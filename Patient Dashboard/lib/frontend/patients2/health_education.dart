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
      title: 'Health Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HealthHubScreen(),
    );
  }
}

class HealthHubScreen extends StatelessWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Health Hub',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const SearchBarWidget(),
              const SizedBox(height: 16),
              const CategoryTabs(),
              const SizedBox(height: 24),
              const Text(
                'Featured',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const FeaturedSection(),
              const SizedBox(height: 24),
              const Text(
                'All Categories',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const AllCategoriesGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF32AE4B),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Bookings',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for health topics...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const FilterTab(),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Nutrition',
            isSelected: true,
            color: const Color(0xFFE4F4E4),
            textColor: const Color(0xFF32AE4B),
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Sanitation',
            isSelected: false,
            color: Colors.white,
            textColor: Colors.black,
          ),
          const SizedBox(width: 8),
          CategoryChip(
            label: 'Maternal Health',
            isSelected: false,
            color: Colors.white,
            textColor: Colors.black,
          ),
        ],
      ),
    );
  }
}

class FilterTab extends StatelessWidget {
  const FilterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.filter_list, color: Colors.black, size: 20),
          SizedBox(width: 4),
          Text(
            'Filters',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final Color textColor;

  const CategoryChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF32AE4B) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

class FeaturedSection extends StatelessWidget {
  const FeaturedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const FeaturedCard(
            imagePath: 'assets/dummy_image.png',
            title: 'Monsoon Health Tips',
            subtitle: 'Video • 5 min',
            cardColor: Color(0xFF32AE4B),
          ),
          const SizedBox(width: 16),
          const FeaturedCard(
            imagePath: 'assets/dummy_image2.png',
            title: 'Child Nutrition',
            subtitle: 'Article • 7 min',
            cardColor: Color(0xFF32AE4B), // Approximate, needs to be replaced
          ),
        ],
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final Color cardColor;

  const FeaturedCard({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.cardColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Approximate width based on visual
      height: 150, // Approximate height
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath), // Placeholder image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            cardColor.withOpacity(0.5), // Apply a tint
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AllCategoriesGrid extends StatelessWidget {
  const AllCategoriesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        CategoryTile(
          imagePath: 'assets/nutrition_bg.png',
          title: 'Nutrition',
          color: Color(0xFF32AE4B),
        ),
        CategoryTile(
          imagePath: 'assets/sanitation_bg.png',
          title: 'Sanitation',
          color: Color(0xFF6B92B0), // Approximate
        ),
        CategoryTile(
          imagePath: 'assets/immunization_bg.png',
          title: 'Immunization',
          color: Color(0xFF9F835F), // Approximate
        ),
        CategoryTile(
          imagePath: 'assets/maternal_health_bg.png',
          title: 'Maternal Health',
          color: Color(0xFF906979), // Approximate
        ),
        CategoryTile(
          imagePath: 'assets/child_care_bg.png',
          title: 'Child Care',
          color: Color(0xFF81B0CF), // Approximate
        ),
        CategoryTile(
          imagePath: 'assets/seasonal_diseases_bg.png',
          title: 'Seasonal Diseases',
          color: Color(0xFF8D8D8D), // Approximate
        ),
      ],
    );
  }
}

class CategoryTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final Color color;

  const CategoryTile({
    required this.imagePath,
    required this.title,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Placeholder background
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: AssetImage(imagePath), // Placeholder image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
