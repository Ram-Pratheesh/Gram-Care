// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:permission_handler/permission_handler.dart';

// // Import your existing AppointmentDto class
// import 'package:gramcare/frontend/patients/patientappoinment.dart';

// class VideoConsultationScreen extends StatefulWidget {
//   final String patientUsername;
//   final AppointmentDto appointment;
//   final String? doctorName;
//   final String? doctorSpecialty;
//   final String? appointmentDate;
//   final String? appointmentTime;
//   final String? appointmentMode;
//   final String? slotLabel;
//   final String? doctorId;

//   const VideoConsultationScreen({
//     super.key,
//     required this.patientUsername,
//     required this.appointment,
//     this.doctorName,
//     this.doctorSpecialty,
//     this.appointmentDate,
//     this.appointmentTime,
//     this.appointmentMode,
//     this.slotLabel,
//     this.doctorId,
//   });

//   @override
//   State<VideoConsultationScreen> createState() =>
//       _VideoConsultationScreenState();
// }

// class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
//   final _localRenderer = RTCVideoRenderer();
//   final _remoteRenderer = RTCVideoRenderer();
//   RTCPeerConnection? _pc;
//   MediaStream? _localStream;
//   IOWebSocketChannel? _channel;

//   final iceServers = {
//     'iceServers': [
//       {'urls': 'stun:stun.l.google.com:19302'},
//     ],
//   };

//   bool _videoEnabled = true;
//   bool _audioEnabled = true;
//   bool _inCall = false;
//   bool _isInitialized = false;
//   late String _roomId;

//   @override
//   void initState() {
//     super.initState();
//     // Create unique room ID using appointment details and patient info
//     _roomId =
//         'room_${widget.appointment.doctorId}_${widget.patientUsername}_${widget.appointment.appointmentDate.replaceAll(' ', '_')}_${widget.appointment.appointmentTime.replaceAll(':', '_').replaceAll(' ', '_')}';
//     print('Page 1 - Room ID: $_roomId');
//     _initRenderers();
//     _connectSignaling();
//   }

//   Future<void> _initRenderers() async {
//     try {
//       await _localRenderer.initialize();
//       await _remoteRenderer.initialize();
//       await _checkPermissions();
//       await _startLocalStream();
//       setState(() {
//         _isInitialized = true;
//       });
//     } catch (e) {
//       print("❌ Error initializing renderers: $e");
//     }
//   }

//   Future<void> _checkPermissions() async {
//     final camStatus = await Permission.camera.request();
//     final micStatus = await Permission.microphone.request();
//     if (!camStatus.isGranted || !micStatus.isGranted) {
//       throw Exception("Camera or Microphone permission denied");
//     }
//   }

//   void _connectSignaling() {
//     try {
//       _channel = IOWebSocketChannel.connect('ws://192.168.137.1:8080');
//       _channel!.sink.add(jsonEncode({'type': 'join', 'room': _roomId}));

//       _channel!.stream.listen(
//         (msg) async {
//           final data = jsonDecode(msg);
//           try {
//             switch (data['type']) {
//               case 'offer':
//                 await _createPeer();
//                 await _pc!.setRemoteDescription(
//                   RTCSessionDescription(data['sdp'], 'offer'),
//                 );
//                 final answer = await _pc!.createAnswer();
//                 await _pc!.setLocalDescription(answer);
//                 _channel!.sink.add(
//                   jsonEncode({'type': 'answer', 'sdp': answer.sdp}),
//                 );
//                 setState(() {
//                   _inCall = true;
//                 });
//                 break;

//               case 'answer':
//                 await _pc!.setRemoteDescription(
//                   RTCSessionDescription(data['sdp'], 'answer'),
//                 );
//                 setState(() {
//                   _inCall = true;
//                 });
//                 break;

//               case 'candidate':
//                 final c = data['candidate'];
//                 await _pc?.addCandidate(
//                   RTCIceCandidate(
//                     c['candidate'],
//                     c['sdpMid'],
//                     c['sdpMLineIndex'],
//                   ),
//                 );
//                 break;
//             }
//           } catch (e, st) {
//             print("❌ Error handling signaling message: $e");
//             print(st);
//           }
//         },
//         onError: (error) {
//           print("❌ WebSocket error: $error");
//         },
//       );
//     } catch (e) {
//       print("❌ Error connecting to signaling server: $e");
//     }
//   }

//   Future<void> _startLocalStream() async {
//     try {
//       final constraints = {
//         'audio': true,
//         'video': {
//           'facingMode': 'user',
//           'width': 640,
//           'height': 480,
//           'frameRate': 30,
//         },
//       };
//       _localStream = await navigator.mediaDevices.getUserMedia(constraints);
//       if (_localRenderer.srcObject == null) {
//         _localRenderer.srcObject = _localStream;
//       }
//     } catch (e, st) {
//       print("❌ Error starting local stream: $e");
//       print(st);
//     }
//   }

//   Future<void> _createPeer() async {
//     try {
//       _pc ??= await createPeerConnection(iceServers);
//       _localStream?.getTracks().forEach((track) {
//         _pc!.addTrack(track, _localStream!);
//       });

//       _pc!.onTrack = (event) {
//         if (event.streams.isNotEmpty) {
//           setState(() {
//             _remoteRenderer.srcObject = event.streams[0];
//           });
//         }
//       };

//       _pc!.onIceCandidate = (RTCIceCandidate candidate) {
//         _channel?.sink.add(
//           jsonEncode({
//             'type': 'candidate',
//             'candidate': {
//               'candidate': candidate.candidate,
//               'sdpMid': candidate.sdpMid,
//               'sdpMLineIndex': candidate.sdpMLineIndex,
//             },
//           }),
//         );
//       };
//     } catch (e, st) {
//       print("❌ Error creating peer connection: $e");
//       print(st);
//     }
//   }

//   Future<void> _makeCall() async {
//     try {
//       if (_pc == null) await _createPeer();
//       if (_localStream == null) await _startLocalStream();

//       final offer = await _pc!.createOffer();
//       await _pc!.setLocalDescription(offer);
//       _channel?.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));

//       setState(() {
//         _inCall = true;
//       });

//       print("✅ Offer sent successfully from Page 1");
//     } catch (e, st) {
//       print("❌ Error making call: $e");
//       print(st);
//     }
//   }

//   void _endCall() {
//     try {
//       _localStream?.getTracks().forEach((track) => track.stop());
//       _pc?.close();
//       _pc = null;

//       _localRenderer.srcObject = null;
//       _remoteRenderer.srcObject = null;

//       setState(() {
//         _inCall = false;
//       });

//       Navigator.pop(context, true);
//     } catch (e) {
//       print("❌ Error ending call: $e");
//       Navigator.pop(context, true);
//     }
//   }

//   void _toggleVideo() {
//     if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
//       final videoTrack = _localStream!.getVideoTracks().first;
//       videoTrack.enabled = !videoTrack.enabled;
//       setState(() {
//         _videoEnabled = videoTrack.enabled;
//       });
//     }
//   }

//   void _toggleAudio() {
//     if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
//       final audioTrack = _localStream!.getAudioTracks().first;
//       audioTrack.enabled = !audioTrack.enabled;
//       setState(() {
//         _audioEnabled = audioTrack.enabled;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     try {
//       _localStream?.getTracks().forEach((track) => track.stop());
//       _pc?.close();
//       _localRenderer.dispose();
//       _remoteRenderer.dispose();
//       _channel?.sink.close();
//     } catch (e) {
//       print("❌ Error disposing resources: $e");
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F4F8),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFF1F4F8),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//         ),
//         title: const Text(
//           'Consultation',
//           style: TextStyle(
//             color: Color(0xFF1B1B1B),
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 24),
//               const Text(
//                 'Main Video Feed',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1B1B1B),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               VideoCallFeed(
//                 localRenderer: _localRenderer,
//                 remoteRenderer: _remoteRenderer,
//                 isInitialized: _isInitialized,
//                 inCall: _inCall,
//                 onStartCall: _makeCall,
//               ),
//               const SizedBox(height: 16),
//               VideoControlButtons(
//                 videoEnabled: _videoEnabled,
//                 audioEnabled: _audioEnabled,
//                 onToggleVideo: _toggleVideo,
//                 onToggleAudio: _toggleAudio,
//               ),
//               const SizedBox(height: 24),
//               ConsultationDetailsCard(appointment: widget.appointment),
//               const SizedBox(height: 24),
//               CallEndButton(onEndCall: _endCall),
//               const SizedBox(height: 16),
//               const HelpButton(),
//               const SizedBox(height: 24),
//               const PrivacyInfoText(),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFF3B9BFE),
//         unselectedItemColor: Colors.grey.shade600,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//         currentIndex: 1,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           print('Bottom nav item $index pressed');
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today_outlined),
//             label: 'Appointments',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings_outlined),
//             label: 'Settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class VideoCallFeed extends StatelessWidget {
//   final RTCVideoRenderer localRenderer;
//   final RTCVideoRenderer remoteRenderer;
//   final bool isInitialized;
//   final bool inCall;
//   final VoidCallback onStartCall;

//   const VideoCallFeed({
//     super.key,
//     required this.localRenderer,
//     required this.remoteRenderer,
//     required this.isInitialized,
//     required this.inCall,
//     required this.onStartCall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           height: 420,
//           decoration: BoxDecoration(
//             color: const Color(0xFF90A4AE),
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child:
//                 remoteRenderer.srcObject != null && inCall
//                     ? RTCVideoView(remoteRenderer)
//                     : Container(
//                       color: const Color(0xFF90A4AE),
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               inCall ? Icons.videocam_off : Icons.videocam,
//                               color: Colors.white,
//                               size: 64,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               inCall
//                                   ? "Waiting for remote video..."
//                                   : "Ready to start call",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             if (!inCall && isInitialized) ...[
//                               const SizedBox(height: 16),
//                               ElevatedButton(
//                                 onPressed: onStartCall,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF3B9BFE),
//                                 ),
//                                 child: const Text(
//                                   "Start Call",
//                                   style: TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                     ),
//           ),
//         ),
//         Positioned(
//           bottom: 16,
//           right: 16,
//           child: Container(
//             width: 120,
//             height: 155,
//             decoration: BoxDecoration(
//               color: Colors.black26,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.white, width: 2),
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child:
//                   isInitialized && localRenderer.srcObject != null
//                       ? RTCVideoView(localRenderer, mirror: true)
//                       : const Center(
//                         child: Icon(
//                           Icons.person,
//                           color: Colors.white,
//                           size: 40,
//                         ),
//                       ),
//             ),
//           ),
//         ),
//         const Positioned(top: 12, right: 12, child: VideoTimeDisplay()),
//       ],
//     );
//   }
// }

// class ConsultationDetailsCard extends StatelessWidget {
//   final AppointmentDto appointment;

//   const ConsultationDetailsCard({super.key, required this.appointment});

//   String _formatDate(String dateStr) {
//     try {
//       final parts = dateStr.split(' ');
//       if (parts.length >= 2) {
//         final day = parts[0];
//         final month = parts[1];
//         return 'Today, $month $day';
//       }
//       return dateStr;
//     } catch (e) {
//       return dateStr;
//     }
//   }

//   String _formatTimeRange(String timeStr) {
//     try {
//       return '$timeStr - ${_addMinutes(timeStr, 30)}';
//     } catch (e) {
//       return timeStr;
//     }
//   }

//   String _addMinutes(String timeStr, int minutesToAdd) {
//     try {
//       final parts = timeStr.split(' ');
//       if (parts.length == 2) {
//         final timePart = parts[0];
//         final amPm = parts[1];
//         final timeParts = timePart.split(':');
//         if (timeParts.length == 2) {
//           int hour = int.parse(timeParts[0]);
//           int minute = int.parse(timeParts[1]);

//           minute += minutesToAdd;
//           if (minute >= 60) {
//             hour += minute ~/ 60;
//             minute = minute % 60;
//           }

//           if (hour > 12) {
//             hour -= 12;
//           }

//           return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
//         }
//       }
//       return timeStr;
//     } catch (e) {
//       return timeStr;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 5,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Appointment Details',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1B1B1B),
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow(
//             icon: Icons.person_outlined,
//             text:
//                 appointment.doctorName.isNotEmpty
//                     ? appointment.doctorName
//                     : 'Dr. Unknown',
//             subtitle:
//                 appointment.doctorSpecialty.isNotEmpty
//                     ? appointment.doctorSpecialty
//                     : 'General Medicine',
//             isProfile: true,
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow(
//             icon: Icons.calendar_today_outlined,
//             text: _formatDate(appointment.appointmentDate),
//             subtitle: _formatTimeRange(appointment.appointmentTime),
//             isProfile: false,
//           ),
//           const SizedBox(height: 16),
//           _buildDetailRow(
//             icon: Icons.videocam_outlined,
//             text: 'Mode: ${appointment.mode}',
//             subtitle: 'Slot: ${appointment.slotLabel}',
//             isProfile: false,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow({
//     required IconData icon,
//     required String text,
//     required String subtitle,
//     required bool isProfile,
//   }) {
//     return Row(
//       children: [
//         if (isProfile)
//           const CircleAvatar(
//             backgroundImage: AssetImage('assets/dummy_doctor_image.png'),
//             radius: 24,
//           )
//         else
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8F4F8),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFF3B9BFE)),
//           ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 text,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF1B1B1B),
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class VideoTimeDisplay extends StatelessWidget {
//   const VideoTimeDisplay({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.5),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const Text(
//             '05:32',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         InkWell(
//           onTap: () {
//             print('Mute icon pressed');
//           },
//           child: const Icon(Icons.volume_up, color: Colors.white),
//         ),
//       ],
//     );
//   }
// }

// class VideoControlButtons extends StatelessWidget {
//   final bool videoEnabled;
//   final bool audioEnabled;
//   final VoidCallback onToggleVideo;
//   final VoidCallback onToggleAudio;

//   const VideoControlButtons({
//     super.key,
//     required this.videoEnabled,
//     required this.audioEnabled,
//     required this.onToggleVideo,
//     required this.onToggleAudio,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildControlButton(
//           audioEnabled ? 'Mute' : 'Unmute',
//           audioEnabled ? Icons.mic : Icons.mic_off,
//           onToggleAudio,
//           audioEnabled,
//         ),
//         _buildControlButton(
//           videoEnabled ? 'Cam Off' : 'Cam On',
//           videoEnabled ? Icons.videocam : Icons.videocam_off,
//           onToggleVideo,
//           videoEnabled,
//         ),
//         _buildControlButton('Chat', Icons.chat_bubble_outline, () {
//           print('Chat button pressed');
//         }, true),
//         _buildControlButton('Notes', Icons.description_outlined, () {
//           print('Notes button pressed');
//         }, true),
//       ],
//     );
//   }

//   Widget _buildControlButton(
//     String label,
//     IconData icon,
//     VoidCallback onPressed,
//     bool isEnabled,
//   ) {
//     return InkWell(
//       onTap: onPressed,
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isEnabled ? Colors.white : Colors.red.shade100,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color:
//                     isEnabled ? const Color(0xFFDEDEDE) : Colors.red.shade300,
//               ),
//             ),
//             child: Icon(
//               icon,
//               color: isEnabled ? Colors.grey.shade600 : Colors.red.shade600,
//               size: 24,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Color(0xFF666666),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CallEndButton extends StatelessWidget {
//   final VoidCallback? onEndCall;

//   const CallEndButton({super.key, this.onEndCall});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton(
//         onPressed: () {
//           print('End Call button pressed');
//           if (onEndCall != null) {
//             onEndCall!();
//           } else {
//             Navigator.pop(context, true);
//           }
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFFEF5350),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         child: const Text(
//           'End Call',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class HelpButton extends StatelessWidget {
//   const HelpButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: OutlinedButton.icon(
//         onPressed: () {
//           print('Need Help button pressed');
//         },
//         icon: const Icon(Icons.help_outline, color: Color(0xFF3B9BFE)),
//         label: const Text(
//           'Need Help?',
//           style: TextStyle(
//             color: Color(0xFF3B9BFE),
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         style: OutlinedButton.styleFrom(
//           side: const BorderSide(color: Color(0xFF3B9BFE)),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PrivacyInfoText extends StatelessWidget {
//   const PrivacyInfoText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F4F8),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: const Text.rich(
//         TextSpan(
//           children: [
//             TextSpan(
//               text: 'Privacy Notice: ',
//               style: TextStyle(
//                 color: Color(0xFF3B9BFE),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             TextSpan(
//               text:
//                   'This consultation is being recorded for security purposes. The information will be kept confidential.',
//               style: TextStyle(color: Color(0xFF666666), fontSize: 12),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';
import 'package:permission_handler/permission_handler.dart';

// Import your existing AppointmentDto class
import 'package:gramcare/frontend/patients/patientappoinment.dart';

class VideoConsultationScreen extends StatefulWidget {
  final String patientUsername;
  final AppointmentDto appointment;
  final String? doctorName;
  final String? doctorSpecialty;
  final String? appointmentDate;
  final String? appointmentTime;
  final String? appointmentMode;
  final String? slotLabel;
  final String? doctorId;

  const VideoConsultationScreen({
    super.key,
    required this.patientUsername,
    required this.appointment,
    this.doctorName,
    this.doctorSpecialty,
    this.appointmentDate,
    this.appointmentTime,
    this.appointmentMode,
    this.slotLabel,
    this.doctorId,
  });

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  IOWebSocketChannel? _channel;

  final iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  bool _videoEnabled = true;
  bool _audioEnabled = true;
  bool _inCall = false;
  bool _isInitialized = false;
  late String _roomId;

  @override
  void initState() {
    super.initState();
    // Use a simple fixed room ID for testing
    _roomId = 'test_room_123';
    print('Page 1 (Patient) - Room ID: $_roomId');
    _initRenderers();
    _connectSignaling();
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      await _checkPermissions();
      await _startLocalStream();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print("❌ Error initializing renderers: $e");
    }
  }

  Future<void> _checkPermissions() async {
    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (!camStatus.isGranted || !micStatus.isGranted) {
      throw Exception("Camera or Microphone permission denied");
    }
  }

  void _connectSignaling() {
    try {
      _channel = IOWebSocketChannel.connect('ws://192.168.137.1:8080');

      // Add connection success handler
      _channel!.sink.add(jsonEncode({'type': 'join', 'room': _roomId}));
      print(
        '✅ Successfully connected to signaling server and joined room: $_roomId',
      );

      _channel!.stream.listen(
        (msg) async {
          final data = jsonDecode(msg);
          try {
            print('📨 Received message: ${data['type']} in room $_roomId');
            switch (data['type']) {
              case 'joined-room':
                print('🏠 Joined room info: ${data.toString()}');
                break;
              case 'user-joined':
                print('👤 Another user joined the room!');
                break;
              case 'offer':
                print('📞 Received offer from remote peer');
                await _handleOffer(data);
                break;
              case 'answer':
                print('✅ Received answer from remote peer');
                await _handleAnswer(data);
                break;
              case 'candidate':
                print('🔄 Received ICE candidate from remote peer');
                await _handleCandidate(data);
                break;
            }
          } catch (e, st) {
            print("❌ Error handling signaling message: $e");
            print(st);
          }
        },
        onError: (error) {
          print("❌ WebSocket error: $error");
        },
        onDone: () {
          print("🔌 WebSocket connection closed");
        },
      );
    } catch (e) {
      print("❌ Error connecting to signaling server: $e");
    }
  }

  Future<void> _handleOffer(Map<String, dynamic> data) async {
    if (_pc == null) await _createPeer();

    await _pc!.setRemoteDescription(
      RTCSessionDescription(data['sdp'], 'offer'),
    );

    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);

    _channel!.sink.add(jsonEncode({'type': 'answer', 'sdp': answer.sdp}));

    setState(() {
      _inCall = true;
    });
  }

  Future<void> _handleAnswer(Map<String, dynamic> data) async {
    await _pc!.setRemoteDescription(
      RTCSessionDescription(data['sdp'], 'answer'),
    );

    setState(() {
      _inCall = true;
    });
  }

  Future<void> _handleCandidate(Map<String, dynamic> data) async {
    final c = data['candidate'];
    await _pc?.addCandidate(
      RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
    );
  }

  Future<void> _startLocalStream() async {
    try {
      final constraints = {
        'audio': {
          'mandatory': {
            'googEchoCancellation': 'true',
            'googAutoGainControl': 'true',
            'googNoiseSuppression': 'true',
            'googHighpassFilter': 'true',
          },
          'optional': [],
        },
        'video': {
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        },
      };
      _localStream = await navigator.mediaDevices.getUserMedia(constraints);
      _localRenderer.srcObject = _localStream;
      setState(() {}); // Trigger rebuild
    } catch (e, st) {
      print("❌ Error starting local stream: $e");
      print(st);
    }
  }

  Future<void> _createPeer() async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      };

      _pc = await createPeerConnection(config);

      // Add local stream tracks
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _pc!.addTrack(track, _localStream!);
        });
      }

      // Handle remote stream
      _pc!.onTrack = (event) {
        print('🎥 Remote track received: ${event.track.kind}');
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteRenderer.srcObject = event.streams[0];
          });
          print('✅ Remote stream set to renderer');
        }
      };

      // Handle ICE candidates
      _pc!.onIceCandidate = (RTCIceCandidate candidate) {
        print('🔄 Sending ICE candidate');
        _channel?.sink.add(
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

      // Handle connection state changes
      _pc!.onConnectionState = (RTCPeerConnectionState state) {
        print('🔗 Connection state: $state');
      };

      _pc!.onIceConnectionState = (RTCIceConnectionState state) {
        print('🧊 ICE connection state: $state');
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

      print('📞 Creating offer...');
      final offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);

      _channel?.sink.add(jsonEncode({'type': 'offer', 'sdp': offer.sdp}));

      setState(() {
        _inCall = true;
      });

      print("✅ Offer sent successfully from Patient");
    } catch (e, st) {
      print("❌ Error making call: $e");
      print(st);
    }
  }

  void _endCall() {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _pc?.close();
      _pc = null;

      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;

      setState(() {
        _inCall = false;
      });

      Navigator.pop(context, true);
    } catch (e) {
      print("❌ Error ending call: $e");
      Navigator.pop(context, true);
    }
  }

  void _toggleVideo() {
    if (_localStream != null && _localStream!.getVideoTracks().isNotEmpty) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
      setState(() {
        _videoEnabled = videoTrack.enabled;
      });
    }
  }

  void _toggleAudio() {
    if (_localStream != null && _localStream!.getAudioTracks().isNotEmpty) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      setState(() {
        _audioEnabled = audioTrack.enabled;
      });
    }
  }

  @override
  void dispose() {
    try {
      _localStream?.getTracks().forEach((track) => track.stop());
      _pc?.close();
      _localRenderer.dispose();
      _remoteRenderer.dispose();
      _channel?.sink.close();
    } catch (e) {
      print("❌ Error disposing resources: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F4F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        title: const Text(
          'Consultation',
          style: TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Main Video Feed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 12),
              VideoCallFeed(
                localRenderer: _localRenderer,
                remoteRenderer: _remoteRenderer,
                isInitialized: _isInitialized,
                inCall: _inCall,
                onStartCall: _makeCall,
              ),
              const SizedBox(height: 16),
              VideoControlButtons(
                videoEnabled: _videoEnabled,
                audioEnabled: _audioEnabled,
                onToggleVideo: _toggleVideo,
                onToggleAudio: _toggleAudio,
              ),
              const SizedBox(height: 24),
              ConsultationDetailsCard(appointment: widget.appointment),
              const SizedBox(height: 24),
              CallEndButton(onEndCall: _endCall),
              const SizedBox(height: 16),
              const HelpButton(),
              const SizedBox(height: 24),
              const PrivacyInfoText(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF3B9BFE),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          print('Bottom nav item $index pressed');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// All the UI components remain the same...
class VideoCallFeed extends StatelessWidget {
  final RTCVideoRenderer localRenderer;
  final RTCVideoRenderer remoteRenderer;
  final bool isInitialized;
  final bool inCall;
  final VoidCallback onStartCall;

  const VideoCallFeed({
    super.key,
    required this.localRenderer,
    required this.remoteRenderer,
    required this.isInitialized,
    required this.inCall,
    required this.onStartCall,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 420,
          decoration: BoxDecoration(
            color: const Color(0xFF90A4AE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                remoteRenderer.srcObject != null && inCall
                    ? RTCVideoView(remoteRenderer)
                    : Container(
                      color: const Color(0xFF90A4AE),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              inCall ? Icons.videocam_off : Icons.videocam,
                              color: Colors.white,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              inCall
                                  ? "Waiting for doctor to join..."
                                  : "Ready to start consultation",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            if (!inCall && isInitialized) ...[
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: onStartCall,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B9BFE),
                                ),
                                child: const Text(
                                  "Start Consultation",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            width: 120,
            height: 155,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
                  isInitialized && localRenderer.srcObject != null
                      ? RTCVideoView(localRenderer, mirror: true)
                      : const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
            ),
          ),
        ),
        const Positioned(top: 12, right: 12, child: VideoTimeDisplay()),
      ],
    );
  }
}

// Keep all other UI components exactly the same as your original code...
// (ConsultationDetailsCard, VideoTimeDisplay, VideoControlButtons, etc.)

class ConsultationDetailsCard extends StatelessWidget {
  final AppointmentDto appointment;

  const ConsultationDetailsCard({super.key, required this.appointment});

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        final day = parts[0];
        final month = parts[1];
        return 'Today, $month $day';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTimeRange(String timeStr) {
    try {
      return '$timeStr - ${_addMinutes(timeStr, 30)}';
    } catch (e) {
      return timeStr;
    }
  }

  String _addMinutes(String timeStr, int minutesToAdd) {
    try {
      final parts = timeStr.split(' ');
      if (parts.length == 2) {
        final timePart = parts[0];
        final amPm = parts[1];
        final timeParts = timePart.split(':');
        if (timeParts.length == 2) {
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);

          minute += minutesToAdd;
          if (minute >= 60) {
            hour += minute ~/ 60;
            minute = minute % 60;
          }

          if (hour > 12) {
            hour -= 12;
          }

          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
        }
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.person_outlined,
            text:
                appointment.doctorName.isNotEmpty
                    ? appointment.doctorName
                    : 'Dr. Unknown',
            subtitle:
                appointment.doctorSpecialty.isNotEmpty
                    ? appointment.doctorSpecialty
                    : 'General Medicine',
            isProfile: true,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            text: _formatDate(appointment.appointmentDate),
            subtitle: _formatTimeRange(appointment.appointmentTime),
            isProfile: false,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            icon: Icons.videocam_outlined,
            text: 'Mode: ${appointment.mode}',
            subtitle: 'Slot: ${appointment.slotLabel}',
            isProfile: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required String subtitle,
    required bool isProfile,
  }) {
    return Row(
      children: [
        if (isProfile)
          const CircleAvatar(
            backgroundImage: AssetImage('assets/dummy_doctor_image.png'),
            radius: 24,
          )
        else
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF3B9BFE)),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoTimeDisplay extends StatelessWidget {
  const VideoTimeDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '05:32',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            print('Mute icon pressed');
          },
          child: const Icon(Icons.volume_up, color: Colors.white),
        ),
      ],
    );
  }
}

class VideoControlButtons extends StatelessWidget {
  final bool videoEnabled;
  final bool audioEnabled;
  final VoidCallback onToggleVideo;
  final VoidCallback onToggleAudio;

  const VideoControlButtons({
    super.key,
    required this.videoEnabled,
    required this.audioEnabled,
    required this.onToggleVideo,
    required this.onToggleAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildControlButton(
          audioEnabled ? 'Mute' : 'Unmute',
          audioEnabled ? Icons.mic : Icons.mic_off,
          onToggleAudio,
          audioEnabled,
        ),
        _buildControlButton(
          videoEnabled ? 'Cam Off' : 'Cam On',
          videoEnabled ? Icons.videocam : Icons.videocam_off,
          onToggleVideo,
          videoEnabled,
        ),
        _buildControlButton('Chat', Icons.chat_bubble_outline, () {
          print('Chat button pressed');
        }, true),
        _buildControlButton('Notes', Icons.description_outlined, () {
          print('Notes button pressed');
        }, true),
      ],
    );
  }

  Widget _buildControlButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
    bool isEnabled,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isEnabled ? const Color(0xFFDEDEDE) : Colors.red.shade300,
              ),
            ),
            child: Icon(
              icon,
              color: isEnabled ? Colors.grey.shade600 : Colors.red.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class CallEndButton extends StatelessWidget {
  final VoidCallback? onEndCall;

  const CallEndButton({super.key, this.onEndCall});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          print('End Call button pressed');
          if (onEndCall != null) {
            onEndCall!();
          } else {
            Navigator.pop(context, true);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF5350),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'End Call',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  const HelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {
          print('Need Help button pressed');
        },
        icon: const Icon(Icons.help_outline, color: Color(0xFF3B9BFE)),
        label: const Text(
          'Need Help?',
          style: TextStyle(
            color: Color(0xFF3B9BFE),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF3B9BFE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class PrivacyInfoText extends StatelessWidget {
  const PrivacyInfoText({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'Privacy Notice: ',
              style: TextStyle(
                color: Color(0xFF3B9BFE),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text:
                  'This consultation is being recorded for security purposes. The information will be kept confidential.',
              style: TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
