import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: const SymptomCheckerScreen(),
    );
  }
}

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  int _bottomNavIndex = 0;
  int _chatModeIndex = 1;
  int _languageIndex = 2;

  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];

  void _handleSend() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add({'type': 'input', 'text': _textController.text});
        _chatMessages.add({
          'type': 'output',
          'text':
              'This is a sample AI response to your message: "${_textController.text}"',
        });
      });
      _textController.clear();
      print('Message sent: ${_chatMessages.last['text']}');
    }
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
            print('Back button pressed');
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
              const AISymptomCheckerHeader(),
              const SizedBox(height: 24),
              if (_chatMessages.isNotEmpty)
                ..._chatMessages.map((msg) {
                  if (msg['type'] == 'input') {
                    return ChatBubble(text: msg['text']!, isUserMessage: true);
                  } else {
                    return ChatBubble(text: msg['text']!, isUserMessage: false);
                  }
                }).toList(),
              const SizedBox(height: 16),
              AISymptomCheckerInput(
                chatModeIndex: _chatModeIndex,
                onModeSelected: (index) {
                  setState(() {
                    _chatModeIndex = index;
                  });
                },
                textController: _textController,
                onSend: _handleSend,
              ),
              const SizedBox(height: 16),
              LanguageSelectionCard(
                selectedIndex: _languageIndex,
                onLanguageSelected: (index) {
                  setState(() {
                    _languageIndex = index;
                  });
                },
              ),
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
        currentIndex: _bottomNavIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
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

class AISymptomCheckerHeader extends StatelessWidget {
  const AISymptomCheckerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Symptom Checker',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1B1B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Describe your symptoms in your\npreferred language.',
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AISymptomCheckerInput extends StatelessWidget {
  final int chatModeIndex;
  final ValueChanged<int> onModeSelected;
  final TextEditingController textController;
  final VoidCallback onSend;

  const AISymptomCheckerInput({
    required this.chatModeIndex,
    required this.onModeSelected,
    required this.textController,
    required this.onSend,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
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
          ModeSelectionTabs(
            selectedIndex: chatModeIndex,
            onModeSelected: onModeSelected,
          ),
          const SizedBox(height: 16),
          SymptomInputBox(
            controller: textController,
            isVoiceMode: chatModeIndex == 0,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                'Send',
                style: TextStyle(
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
  final String text;
  final bool isUserMessage;

  const ChatBubble({
    required this.text,
    required this.isUserMessage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        isUserMessage ? const Color(0xFFDCF8C6) : const Color(0xFFE0E0E0);
    final borderRadius =
        isUserMessage
            ? const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )
            : const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(color: color, borderRadius: borderRadius),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF1B1B1B)),
        ),
      ),
    );
  }
}

class ModeSelectionTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onModeSelected;

  const ModeSelectionTabs({
    required this.selectedIndex,
    required this.onModeSelected,
    super.key,
  });

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
    final bool isSelected = selectedIndex == index;
    final Color selectedColor = const Color(0xFF32AE4B);
    final Color unselectedColor = Colors.grey.shade600;

    return InkWell(
      onTap: () => onModeSelected(index),
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

class SymptomInputBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isVoiceMode;

  const SymptomInputBox({
    required this.controller,
    required this.isVoiceMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child:
          isVoiceMode
              ? Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Start voice recording');
                  },
                  icon: const Icon(Icons.mic, color: Colors.white),
                  label: const Text(
                    'Start Recording',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF32AE4B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              )
              : TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Describe your symptoms...',
                  hintStyle: TextStyle(color: Color(0xFFA5A5A5), fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
    );
  }
}

class LanguageSelectionCard extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onLanguageSelected;

  const LanguageSelectionCard({
    required this.selectedIndex,
    required this.onLanguageSelected,
    super.key,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildLanguageButton(context, 'Punjabi', 0),
              const SizedBox(width: 8),
              _buildLanguageButton(context, 'Hindi', 1),
              const SizedBox(width: 8),
              _buildLanguageButton(context, 'English', 2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String text, int index) {
    final bool isSelected = selectedIndex == index;
    final Color selectedColor = const Color(0xFFEF5350);
    final Color unselectedColor = Colors.white;

    return InkWell(
      onTap: () => onLanguageSelected(index),
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
