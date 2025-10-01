import 'package:flutter/material.dart';

void main() {
  runApp(const HealthRecordsApp(username: 'JohnDoe'));
}

class HealthRecordsApp extends StatelessWidget {
  final String username;
  const HealthRecordsApp({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    // You can use username in your widgets as needed
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Records',
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFF0FA3FF),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      home: HealthRecordsPage(username: username),
    );
  }
}

class HealthRecordsPage extends StatelessWidget {
  final String username;
  const HealthRecordsPage({super.key, required this.username});

  final List<Map<String, dynamic>> records = const [
    {
      "date": "2024-01-15",
      "title": "Medication for Fever",
      "doctor": "Dr. Sharma",
      "status": "cloud", // indicates downloaded icon
    },
    {
      "date": "2023-12-20",
      "title": "Antibiotics for Infection",
      "doctor": "Dr. Verma",
      "status": "sync", // indicates sync icon
    },
    {
      "date": "2023-11-05",
      "title": "Pain Relievers",
      "doctor": "Dr. Singh",
      "status": "cloud",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Health Records',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search records...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6F8A94)),
                filled: true,
                fillColor: const Color(0xFFF6F7F8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                TabItem(text: 'Prescriptions', active: true),
                TabItem(text: 'Lab Reports', active: false),
                TabItem(text: 'Doctor Notes', active: false),
                TabItem(text: 'Vaccinations', active: false),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HealthRecordCard(
                    date: record['date'],
                    title: record['title'],
                    doctor: record['doctor'],
                    status: record['status'],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class TabItem extends StatelessWidget {
  final String text;
  final bool active;
  const TabItem({super.key, required this.text, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? const Color(0xFF0FA3FF) : const Color(0xFF6F8A94),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF0FA3FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class HealthRecordCard extends StatelessWidget {
  final String date;
  final String title;
  final String doctor;
  final String status;

  const HealthRecordCard({
    super.key,
    required this.date,
    required this.title,
    required this.doctor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData statusIcon;
    Color statusColor;
    if (status == 'cloud') {
      statusIcon = Icons.cloud_done;
      statusColor = const Color(0xFF00C853);
    } else {
      statusIcon = Icons.sync;
      statusColor = const Color(0xFFFFC107);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6F8A94)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            doctor,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6F8A94)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.download,
                  size: 16,
                  color: Color(0xFF0FA3FF),
                ),
                label: const Text(
                  'Download',
                  style: TextStyle(
                    color: Color(0xFF0FA3FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  size: 16,
                  color: Color(0xFF0FA3FF),
                ),
                label: const Text(
                  'Share',
                  style: TextStyle(
                    color: Color(0xFF0FA3FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEFF8FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, color: statusColor, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF0FA3FF);
    final Color inactiveColor = const Color(0xFF8EA6AC);

    return Container(
      height: 76,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF3F5))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          BottomNavItem(icon: Icons.home_outlined, label: 'Home', active: true),
          BottomNavItem(
            icon: Icons.calendar_today,
            label: 'Appointments',
            active: false,
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            active: false,
          ),
          BottomNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            active: false,
          ),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFF0FA3FF);
    final Color inactiveColor = const Color(0xFF8EA6AC);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: active ? activeColor : inactiveColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: active ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}
