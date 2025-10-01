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
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PharmacySearchScreen(),
    );
  }
}

class PharmacySearchScreen extends StatelessWidget {
  const PharmacySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'GramCare',
          style: TextStyle(
            color: Colors.black,
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
              const SearchBarWidget(),
              const SizedBox(height: 24),
              const Text(
                'Recently Searched',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              const RecentSearchList(),
              const SizedBox(height: 24),
              const Text(
                'Nearby Pharmacies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              const NearbyPharmaciesList(),
              const SizedBox(height: 24),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              const FilterChips(),
              const SizedBox(height: 24),
              const NotificationButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF007BFF), // Approximate
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
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

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for medicines',
                hintStyle: TextStyle(color: Color(0xFFA5A5A5), fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecentSearchList extends StatelessWidget {
  const RecentSearchList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        RecentSearchItem(query: 'Paracetamol'),
        SizedBox(height: 16),
        RecentSearchItem(query: 'Amoxicillin'),
        SizedBox(height: 16),
        RecentSearchItem(query: 'Ibuprofen'),
      ],
    );
  }
}

class RecentSearchItem extends StatelessWidget {
  final String query;

  const RecentSearchItem({required this.query, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            query,
            style: const TextStyle(fontSize: 16, color: Color(0xFF555555)),
          ),
          const Icon(Icons.cancel_outlined, color: Color(0xFFA5A5A5)),
        ],
      ),
    );
  }
}

class NearbyPharmaciesList extends StatelessWidget {
  const NearbyPharmaciesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        PharmacyCard(
          name: 'Rural Pharmacy',
          distance: '1.2 km',
          status: 'Open until 8 PM',
          statusColor: Color(0xFF4CAF50),
        ),
        SizedBox(height: 16),
        PharmacyCard(
          name: 'Village Pharmacy',
          distance: '2.5 km',
          status: 'Open until 9 PM',
          statusColor: Color(0xFFFFA000),
        ),
        SizedBox(height: 16),
        PharmacyCard(
          name: 'Community Pharmacy',
          distance: '3.8 km',
          status: 'Closed',
          statusColor: Color(0xFFF44336),
        ),
      ],
    );
  }
}

class PharmacyCard extends StatelessWidget {
  final String name;
  final String distance;
  final String status;
  final Color statusColor;

  const PharmacyCard({
    required this.name,
    required this.distance,
    required this.status,
    required this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: const DecorationImage(
                image: AssetImage('assets/dummy_pharmacy_image.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$distance • $status',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        FilterChip(label: 'Distance'),
        SizedBox(width: 8),
        FilterChip(label: 'Verified'),
        SizedBox(width: 8),
        FilterChip(label: 'Open Now'),
      ],
    );
  }
}

class FilterChip extends StatelessWidget {
  final String label;

  const FilterChip({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
      ),
    );
  }
}

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F8FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB0D9FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.notifications_outlined, color: Color(0xFF007BFF)),
          SizedBox(width: 8),
          Text(
            'Subscribe to Notifications',
            style: TextStyle(
              color: Color(0xFF007BFF),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
