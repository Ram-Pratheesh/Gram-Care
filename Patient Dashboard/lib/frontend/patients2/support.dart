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
      title: 'Support',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const SupportScreen(),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F1F1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1B1B)),
          onPressed: () {
            print('Back button pressed');
          },
        ),
        title: const Text(
          'Support',
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
                'Need Help?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const NeedHelpSection(),
              const SizedBox(height: 32),
              const Text(
                'Common Issues',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const CommonIssuesList(),
              const SizedBox(height: 32),
              const Text(
                'Live Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const LiveSupportButtons(),
              const SizedBox(height: 32),
              const Text(
                'Tutorials & Guides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const TutorialsList(),
              const SizedBox(height: 32),
              const Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const FeedbackButton(),
              const SizedBox(height: 32),
              const Text(
                'Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const LanguageButtons(),
              const SizedBox(height: 32),
              const Text(
                'Accessibility',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const AccessibilityList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFEF5350),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: 3, // Assuming Support is the last item
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
            icon: Icon(Icons.help_outline),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}

class NeedHelpSection extends StatelessWidget {
  const NeedHelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Call IVR Helpline button pressed');
            },
            icon: const Icon(Icons.call, color: Colors.white),
            label: const Text(
              'Call IVR Helpline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () {
              print('Voice Assistance button pressed');
            },
            icon: const Icon(Icons.mic, color: Color(0xFF1B1B1B)),
            label: const Text(
              'Voice Assistance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B1B),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFDEDEDE)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CommonIssuesList extends StatelessWidget {
  const CommonIssuesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CommonIssueItem(title: 'App Usage'),
        SizedBox(height: 12),
        CommonIssueItem(title: 'Appointments'),
        SizedBox(height: 12),
        CommonIssueItem(title: 'Telemedicine'),
        SizedBox(height: 12),
        CommonIssueItem(title: 'Medicine Availability'),
      ],
    );
  }
}

class CommonIssueItem extends StatelessWidget {
  final String title;

  const CommonIssueItem({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Common issue item "$title" tapped');
      },
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1B1B1B),
                fontWeight: FontWeight.w400,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF909090),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class LiveSupportButtons extends StatelessWidget {
  const LiveSupportButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Live Support Call button pressed');
              },
              icon: const Icon(Icons.call, color: Color(0xFF1B1B1B), size: 18),
              label: const Text(
                'Call',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFDEDEDE)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                print('Live Support Message button pressed');
              },
              icon: const Icon(
                Icons.message,
                color: Color(0xFF1B1B1B),
                size: 18,
              ),
              label: const Text(
                'Message',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFDEDEDE)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TutorialsList extends StatelessWidget {
  const TutorialsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTutorialItem(
          icon: Icons.home_outlined,
          label: 'Home',
          color: Colors.white,
          isSupport: false,
        ),
        const SizedBox(height: 12),
        _buildTutorialItem(
          icon: Icons.calendar_today_outlined,
          label: 'Appointments',
          color: Colors.white,
          isSupport: false,
        ),
        const SizedBox(height: 12),
        _buildTutorialItem(
          icon: Icons.person_outlined,
          label: 'Profile',
          color: Colors.white,
          isSupport: false,
        ),
        const SizedBox(height: 12),
        _buildTutorialItem(
          icon: Icons.help_outline,
          label: 'Support',
          color: Colors.white,
          isSupport: true,
        ),
        const SizedBox(height: 12),
        _buildTutorialItem(
          icon: Icons.library_books_outlined, // Approximate
          label: 'Step-by-step Guides',
          color: Colors.white,
          isSupport: false,
        ),
      ],
    );
  }

  Widget _buildTutorialItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isSupport = false,
  }) {
    return InkWell(
      onTap: () {
        print('Tutorials & Guides item "$label" tapped');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Icon(
                icon,
                color: isSupport ? const Color(0xFFEF5350) : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isSupport
                          ? const Color(0xFFEF5350)
                          : const Color(0xFF1B1B1B),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF909090),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () {
          print('Report a Problem button pressed');
        },
        icon: const Icon(Icons.flag_outlined, color: Color(0xFF1B1B1B)),
        label: const Text(
          'Report a Problem',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1B1B1B),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFDEDEDE)),
          ),
        ),
      ),
    );
  }
}

class LanguageButtons extends StatelessWidget {
  const LanguageButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildLanguageButton(context, 'ਪੰਜਾਬੀ', isSelected: false),
        const SizedBox(width: 8),
        _buildLanguageButton(context, 'हिन्दी', isSelected: false),
        const SizedBox(width: 8),
        _buildLanguageButton(context, 'English', isSelected: true),
      ],
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    String text, {
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: () {
        print('Language button "$text" tapped');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEF5350) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFEF5350) : const Color(0xFFDEDEDE),
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

class AccessibilityList extends StatelessWidget {
  const AccessibilityList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        AccessibilityItem(
          title: 'Text Size',
          subtitle: 'Adjust for comfortable reading',
        ),
        SizedBox(height: 12),
        AccessibilityItem(title: 'Contrast', subtitle: 'High contrast mode'),
      ],
    );
  }
}

class AccessibilityItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const AccessibilityItem({
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Accessibility item "$title" tapped');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDEDEDE)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF909090),
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF909090),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
