import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const HealthHubApp());

class HealthHubApp extends StatelessWidget {
  const HealthHubApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8F5EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7A4D),
          primary: const Color(0xFF0E7A4D),
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      home: const HealthHubScreen(),
    );
  }
}

class HealthHubScreen extends StatefulWidget {
  const HealthHubScreen({super.key});

  @override
  State<HealthHubScreen> createState() => _HealthHubScreenState();
}

class _HealthHubScreenState extends State<HealthHubScreen> {
  static const Color searchBarColor = Color(0xFFF1F3EE);
  static const Color tabSelectedBg = Color(0xFFE8F8E9);
  static const Color tabSelectedText = Color(0xFF209343);
  static const Color tabUnselectedBg = Color(0xFFF8F8F7);
  static const Color tabUnselectedText = Color(0xFF6B7A6B);
  static const Color catTitle = Color(0xFF222222);

  int selectedTab = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  final List<_Category> _allCategories = const [
    _Category(title: "Nutrition", icon: Icons.local_dining),
    _Category(title: "Environment Health Shield", icon: Icons.child_care),
    _Category(title: "Mental Wellness", icon: Icons.psychology),
    _Category(title: "Physical Activity", icon: Icons.fitness_center),
    _Category(title: "Sexual and Reproductive Health", icon: Icons.water),
  ];

  List<_Category> get _filteredCategories {
    if (_searchText.isEmpty) return _allCategories;
    return _allCategories
        .where((c) => c.title.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _clearSearch() {
    _searchController.clear();
    _searchText = '';
    setState(() {});
  }

  void _updateSearch(String val) {
    setState(() {
      _searchText = val;
    });
  }

  void _openAssetVideo(String assetPath, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AssetVideoScreen(assetPath: assetPath, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "Health Hub",
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
          onPressed: () => _showMsg("Back tapped"),
        ),
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: searchBarColor,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        size: 24,
                        color: Color(0xFFA2AFA2),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _updateSearch,
                          cursorHeight: 22,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search for health topics...",
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: 'Inter',
                              color: Color(0xFFA2AFA2),
                            ),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            fontFamily: 'Inter',
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (_searchText.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFFA2AFA2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemCount: 4,
                    itemBuilder: (_, idx) {
                      final labels = [
                        "Filters",
                        "Nutrition",
                        "Sanitation",
                        "Maternal Health",
                      ];
                      final icons = [
                        Icons.filter_alt_outlined,
                        null,
                        null,
                        null,
                      ];
                      final selected = selectedTab == idx;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedTab = idx);
                          _showMsg("${labels[idx]} tapped");
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 22,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            color: selected ? tabSelectedBg : tabUnselectedBg,
                            border: Border.all(
                              color:
                                  selected
                                      ? Colors.transparent
                                      : const Color(0xFFC8D1BD),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icons[idx] != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 11),
                                  child: Icon(
                                    icons[idx],
                                    size: 21,
                                    color:
                                        selected
                                            ? tabSelectedText
                                            : const Color(0xFF6F8577),
                                  ),
                                ),
                              Text(
                                labels[idx],
                                style: TextStyle(
                                  fontWeight:
                                      selected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                  fontSize: 13,
                                  color:
                                      selected
                                          ? tabSelectedText
                                          : const Color(0xFF6F8577),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Featured
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 22, 0, 15),
                child: Text(
                  "Featured",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF2F2E2C),
                  ),
                ),
              ),
              SizedBox(
                height: 164,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, right: 14),
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final titles = ["The Three Giants", "Winning the unseen"];
                    final labels = ["Video • 5 min", "Article • 7 min"];
                    final colors1 = [
                      const Color(0xFF265E3F),
                      const Color(0xFFC7B943),
                    ];
                    final colors2 = [
                      const Color(0xFF1C3D2A),
                      const Color(0xFF9E942C),
                    ];
                    final icons = [Icons.cloud, Icons.child_friendly];

                    return _FeaturedCard(
                      width: 280,
                      color1: colors1[index],
                      color2: colors2[index],
                      icon: icons[index],
                      title: titles[index],
                      label: labels[index],
                      onTap: () {
                        // Keep behavior; example: open Nutrition video from featured “Child Nutrition”
                        if (titles[index] == "Winning the unseen") {
                          _openAssetVideo(
                            'assets/Winning_the_Unseen_War.mp4',
                            'Winning the Unseen',
                          );
                        } else if (titles[index] == "The Three Giants") {
                          _openAssetVideo(
                            'assets/The_Three_Giants.mp4',
                            'The Three Giants',
                          );
                        } else {
                          _showMsg("${titles[index]} card tapped");
                        }
                      },
                    );
                  },
                ),
              ),

              // All Categories
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 28, 0, 18),
                child: Text(
                  "All Categories",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF2F2E2C),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _filteredCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final cat = _filteredCategories[index];
                    return _CategoryCard(
                      title: cat.title,
                      icon: cat.icon,
                      onTap: () {
                        // Route to specific videos without changing UI
                        switch (cat.title) {
                          case "Nutrition":
                            _openAssetVideo(
                              'assets/Nutrition_&_Healthy_Eating.mp4',
                              'Nutrition & Healthy Eating',
                            );
                            break;
                          case "Mental Wellness":
                            _openAssetVideo(
                              'assets/Mastering_Mental_Wellness.mp4',
                              'Mastering Mental Wellness',
                            );
                            break;
                          case "Physical Activity":
                            _openAssetVideo(
                              'assets/Power_Of_Physical_Activity.mp4',
                              'Power of Physical Activity',
                            );
                            break;
                          case "Sexual and Reproductive Awareness":
                            _openAssetVideo(
                              'assets/Sexual_&_Reproductive_Health.mp4',
                              'Sexual and Reproductive Awareness',
                            );
                            break;
                          case "Environment Health Shield":
                            _openAssetVideo(
                              'assets/Environmental_Health_Shield.mp4',
                              'Environment Health Shield',
                            );
                            break;
                          default:
                            _showMsg("${cat.title} tapped");
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _Category {
  final String title;
  final IconData icon;
  const _Category({required this.title, required this.icon});
}

class _FeaturedCard extends StatelessWidget {
  final double width;
  final Color color1;
  final Color color2;
  final IconData icon;
  final String title;
  final String label;
  final GestureTapCallback onTap;
  const _FeaturedCard({
    Key? key,
    required this.width,
    required this.color1,
    required this.color2,
    required this.icon,
    required this.title,
    required this.label,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 80, color: Colors.white24)),
              Positioned(
                left: 20,
                bottom: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 11,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final GestureTapCallback onTap;
  const _CategoryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: const Color(0xFFC9D1C1),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 56, color: Colors.white54),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 5,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color(0xFF209243);
    final unselectedColor = const Color(0xFFA5B292);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavIcon(
              icon: Icons.home_filled,
              text: "Home",
              selected: true,
              color: selectedColor,
              onTap:
                  () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Home tapped'))),
            ),
            _NavIcon(
              icon: Icons.calendar_today,
              text: "Bookings",
              selected: false,
              color: unselectedColor,
              onTap:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bookings tapped')),
                  ),
            ),
            _NavIcon(
              icon: Icons.person,
              text: "Profile",
              selected: false,
              color: unselectedColor,
              onTap:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile tapped')),
                  ),
            ),
            _NavIcon(
              icon: Icons.settings,
              text: "Settings",
              selected: false,
              color: unselectedColor,
              onTap:
                  () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings tapped')),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _NavIcon({
    required this.icon,
    required this.text,
    required this.color,
    this.selected = false,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Generic asset video player screen (reusable for all three videos)
class AssetVideoScreen extends StatefulWidget {
  final String assetPath;
  final String title;
  const AssetVideoScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<AssetVideoScreen> createState() => _AssetVideoScreenState();
}

class _AssetVideoScreenState extends State<AssetVideoScreen> {
  late VideoPlayerController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
      ..initialize()
          .then((_) {
            setState(() {});
            _controller.play();
          })
          .catchError((e) {
            setState(() => _error = e.toString());
          });
    _controller.setLooping(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBody() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Failed to load video:\n$_error\n\nCheck pubspec.yaml path and codecs.',
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0E7A4D),
      ),
      body: Center(child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0E7A4D),
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
        onPressed: () {
          if (!_controller.value.isInitialized) return;
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
      ),
    );
  }
}
