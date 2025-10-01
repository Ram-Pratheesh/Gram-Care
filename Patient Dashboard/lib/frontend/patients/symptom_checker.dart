// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'GramCare',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       home: const SymptomCheckerScreen(username: 'User'),
//     );
//   }
// }

// class SymptomCheckerScreen extends StatefulWidget {
//   final String username;
//   const SymptomCheckerScreen({super.key, required this.username});

//   @override
//   State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
// }

// class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
//   int _selectedIndex = 0; // Assuming Home is the first item

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
//             print('Back button pressed');
//           },
//         ),
//         title: const Text(
//           'GramCare',
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
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               const AISymptomCheckerCard(),
//               const SizedBox(height: 16),
//               const LanguageSelectionCard(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFF32AE4B),
//         unselectedItemColor: Colors.grey.shade600,
//         selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
//         unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
//         currentIndex: _selectedIndex,
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
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

// class AISymptomCheckerCard extends StatelessWidget {
//   const AISymptomCheckerCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//             'AI Symptom Checker',
//             style: TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1B1B1B),
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Describe your symptoms in your\npreferred language.',
//             style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
//           ),
//           const SizedBox(height: 24),
//           const ModeSelectionTabs(),
//           const SizedBox(height: 16),
//           const SymptomInputBox(),
//           const SizedBox(height: 16),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 print('Send button pressed');
//               },
//               icon: const Icon(Icons.send, color: Colors.white),
//               label: const Text(
//                 'Send',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF32AE4B),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ModeSelectionTabs extends StatefulWidget {
//   const ModeSelectionTabs({super.key});

//   @override
//   State<ModeSelectionTabs> createState() => _ModeSelectionTabsState();
// }

// class _ModeSelectionTabsState extends State<ModeSelectionTabs> {
//   int _selectedIndex = 1; // Text is selected by default

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _buildTab(context, 'Voice', Icons.mic, 0),
//         _buildTab(context, 'Text', Icons.message, 1),
//       ],
//     );
//   }

//   Widget _buildTab(
//     BuildContext context,
//     String text,
//     IconData icon,
//     int index,
//   ) {
//     final bool isSelected = _selectedIndex == index;
//     final Color selectedColor = const Color(0xFF32AE4B);
//     final Color unselectedColor = Colors.grey.shade600;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedIndex = index;
//         });
//         print('$text tab tapped');
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: isSelected ? selectedColor : unselectedColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: isSelected ? selectedColor : unselectedColor,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Container(
//               height: 2,
//               width: 60, // Approximate width
//               color: isSelected ? selectedColor : Colors.transparent,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SymptomInputBox extends StatelessWidget {
//   const SymptomInputBox({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       height: 150,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF7F7F7),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: const TextField(
//         maxLines: null,
//         expands: true,
//         decoration: InputDecoration(
//           hintText: 'Describe your symptoms...',
//           hintStyle: TextStyle(color: Color(0xFFA5A5A5), fontSize: 16),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }

// class LanguageSelectionCard extends StatefulWidget {
//   const LanguageSelectionCard({super.key});

//   @override
//   State<LanguageSelectionCard> createState() => _LanguageSelectionCardState();
// }

// class _LanguageSelectionCardState extends State<LanguageSelectionCard> {
//   int _selectedLanguageIndex = 2; // English is selected by default

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//             'Language Selection',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1B1B1B),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               _buildLanguageButton(context, 'Punjabi', 0),
//               const SizedBox(width: 8),
//               _buildLanguageButton(context, 'Hindi', 1),
//               const SizedBox(width: 8),
//               _buildLanguageButton(context, 'English', 2),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLanguageButton(BuildContext context, String text, int index) {
//     final bool isSelected = _selectedLanguageIndex == index;
//     final Color selectedColor = const Color(0xFFEF5350); // Approximate
//     final Color unselectedColor = Colors.white;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedLanguageIndex = index;
//         });
//         print('Language button "$text" tapped');
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? selectedColor : unselectedColor,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(
//             color: isSelected ? selectedColor : const Color(0xFFDEDEDE),
//           ),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF1B1B1B),
//             fontSize: 16,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SymptomCheckerScreen(username: 'User'),
    );
  }
}

// API Service Class with proper localhost handling
class MedTriageApiService {
  // Dynamic base URL based on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.137.1:3000';
    } else if (Platform.isAndroid) {
      return 'http://192.168.137.1:3000'; // Android emulator localhost
    } else if (Platform.isIOS) {
      return 'http://192.168.137.1:3000'; // iOS simulator
    } else {
      return 'http://192.168.137.1:3000'; // Desktop/other platforms
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String message,
    String sessionId,
  ) async {
    try {
      print('Sending request to: ${baseUrl}/chat');
      print('Message: $message');
      print('Session ID: $sessionId');

      final response = await http
          .post(
            Uri.parse('${baseUrl}/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'message': message, 'sessionId': sessionId}),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> resetConversation(
    String sessionId,
  ) async {
    try {
      print('Resetting conversation for session: $sessionId');

      final response = await http
          .post(
            Uri.parse('${baseUrl}/reset'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'sessionId': sessionId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Reset Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      print('Checking health at: ${baseUrl}/health');

      final response = await http
          .get(
            Uri.parse('${baseUrl}/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      print('Health check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Health Check Error: $e');
      rethrow;
    }
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class SymptomCheckerScreen extends StatefulWidget {
  final String username;
  const SymptomCheckerScreen({super.key, required this.username});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  int _selectedIndex = 0;
  final String _sessionId = 'user_${DateTime.now().millisecondsSinceEpoch}';

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
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'GramCare',
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AISymptomCheckerCard(sessionId: _sessionId),
              const SizedBox(height: 16),
              const LanguageSelectionCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF32AE4B),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _handleBottomNavTap(index);
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

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        _showSnackBar('Appointments feature coming soon!');
        break;
      case 2:
        _showSnackBar('Profile feature coming soon!');
        break;
      case 3:
        _showSnackBar('Settings feature coming soon!');
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF32AE4B),
      ),
    );
  }
}

class AISymptomCheckerCard extends StatefulWidget {
  final String sessionId;
  const AISymptomCheckerCard({super.key, required this.sessionId});

  @override
  State<AISymptomCheckerCard> createState() => _AISymptomCheckerCardState();
}

class _AISymptomCheckerCardState extends State<AISymptomCheckerCard> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _connectionStatus = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkApiConnection();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _checkApiConnection() async {
    try {
      await MedTriageApiService.checkHealth();
      setState(() {
        _connectionStatus = 'Connected to MedTriage AI';
      });
    } catch (e) {
      setState(() {
        _connectionStatus =
            'Connection failed - Check if API server is running';
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _textController.clear();

    try {
      final response = await MedTriageApiService.sendMessage(
        message,
        widget.sessionId,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            text: response['response'] ?? 'No response received',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                'Error: Unable to get response from MedTriage. Please check your connection and try again.',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _resetConversation() async {
    try {
      await MedTriageApiService.resetConversation(widget.sessionId);
      setState(() {
        _messages.clear();
      });
      _showSnackBar('Conversation reset successfully');
    } catch (e) {
      _showSnackBar('Failed to reset conversation');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF32AE4B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Symptom Checker',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              IconButton(
                onPressed: _resetConversation,
                icon: const Icon(Icons.refresh, color: Color(0xFF32AE4B)),
                tooltip: 'Reset Conversation',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _connectionStatus,
            style: TextStyle(
              fontSize: 12,
              color:
                  _connectionStatus.contains('Connected')
                      ? Colors.green
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Describe your symptoms in your\npreferred language.',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 24),
          const ModeSelectionTabs(),
          const SizedBox(height: 16),

          // Chat Messages Area
          if (_messages.isNotEmpty) ...[
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(message: message);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Input Area
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Describe your symptoms...',
                hintStyle: TextStyle(color: Color(0xFFA5A5A5), fontSize: 16),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _sendMessage,
              icon:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.send, color: Colors.white),
              label: Text(
                _isLoading ? 'Sending...' : 'Send',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF32AE4B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF32AE4B),
              child: Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF32AE4B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    message.isUser
                        ? null
                        : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF666666),
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

class ModeSelectionTabs extends StatefulWidget {
  const ModeSelectionTabs({super.key});

  @override
  State<ModeSelectionTabs> createState() => _ModeSelectionTabsState();
}

class _ModeSelectionTabsState extends State<ModeSelectionTabs> {
  int _selectedIndex = 1; // Text is selected by default

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTab(context, 'Voice', Icons.mic, 0),
        _buildTab(context, 'Text', Icons.message, 1),
      ],
    );
  }

  Widget _buildTab(
    BuildContext context,
    String text,
    IconData icon,
    int index,
  ) {
    final bool isSelected = _selectedIndex == index;
    final Color selectedColor = const Color(0xFF32AE4B);
    final Color unselectedColor = Colors.grey.shade600;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Voice input feature coming soon!'),
              backgroundColor: Color(0xFF32AE4B),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: isSelected ? selectedColor : unselectedColor),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? selectedColor : unselectedColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 2,
              width: 60,
              color: isSelected ? selectedColor : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageSelectionCard extends StatefulWidget {
  const LanguageSelectionCard({super.key});

  @override
  State<LanguageSelectionCard> createState() => _LanguageSelectionCardState();
}

class _LanguageSelectionCardState extends State<LanguageSelectionCard> {
  int _selectedLanguageIndex = 2; // English is selected by default

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            'Language Selection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLanguageButton(context, 'Punjabi', 0),
              _buildLanguageButton(context, 'Hindi', 1),
              _buildLanguageButton(context, 'English', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, int index) {
    final bool isSelected = _selectedLanguageIndex == index;
    final Color selectedColor = const Color(0xFFEF5350);
    final Color unselectedColor = Colors.white;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguageIndex = index;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language switched to $text'),
            backgroundColor: selectedColor,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFDEDEDE),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1B1B1B),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
