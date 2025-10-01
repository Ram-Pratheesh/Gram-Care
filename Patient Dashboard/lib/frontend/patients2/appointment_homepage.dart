import 'package:flutter/material.dart';

void main() {
  runApp(const AppointmentHomePage());
}

class AppointmentHomePage extends StatelessWidget {
  const AppointmentHomePage({Key? key}) : super(key: key);

  // Colors approximated from image
  static const Color headerText = Color(0xFF0D1F25);
  static const Color primaryBlue = Color(0xFF0FA3FF);
  static const Color tabActive = Color(0xFF0FA3FF);
  static const Color tabInactive = Color(0xFF6F8A94);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color pageBg = Color(0xFFF6F7F8);
  static const Color rescheduleBg = Color(0xFFDFF3FB);
  static const Color cancelBg = Color(0xFFF6D8D8);
  static const Color confirmedBadge = Color(0xFFE6F9E9);
  static const Color pendingBadge = Color(0xFFFFF4D6);
  static const Color lightDivider = Color(0xFFECEFF1);
  static const Color bottomNavBg = Color(0xFFFFFFFF);
  static const Color iconBlue = Color(0xFF0FA3FF);
  static const Color doctorName = Color(0xFF3B6E7C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Column(
          children: [
            HeaderBar(),
            const SizedBox(height: 6),
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Upcoming',
                              style: TextStyle(
                                color: tabActive,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          width: 70,
                          decoration: BoxDecoration(
                            color: tabActive,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Past',
                        style: TextStyle(
                          color: tabInactive,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                children: [
                  AppointmentCard(
                    date: '20 Jul 2024, 10:00\nAM',
                    doctor: 'Dr. Anjali Sharma',
                    statusText: 'Confirmed',
                    statusColor: confirmedBadge,
                    leftButtonText: 'Reschedule',
                    rightButtonText: 'Cancel',
                    leftButtonBg: rescheduleBg,
                    rightButtonBg: cancelBg,
                    iconColor: iconBlue,
                  ),
                  const SizedBox(height: 18),
                  AppointmentCard(
                    date: '25 Jul 2024, 02:30\nPM',
                    doctor: 'Dr. Rajesh Verma',
                    statusText: 'Pending',
                    statusColor: pendingBadge,
                    leftButtonText: 'Reschedule',
                    rightButtonText: 'Cancel',
                    leftButtonBg: rescheduleBg,
                    rightButtonBg: cancelBg,
                    iconColor: iconBlue,
                  ),
                  const SizedBox(height: 28),
                  // Book New Appointment CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/appointment');
                      },
                      child: const BookNewAppointmentButton(),
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

/// Top header bar with back arrow and title
class HeaderBar extends StatelessWidget {
  HeaderBar({Key? key}) : super(key: key);

  final double titleSize = 22;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 20, top: 18, bottom: 10),
      color: Colors.transparent,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 22,
              color: Color(0xFF0D1F25),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                'Appointments',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: AppointmentHomePage.headerText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Appointment card widget
class AppointmentCard extends StatelessWidget {
  final String date;
  final String doctor;
  final String statusText;
  final Color statusColor;
  final String leftButtonText;
  final String rightButtonText;
  final Color leftButtonBg;
  final Color rightButtonBg;
  final Color iconColor;

  const AppointmentCard({
    Key? key,
    required this.date,
    required this.doctor,
    required this.statusText,
    required this.statusColor,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.leftButtonBg,
    required this.rightButtonBg,
    required this.iconColor,
  }) : super(key: key);

  static const double cardRadius = 18.0;
  static const double innerPadding = 14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppointmentHomePage.cardBg,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6EDF0), width: 1.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(innerPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalendarIcon(iconColor: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppointmentHomePage.headerText,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppointmentHomePage.doctorName,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(text: statusText, color: statusColor),
              ],
            ),
          ),
          Container(height: 1, color: _dividerColor),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: ActionButton(
                    text: leftButtonText,
                    background: leftButtonBg,
                    textColor: AppointmentHomePage.iconBlue,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    text: rightButtonText,
                    background: rightButtonBg,
                    textColor: const Color(0xFFB33B3B),
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const Color _dividerColor = Color(0xFFEEF3F5);
}

class CalendarIcon extends StatelessWidget {
  final Color iconColor;
  const CalendarIcon({Key? key, required this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double size = 52;
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF8FF),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.calendar_today, color: iconColor, size: 20),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const StatusBadge({Key? key, required this.text, required this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EFEF)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _statusTextColor(text),
        ),
      ),
    );
  }

  Color _statusTextColor(String status) {
    if (status.toLowerCase().contains('confirm')) {
      return const Color(0xFF127D34);
    } else if (status.toLowerCase().contains('pend')) {
      return const Color(0xFF9A6F0B);
    }
    return const Color(0xFF334A52);
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  final double borderRadius;

  const ActionButton({
    Key? key,
    required this.text,
    required this.background,
    required this.textColor,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Color(0xFFE6EDF0)),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class BookNewAppointmentButton extends StatelessWidget {
  const BookNewAppointmentButton({Key? key}) : super(key: key);

  static const Color ctaBlue = Color(0xFF0FA3FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: ctaBlue,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: ctaBlue.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          const Text(
            'Book New Appointment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  BottomNavBar({Key? key}) : super(key: key);

  final double navHeight = 76;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: navHeight,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFEEF3F5))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 18.0,
          right: 18.0,
          top: 8,
          bottom: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            NavItem(icon: Icons.home_outlined, label: 'Home', active: false),
            NavItem(
              icon: Icons.calendar_today,
              label: 'Appointments',
              active: true,
            ),
            NavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              active: false,
            ),
            NavItem(
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

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = AppointmentHomePage.iconBlue;
    final Color inactiveColor = Color(0xFF8EA6AC);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: active ? activeColor : inactiveColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? activeColor : inactiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
