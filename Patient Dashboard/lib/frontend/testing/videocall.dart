import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';

class CallPage extends StatefulWidget {
  final String roomId;
  const CallPage({super.key, required this.roomId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  late IOWebSocketChannel _channel;

  final iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  bool _videoEnabled = true;
  bool _audioEnabled = true;
  bool _inCall = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _connectSignaling();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await _checkPermissions();
    await _startLocalStream();
  }

  Future<void> _checkPermissions() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (!camStatus.isGranted || !micStatus.isGranted) {
      throw Exception("Camera or Microphone permission denied");
    }
  }

  void _connectSignaling() {
    _channel = IOWebSocketChannel.connect('ws://192.168.137.1:8080');
    _channel.sink.add(jsonEncode({'type': 'join', 'room': widget.roomId}));
    _channel.stream.listen((msg) async {
      final data = jsonDecode(msg);
      try {
        switch (data['type']) {
          case 'offer':
            await _createPeer();
            await _pc!.setRemoteDescription(
              RTCSessionDescription(data['sdp'], 'offer'),
            );
            final answer = await _pc!.createAnswer();
            await _pc!.setLocalDescription(answer);
            _channel.sink.add(
              jsonEncode({'type': 'answer', 'sdp': answer.sdp}),
            );
            setState(() {
              _inCall = true;
            });
            break;

          case 'answer':
            await _pc!.setRemoteDescription(
              RTCSessionDescription(data['sdp'], 'answer'),
            );
            setState(() {
              _inCall = true;
            });
            break;

          case 'candidate':
            final c = data['candidate'];
            await _pc?.addCandidate(
              RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
            );
            break;
        }
      } catch (e, st) {
        print("❌ Error handling signaling message: $e");
        print(st);
      }
    });
  }

  Future<void> _startLocalStream() async {
    try {
      final constraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'width': 640,
          'height': 480,
          'frameRate': 30,
        },
      };
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;
    } catch (e, st) {
      print("❌ Error starting local stream: $e");
      print(st);
    }
  }

  Future<void> _createPeer() async {
    try {
      _pc ??= await createPeerConnection(iceServers);
      _localStream?.getTracks().forEach((track) {
        _pc!.addTrack(track, _localStream!);
      });

      _pc!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
        }
      };

      _pc!.onIceCandidate = (RTCIceCandidate candidate) {
        _channel.sink.add(
          jsonEncode({
            'type': 'candidate',
            'candidate': {
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex,
            },
          }),
        );
      };
    } catch (e, st) {
      print("❌ Error creating peer connection: $e");
      print(st);
    }
  }

  Future<void> _makeCall() async {
    try {
      if (_pc == null) await _createPeer();
      if (_localStream == null) await _startLocalStream();

      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      _channel.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));

      setState(() {
        _inCall = true;
      });

      print("✅ Offer sent successfully");
    } catch (e, st) {
      print("❌ Error making call: $e");
      print(st);
    }
  }

  void _endCall() {
    // Stop all local tracks
    _localStream?.getTracks().forEach((track) => track.stop());
    _pc?.close();
    _pc = null;

    // Clear renderers
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    setState(() {
      _inCall = false;
    });
  }

  void _toggleVideo() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().firstWhere(
        (track) => track.kind == 'video',
      );
      videoTrack.enabled = !videoTrack.enabled;
      setState(() {
        _videoEnabled = videoTrack.enabled;
      });
    }
  }

  void _toggleAudio() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().firstWhere(
        (track) => track.kind == 'audio',
      );
      audioTrack.enabled = !audioTrack.enabled;
      setState(() {
        _audioEnabled = audioTrack.enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video
          Positioned.fill(
            child:
                _remoteRenderer.srcObject != null
                    ? RTCVideoView(_remoteRenderer)
                    : const Center(
                      child: Text(
                        "Waiting for user to connect...",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
          ),

          // Local video small overlay
          Positioned(
            top: 40,
            right: 20,
            width: 120,
            height: 160,
            child:
                _localRenderer.srcObject != null
                    ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    )
                    : const SizedBox.shrink(),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "audio",
                  backgroundColor: _audioEnabled ? Colors.green : Colors.red,
                  onPressed: _toggleAudio,
                  child: Icon(_audioEnabled ? Icons.mic : Icons.mic_off),
                ),
                FloatingActionButton(
                  heroTag: "video",
                  backgroundColor: _videoEnabled ? Colors.green : Colors.red,
                  onPressed: _toggleVideo,
                  child: Icon(
                    _videoEnabled ? Icons.videocam : Icons.videocam_off,
                  ),
                ),
                // Start / End call button
                FloatingActionButton(
                  heroTag: "call",
                  backgroundColor: _inCall ? Colors.red : Colors.blue,
                  onPressed: _inCall ? _endCall : _makeCall,
                  child: Icon(_inCall ? Icons.call_end : Icons.call),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
