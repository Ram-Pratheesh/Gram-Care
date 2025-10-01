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
      title: 'Prescriptions',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PrescriptionsScreen(),
    );
  }
}

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

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
          'Prescriptions',
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
              const SizedBox(height: 16),
              const SearchBar(),
              const SizedBox(height: 16),
              const FilterDropdown(label: 'Filter by Doctor'),
              const SizedBox(height: 16),
              const DatePickerField(),
              const SizedBox(height: 24),
              const Text(
                'Recent Prescriptions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const RecentPrescriptionsList(),
              const SizedBox(height: 24),
              const Text(
                'Archived Prescriptions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                ),
              ),
              const SizedBox(height: 16),
              const ArchivedPrescriptionsList(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: 0,
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

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Search bar tapped');
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Search prescriptions...',
                  hintStyle: TextStyle(color: Color(0xFFA5A5A5), fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterDropdown extends StatelessWidget {
  final String label;

  const FilterDropdown({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Filter dropdown for $label tapped');
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class DatePickerField extends StatelessWidget {
  const DatePickerField({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Date picker tapped');
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'mm/dd/yyyy',
              style: TextStyle(fontSize: 16, color: Color(0xFFA5A5A5)),
            ),
            Icon(Icons.calendar_today_outlined, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class RecentPrescriptionsList extends StatelessWidget {
  const RecentPrescriptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RecentPrescriptionItem(date: '2024-01-15', doctor: 'Dr. Patel'),
        SizedBox(height: 12),
        RecentPrescriptionItem(date: '2023-12-20', doctor: 'Dr. Sharma'),
        SizedBox(height: 12),
        RecentPrescriptionItem(date: '2023-11-05', doctor: 'Dr. Verma'),
      ],
    );
  }
}

class RecentPrescriptionItem extends StatelessWidget {
  final String date;
  final String doctor;

  const RecentPrescriptionItem({
    required this.date,
    required this.doctor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Tapped on recent prescription from $doctor on $date');
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '℞',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

class ArchivedPrescriptionsList extends StatelessWidget {
  const ArchivedPrescriptionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ArchivedPrescriptionItem(date: '2023-09-10', doctor: 'Dr. Patel'),
        SizedBox(height: 12),
        ArchivedPrescriptionItem(date: '2023-08-15', doctor: 'Dr. Sharma'),
      ],
    );
  }
}

class ArchivedPrescriptionItem extends StatelessWidget {
  final String date;
  final String doctor;

  const ArchivedPrescriptionItem({
    required this.date,
    required this.doctor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Tapped on archived prescription from $doctor on $date');
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '℞',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doctor,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.download_for_offline_outlined,
                color: Color(0xFF909090),
                size: 24,
              ),
              onPressed: () {
                print(
                  'Download button pressed for prescription from $doctor on $date',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
