import 'package:flutter/material.dart';
import 'package:gramcare/docprescribe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientSelectApp extends StatelessWidget {
  final String jwtToken;
  const PatientSelectApp({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Selection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        useMaterial3: false,
      ),
      home: PatientSelectionScreen(jwtToken: jwtToken),
    );
  }
}

class Patient {
  final String name;
  final String id;

  const Patient({required this.name, required this.id});

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(name: json['name'] ?? '', id: json['id'] ?? '');
  }
}

class PatientApiResponse {
  final bool success;
  final List<Patient> patients;
  final Map<String, dynamic>? pagination;

  const PatientApiResponse({
    required this.success,
    required this.patients,
    this.pagination,
  });

  factory PatientApiResponse.fromJson(Map<String, dynamic> json) {
    final patientsList =
        (json['patients'] as List<dynamic>? ?? [])
            .map(
              (patientJson) =>
                  Patient.fromJson(patientJson as Map<String, dynamic>),
            )
            .toList();

    return PatientApiResponse(
      success: json['success'] ?? false,
      patients: patientsList,
      pagination: json['pagination'] as Map<String, dynamic>?,
    );
  }
}

class PatientService {
  static const String baseUrl = 'http://172.16.58.254:4000'; // Your server URL

  // You'll need to store the JWT token after doctor login
  // This is a simple example - in production, use secure storage
  static String? _authToken;

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static Future<PatientApiResponse> getPatients({
    String? search,
    String? filter,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (filter != null && filter.isNotEmpty && filter != 'Recent') {
        queryParams['filter'] = filter.toLowerCase();
      }

      final uri = Uri.parse(
        '$baseUrl/api/doctor/patients',
      ).replace(queryParameters: queryParams);

      final headers = <String, String>{'Content-Type': 'application/json'};

      // Add authorization header if token exists
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PatientApiResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Failed to fetch patients');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

class PatientSelectionScreen extends StatefulWidget {
  const PatientSelectionScreen({super.key, required String jwtToken});

  @override
  State<PatientSelectionScreen> createState() => _PatientSelectionScreenState();
}

class _PatientSelectionScreenState extends State<PatientSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedFilter = 'Recent';

  List<Patient> patients = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;

  int currentPage = 1;
  bool hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPatients();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Add search debouncing
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePatients();
    }
  }

  void _onSearchChanged() {
    // Simple debouncing - wait 500ms after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _resetAndLoadPatients();
      }
    });
  }

  Future<void> _loadPatients() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await PatientService.getPatients(
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        filter: selectedFilter,
        page: 1,
      );

      if (mounted) {
        setState(() {
          patients = response.patients;
          currentPage = 1;
          hasMore = response.pagination?['hasMore'] ?? false;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadMorePatients() async {
    if (isLoadingMore || !hasMore) return;

    try {
      setState(() {
        isLoadingMore = true;
      });

      final response = await PatientService.getPatients(
        search:
            _searchController.text.isNotEmpty ? _searchController.text : null,
        filter: selectedFilter,
        page: currentPage + 1,
      );

      if (mounted) {
        setState(() {
          patients.addAll(response.patients);
          currentPage += 1;
          hasMore = response.pagination?['hasMore'] ?? false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMore = false;
        });
        _showErrorSnackbar('Failed to load more patients: $e');
      }
    }
  }

  Future<void> _resetAndLoadPatients() async {
    currentPage = 1;
    hasMore = true;
    await _loadPatients();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadPatients,
        ),
      ),
    );
  }

  void _navigateToPrescription(Patient patient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrescribeApp(selectedPatient: patient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Select Patient',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF0F172A)),
            onPressed: _loadPatients,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F172A),
                ),
                decoration: const InputDecoration(
                  hintText: 'Search by name or ID',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A94A6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF8A94A6),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                FilterTab(
                  text: 'Recent',
                  isSelected: selectedFilter == 'Recent',
                  onTap: () {
                    setState(() => selectedFilter = 'Recent');
                    _resetAndLoadPatients();
                  },
                ),
                const SizedBox(width: 24),
                FilterTab(
                  text: 'Active',
                  isSelected: selectedFilter == 'Active',
                  onTap: () {
                    setState(() => selectedFilter = 'Active');
                    _resetAndLoadPatients();
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Container(color: Colors.white, child: _buildContent()),
          ),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BottomNavItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              isSelected: false,
              onTap: () {},
            ),
            BottomNavItem(
              icon: Icons.people_outline,
              label: 'Patients',
              isSelected: true,
              onTap: () {},
            ),
            BottomNavItem(
              icon: Icons.chat_bubble_outline,
              label: 'Messages',
              isSelected: false,
              onTap: () {},
            ),
            BottomNavItem(
              icon: Icons.calendar_today_outlined,
              label: 'Schedule',
              isSelected: false,
              onTap: () {},
            ),
            BottomNavItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isSelected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading && patients.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0F172A)),
      );
    }

    if (errorMessage != null && patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF8A94A6)),
            const SizedBox(height: 16),
            Text(
              'Failed to load patients',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF8A94A6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPatients,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (patients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF8A94A6)),
            SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(fontSize: 14, color: Color(0xFF8A94A6)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: patients.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == patients.length) {
          // Loading indicator at the bottom
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF0F172A)),
            ),
          );
        }

        final patient = patients[index];
        return PatientListItem(
          patient: patient,
          onTap: () => _navigateToPrescription(patient),
        );
      },
    );
  }
}

// Rest of your existing widgets remain the same...
class FilterTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterTab({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF8A94A6),
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              width: 24,
              height: 2,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}

class PatientListItem extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientListItem({
    super.key,
    required this.patient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E40FF),
              ),
              child: Center(
                child: Text(
                  patient.name.isNotEmpty
                      ? patient.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Patient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${patient.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8A94A6),
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF8A94A6),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color:
                isSelected ? const Color(0xFF0F172A) : const Color(0xFF8A94A6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color:
                  isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF8A94A6),
            ),
          ),
        ],
      ),
    );
  }
}
