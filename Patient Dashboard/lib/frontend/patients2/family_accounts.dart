import 'package:flutter/material.dart';

void main() {
  runApp(const FamilyHealthApp());
}

class FamilyHealthApp extends StatelessWidget {
  const FamilyHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Health Accounts',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F9F4),
      ),
      home: const FamilyHealthAccountsScreen(),
    );
  }
}

class FamilyHealthAccountsScreen extends StatelessWidget {
  const FamilyHealthAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SectionHeader(title: 'Family Members'),
          FamilyMemberCard(
            name: 'Priya Sharma',
            subtitle: 'Spouse, 35',
            avatar: 'assets/dummy_image.png',
            onTap: () {},
          ),
          FamilyMemberCard(
            name: 'Arjun Sharma',
            subtitle: 'Child, 8',
            avatar: 'assets/dummy_image.png',
            onTap: () {},
          ),
          FamilyMemberCard(
            name: 'Rajesh Sharma',
            subtitle: 'Parent, 65',
            avatar: 'assets/dummy_image.png',
            onTap: () {},
          ),
          const SectionHeader(title: 'Actions'),
          const ActionCard(
            icon: Icons.add,
            label: 'Add Family Member',
            color: Color(0xFFB6F3C0),
            textColor: Color(0xFF131516),
            onPressed: _onAddMember,
          ),
          const ActionCard(
            icon: Icons.remove,
            label: 'Remove Family Member',
            color: Color(0xFFB6F3C0),
            textColor: Color(0xFF131516),
            onPressed: _onRemoveMember,
          ),
          const SectionHeader(title: 'Settings'),
          const ActionCard(
            icon: Icons.shield_outlined,
            label: 'Permissions & Privacy',
            color: Color(0xFFB6F3C0),
            textColor: Color(0xFF131516),
            onPressed: _onPermissions,
          ),
          const SectionHeader(title: 'Emergency'),
          ActionCard(
            icon: Icons.phone,
            label: 'Emergency Contacts',
            color: Color(0xFFB6F3C0),
            textColor: Color(0xFF131516),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmergencyServicesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F9F4),
      elevation: 0,
      foregroundColor: Colors.black,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF131516),
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            splashRadius: 20,
          ),
          const Spacer(),
          const Text(
            'Family Health Accounts',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Color(0xFF131516),
              letterSpacing: 0.1,
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 22, top: 24, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: Color(0xFF161615),
        ),
      ),
    );
  }
}

class FamilyMemberCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatar;
  final VoidCallback? onTap;
  const FamilyMemberCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundImage: AssetImage(avatar),
                backgroundColor: Color(0xFFEFE1CF),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF161615),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color(0xFF656668),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF929394),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;
  const ActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Color(0xFF36B463), size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF929394),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEDEDED))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            CustomBottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: false,
            ),
            CustomBottomNavItem(
              icon: Icons.calendar_today,
              label: 'Appointments',
              active: false,
            ),
            CustomBottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: true,
            ),
            CustomBottomNavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              active: false,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const CustomBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Color(0xFF36B463);
    final Color inactiveColor = Color(0xFF94969A);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 26, color: active ? activeColor : inactiveColor),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: active ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class EmergencyServicesScreen extends StatelessWidget {
  const EmergencyServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmergencyAppBar(),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Need Help?',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Color(0xFF201E1E),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 32,
              height: 62,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Color(0xFFFF2222),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF2222).withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.white, size: 24),
                label: const Text(
                  'Call Ambulance (108)',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Estimated arrival: 15-20 minutes',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                fontSize: 15,
                color: Color(0xFFFF5A5A),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Local Hospitals'),
          const EmergencyHospitalCard(
            title: 'Rural Health Center',
            contact: '91-9876543210',
          ),
          const EmergencyHospitalCard(
            title: 'Community Clinic',
            contact: '91-8765432109',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Emergency Contacts'),
          const EmergencyContactCard(name: 'Rajesh Kumar', relation: 'Family'),
          const EmergencyContactCard(name: 'Priya Sharma', relation: 'Friend'),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Health Workers'),
          const EmergencyHealthWorkerCard(
            name: 'ASHA Worker',
            desc: 'Contact for advice',
          ),
          const SizedBox(height: 16),
          const SectionTitle(title: 'Emergency Guidelines'),
          const EmergencyGuidelineCard(title: 'First Aid for Burns'),
          const EmergencyGuidelineCard(title: 'CPR Instructions'),
          const EmergencyGuidelineCard(title: 'Choking Relief'),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 64,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Color(0xFFFFEBEB),
              ),
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF2222),
                  size: 22,
                ),
                label: const Text(
                  'Share Location',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFFFF2222),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
      bottomNavigationBar: const EmergencyBottomNavBar(),
    );
  }
}

class EmergencyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmergencyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: Colors.black,
      backgroundColor: Color(0xFFFDFBF8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF1E1E1E),
          size: 22,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        splashRadius: 18,
      ),
      title: const Text(
        'Emergency Services',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Color(0xFF201E1E),
          letterSpacing: 0.05,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 10, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Color(0xFF201E1E),
        ),
      ),
    );
  }
}

class EmergencyHospitalCard extends StatelessWidget {
  final String title;
  final String contact;
  const EmergencyHospitalCard({
    super.key,
    required this.title,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFDFBF8),
          border: Border.all(color: Color(0xFFFFCDD0), width: 1.3),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF201E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Emergency: $contact',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFFF5A5A),
                    ),
                  ),
                ],
              ),
            ),
            const EmergencyCallButton(),
          ],
        ),
      ),
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  final String name;
  final String relation;
  const EmergencyContactCard({
    super.key,
    required this.name,
    required this.relation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFDFBF8),
          border: Border.all(color: Color(0xFFFFCDD0), width: 1.3),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF201E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Relationship: $relation',
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFFF5A5A),
                    ),
                  ),
                ],
              ),
            ),
            const EmergencyCallButton(),
          ],
        ),
      ),
    );
  }
}

class EmergencyHealthWorkerCard extends StatelessWidget {
  final String name;
  final String desc;
  const EmergencyHealthWorkerCard({
    super.key,
    required this.name,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFDFBF8),
          border: Border.all(color: Color(0xFFFFCDD0), width: 1.3),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF201E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Color(0xFFFF5A5A),
                    ),
                  ),
                ],
              ),
            ),
            const EmergencyCallButton(),
          ],
        ),
      ),
    );
  }
}

class EmergencyGuidelineCard extends StatelessWidget {
  final String title;
  const EmergencyGuidelineCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFDFBF8),
          border: Border.all(color: Color(0xFFFFCDD0), width: 1.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF201E1E),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFFFF2222),
            size: 26,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 3,
          ),
          onTap: () {},
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class EmergencyCallButton extends StatelessWidget {
  const EmergencyCallButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 39,
      decoration: BoxDecoration(
        color: Color(0xFFFFEBEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
        ),
        child: const Text(
          'Call',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Color(0xFFFF2222),
            letterSpacing: 0.04,
          ),
        ),
      ),
    );
  }
}

class EmergencyBottomNavBar extends StatelessWidget {
  const EmergencyBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF3F5))),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            EmergencyBottomNavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: true,
            ),
            EmergencyBottomNavItem(
              icon: Icons.calendar_today,
              label: 'Appointments',
              active: false,
            ),
            EmergencyBottomNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: false,
            ),
            EmergencyBottomNavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              active: false,
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyBottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const EmergencyBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Color(0xFFFF2222);
    final Color inactiveColor = Color(0xFF8EA6AC);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: active ? activeColor : inactiveColor),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: active ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

// Callback placeholders
void _onAddMember() {}
void _onRemoveMember() {}
void _onPermissions() {}
