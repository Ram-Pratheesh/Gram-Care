import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const GramCareApp());
}

class GramCareApp extends StatelessWidget {
  const GramCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Inter', // Replace with exact font if different.
        scaffoldBackgroundColor: const Color(
          0xFFF7F1EE,
        ), // Soft warm gray seen in screen.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935), // Red for main call actions.
          secondary: const Color(0xFFFFE0DC),
          surface: Colors.white,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A1A),
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
        ),
      ),
      home: const EmergencyServicesScreen(),
    );
  }
}

class EmergencyServicesScreen extends StatelessWidget {
  const EmergencyServicesScreen({super.key});

  // Colors eyedropped/approximated from the mock:
  static const Color kBackground = Color(0xFFF7F1EE);
  static const Color kCard = Colors.white;
  static const Color kPrimaryRed = Color(0xFFE53935);
  static const Color kPrimaryRedDark = Color(0xFFCF2F2B);
  static const Color kSoftRed = Color(0xFFFFE0DC);
  static const Color kPillRed = Color(0xFFF7C7C1);
  static const Color kTextDark = Color(0xFF1A1A1A);
  static const Color kTextMuted = Color(0xFF7A7370);
  static const Color kBorder = Color(0xFFE7DCD7);

  // Shadows approximated:
  static const List<BoxShadow> kBigShadow = [
    BoxShadow(
      color: Color(0x33E53935),
      blurRadius: 20,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];
  static const List<BoxShadow> kCardShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 10,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontal = width < 400 ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: kBackground,
      bottomNavigationBar: const _BottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            _HeaderBar(
              onBack: () => Navigator.of(context).maybePop(),
              title: 'Emergency Services',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const _NeedHelpTitle(),
                    const SizedBox(height: 10),
                    _PrimaryAmbulanceButton(
                      label: 'Call Ambulance (108)',
                      subtitle: 'Estimated arrival: 15-20 minutes',
                      onTap: () => _callNumber('108'),
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(text: 'Local Hospitals'),
                    const SizedBox(height: 8),
                    _HospitalCard(
                      title: 'Rural Health Center',
                      phoneLabel: 'Emergency: 91-9876543210',
                      onCall: () => _callNumber('919876543210'),
                    ),
                    const SizedBox(height: 12),
                    _HospitalCard(
                      title: 'Community Clinic',
                      phoneLabel: 'Emergency: 91-8765432109',
                      onCall: () => _callNumber('918765432109'),
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(text: 'Emergency Contacts'),
                    const SizedBox(height: 8),
                    _ContactCard(
                      name: 'Rajesh Kumar',
                      relation: 'Family',
                      onCall: () => _callNumber('919812345678'),
                    ),
                    const SizedBox(height: 12),
                    _ContactCard(
                      name: 'Priya Sharma',
                      relation: 'Friend',
                      onCall: () => _callNumber('919876543210'),
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(text: 'Health Workers'),
                    const SizedBox(height: 8),
                    _HealthWorkerCard(
                      role: 'ASHA Worker',
                      subtitle: 'Contact for advice',
                      onCall: () => _callNumber('911234567890'),
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(text: 'Emergency Guidelines'),
                    const SizedBox(height: 8),
                    _GuidelineTile(
                      title: 'First Aid for Burns',
                      onTap:
                          () => _openGuideline(context, 'First Aid for Burns'),
                    ),
                    const SizedBox(height: 12),
                    _GuidelineTile(
                      title: 'CPR Instructions',
                      onTap: () => _openGuideline(context, 'CPR Instructions'),
                    ),
                    const SizedBox(height: 12),
                    _GuidelineTile(
                      title: 'Choking Relief',
                      onTap: () => _openGuideline(context, 'Choking Relief'),
                    ),
                    const SizedBox(height: 18),
                    _ShareLocationBar(onTap: () => _shareLocation(context)),
                    const SizedBox(height: 18 + 56), // space above bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _callNumber(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static void _openGuideline(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GuidelineDetailPage(title: title)),
    );
  }

  static Future<void> _shareLocation(BuildContext context) async {
    // Placeholder behavior: simulate GPS fetch and open a maps share link.
    // Replace with geolocator/share_plus as needed.
    const sampleLat = 28.6139;
    const sampleLng = 77.2090;
    final gmaps = Uri.parse('https://maps.google.com/?q=$sampleLat,$sampleLng');
    await launchUrl(gmaps, mode: LaunchMode.externalApplication);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location link opened for sharing.')),
      );
    }
  }
}

class _HeaderBar extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  const _HeaderBar({required this.onBack, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EmergencyServicesScreen.kBackground,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 6),
      child: Row(
        children: [
          _IconCircleButton(icon: Icons.arrow_back, onTap: onBack),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: EmergencyServicesScreen.kTextDark,
              ),
            ),
          ),
          const SizedBox(width: 44), // balance back button width
        ],
      ),
    );
  }
}

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: EmergencyServicesScreen.kTextDark),
        ),
      ),
    );
  }
}

class _NeedHelpTitle extends StatelessWidget {
  const _NeedHelpTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Need Help?',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: EmergencyServicesScreen.kTextDark,
        height: 1.2,
      ),
    );
  }
}

class _PrimaryAmbulanceButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _PrimaryAmbulanceButton({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: EmergencyServicesScreen.kPrimaryRed,
                borderRadius: BorderRadius.circular(24),
                boxShadow: EmergencyServicesScreen.kBigShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: EmergencyServicesScreen.kTextMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: EmergencyServicesScreen.kTextDark,
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final String title;
  final String phoneLabel;
  final VoidCallback onCall;
  const _HospitalCard({
    required this.title,
    required this.phoneLabel,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EmergencyServicesScreen.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmergencyServicesScreen.kBorder),
        boxShadow: EmergencyServicesScreen.kCardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: _TwoLineLabel(top: title, bottom: phoneLabel)),
          _PillCallButton(onTap: onCall),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String name;
  final String relation;
  final VoidCallback onCall;
  const _ContactCard({
    required this.name,
    required this.relation,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EmergencyServicesScreen.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmergencyServicesScreen.kBorder),
        boxShadow: EmergencyServicesScreen.kCardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _TwoLineLabel(top: name, bottom: 'Relationship: $relation'),
          ),
          _PillCallButton(onTap: onCall),
        ],
      ),
    );
  }
}

class _HealthWorkerCard extends StatelessWidget {
  final String role;
  final String subtitle;
  final VoidCallback onCall;
  const _HealthWorkerCard({
    required this.role,
    required this.subtitle,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EmergencyServicesScreen.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmergencyServicesScreen.kBorder),
        boxShadow: EmergencyServicesScreen.kCardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(child: _TwoLineLabel(top: role, bottom: subtitle)),
          _PillCallButton(onTap: onCall),
        ],
      ),
    );
  }
}

class _TwoLineLabel extends StatelessWidget {
  final String top;
  final String bottom;
  const _TwoLineLabel({required this.top, required this.bottom});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          top,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: EmergencyServicesScreen.kTextDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bottom,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: EmergencyServicesScreen.kTextMuted,
          ),
        ),
      ],
    );
  }
}

class _PillCallButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PillCallButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EmergencyServicesScreen.kPillRed.withOpacity(0.55),
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
          child: const Text(
            'Call',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: EmergencyServicesScreen.kPrimaryRedDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidelineTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _GuidelineTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EmergencyServicesScreen.kCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: EmergencyServicesScreen.kBorder),
            boxShadow: EmergencyServicesScreen.kCardShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: EmergencyServicesScreen.kTextDark,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: EmergencyServicesScreen.kTextMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareLocationBar extends StatelessWidget {
  final VoidCallback onTap;
  const _ShareLocationBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EmergencyServicesScreen.kSoftRed,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: EmergencyServicesScreen.kBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.location_on_rounded,
                color: EmergencyServicesScreen.kPrimaryRed,
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'Share Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: EmergencyServicesScreen.kPrimaryRed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          _BottomItem(
            icon: Icons.home_filled,
            label: 'Home',
            selected: true,
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.event_note_rounded,
            label: 'Appointments',
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            onTap: () {},
          ),
          _BottomItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _BottomItem({
    required this.icon,
    required this.label,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected
            ? EmergencyServicesScreen.kPrimaryRed
            : const Color(0xFF8E8E8E);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuidelineDetailPage extends StatelessWidget {
  final String title;
  const GuidelineDetailPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EmergencyServicesScreen.kBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: EmergencyServicesScreen.kBackground,
        foregroundColor: EmergencyServicesScreen.kTextDark,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: EmergencyServicesScreen.kTextDark,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _GuidelineBlock(
            heading: '$title - Overview',
            text:
                'This is a placeholder guideline page. Replace with real content, images, and step-by-step instructions as per medical guidance.',
          ),
          const SizedBox(height: 16),
          _GuidelineBlock(
            heading: 'Steps',
            text:
                '1) Assess safety.\n2) Call emergency services if required.\n3) Follow proper first aid procedures.\n4) Monitor until help arrives.',
          ),
          const SizedBox(height: 16),
          _GuidelineBlock(
            heading: 'Notes',
            text:
                'Information provided here is for demonstration only. Ensure professional validation before release.',
          ),
        ],
      ),
    );
  }
}

class _GuidelineBlock extends StatelessWidget {
  final String heading;
  final String text;
  const _GuidelineBlock({required this.heading, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EmergencyServicesScreen.kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: EmergencyServicesScreen.kBorder),
        boxShadow: EmergencyServicesScreen.kCardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: EmergencyServicesScreen.kTextDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: EmergencyServicesScreen.kTextMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
