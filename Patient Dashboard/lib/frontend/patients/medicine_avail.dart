// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // ---------- Medicine Availability Page ----------
// class MedicineAvailabilityPage extends StatefulWidget {
//   final String username; // optional if needed for future enhancements
//   const MedicineAvailabilityPage({super.key, required this.username});

//   @override
//   State<MedicineAvailabilityPage> createState() =>
//       _MedicineAvailabilityPageState();
// }

// class _MedicineAvailabilityPageState extends State<MedicineAvailabilityPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> _medicines = [];
//   bool _loading = false;
//   String? _error;

//   static const String _apiBase = 'http://192.168.137.1:4001'; // backend IP

//   Future<void> _searchMedicines(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _medicines = [];
//         _error = null;
//       });
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final uri = Uri.parse('$_apiBase/api/medicine-search?q=$query');
//       final response = await http.get(uri);

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         setState(() {
//           _medicines = data;
//           _loading = false;
//         });
//       } else {
//         setState(() {
//           _error = 'Failed to load data (${response.statusCode})';
//           _medicines = [];
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _error = 'Network error';
//         _medicines = [];
//         _loading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Medicine Availability',
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
//         ),
//         backgroundColor: const Color(0xFFF6F7FB),
//         iconTheme: const IconThemeData(color: Colors.black87),
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Search Bar
//             TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search medicines...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   vertical: 0,
//                   horizontal: 16,
//                 ),
//               ),
//               onChanged: (value) {
//                 _searchMedicines(value.trim());
//               },
//             ),
//             const SizedBox(height: 16),

//             // Display results
//             _loading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _error != null
//                 ? Center(
//                   child: Text(
//                     _error!,
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 )
//                 : _medicines.isEmpty
//                 ? const Center(
//                   child: Text(
//                     'No medicines found',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 )
//                 : Expanded(
//                   child: ListView.separated(
//                     itemCount: _medicines.length,
//                     separatorBuilder: (_, __) => const SizedBox(height: 8),
//                     itemBuilder: (context, index) {
//                       final med = _medicines[index];
//                       return Card(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 2,
//                         child: ListTile(
//                           title: Text(
//                             med['itemName'] ?? 'Unknown',
//                             style: const TextStyle(fontWeight: FontWeight.w600),
//                           ),
//                           subtitle: Text(
//                             'Pharmacy: ${med['pharmacyName'] ?? '-'}\nLocation: ${med['location'] ?? '-'}',
//                           ),
//                           trailing: Text(
//                             'Qty: ${med['quantity'] ?? 0}',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                               color: Colors.blue,
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // ---------- Medicine Availability Page ----------
// class MedicineAvailabilityPage extends StatefulWidget {
//   final String username; // optional if needed for future enhancements
//   const MedicineAvailabilityPage({super.key, required this.username});

//   @override
//   State<MedicineAvailabilityPage> createState() =>
//       _MedicineAvailabilityPageState();
// }

// class _MedicineAvailabilityPageState extends State<MedicineAvailabilityPage> {
//   final TextEditingController _searchController = TextEditingController();
//   List<MedicineItem> _medicines = [];
//   bool _loading = false;
//   String? _error;
//   String _lastSearchQuery = '';

//   static const String _apiBase = 'http://192.168.137.1:4001'; // backend IP

//   @override
//   void initState() {
//     super.initState();
//     print('🔍 Medicine page initialized for user: ${widget.username}');
//     _testConnection();
//   }

//   // Test API connection
//   Future<void> _testConnection() async {
//     try {
//       final uri = Uri.parse('$_apiBase/health');
//       final response = await http.get(uri).timeout(const Duration(seconds: 5));
//       print('🔍 API Health check: ${response.statusCode}');
//       if (response.statusCode != 200) {
//         setState(() {
//           _error = 'API server not accessible';
//         });
//       }
//     } catch (e) {
//       print('❌ API connection failed: $e');
//       setState(() {
//         _error = 'Cannot connect to server. Please check your connection.';
//       });
//     }
//   }

//   Future<void> _searchMedicines(String query) async {
//     final trimmedQuery = query.trim();

//     if (trimmedQuery.isEmpty) {
//       setState(() {
//         _medicines = [];
//         _error = null;
//         _lastSearchQuery = '';
//       });
//       return;
//     }

//     // Avoid duplicate searches
//     if (trimmedQuery == _lastSearchQuery && !_loading) {
//       return;
//     }

//     _lastSearchQuery = trimmedQuery;

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       print('🔍 Searching for medicines: $trimmedQuery');

//       // URL encode the query to handle special characters
//       final encodedQuery = Uri.encodeQueryComponent(trimmedQuery);
//       final uri = Uri.parse('$_apiBase/api/medicine-search?q=$encodedQuery');

//       print('🔍 API URL: $uri');

//       final response = await http
//           .get(
//             uri,
//             headers: {
//               'Content-Type': 'application/json',
//               'Accept': 'application/json',
//             },
//           )
//           .timeout(const Duration(seconds: 10));

//       print('🔍 Response status: ${response.statusCode}');
//       print('🔍 Response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final dynamic responseData = jsonDecode(response.body);

//         if (responseData is List) {
//           final List<MedicineItem> medicines =
//               responseData
//                   .map(
//                     (item) =>
//                         MedicineItem.fromJson(item as Map<String, dynamic>),
//                   )
//                   .toList();

//           setState(() {
//             _medicines = medicines;
//             _loading = false;
//             _error = null;
//           });

//           print('✅ Found ${medicines.length} medicines');
//         } else {
//           setState(() {
//             _error = 'Invalid response format';
//             _medicines = [];
//             _loading = false;
//           });
//         }
//       } else if (response.statusCode == 400) {
//         setState(() {
//           _error = 'Invalid search query';
//           _medicines = [];
//           _loading = false;
//         });
//       } else if (response.statusCode == 503) {
//         setState(() {
//           _error = 'Database not ready. Please try again.';
//           _medicines = [];
//           _loading = false;
//         });
//       } else {
//         setState(() {
//           _error = 'Server error (${response.statusCode})';
//           _medicines = [];
//           _loading = false;
//         });
//       }
//     } catch (e) {
//       print('❌ Search error: $e');
//       setState(() {
//         _error = 'Network error: Unable to connect to server';
//         _medicines = [];
//         _loading = false;
//       });
//     }
//   }

//   void _clearSearch() {
//     _searchController.clear();
//     setState(() {
//       _medicines = [];
//       _error = null;
//       _lastSearchQuery = '';
//     });
//   }

//   void _showMedicineDetails(MedicineItem medicine) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(medicine.itemName),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _DetailRow('Pharmacy:', medicine.pharmacyName),
//                 _DetailRow('Location:', medicine.location),
//                 _DetailRow('Available Quantity:', medicine.quantity.toString()),
//                 if (medicine.quantity <= 5 && medicine.quantity > 0)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       '⚠️ Low stock available',
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 if (medicine.quantity == 0)
//                   const Padding(
//                     padding: EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       '❌ Out of stock',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Close'),
//               ),
//             ],
//           ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF6F7FB),
//       appBar: AppBar(
//         title: const Text(
//           'Medicine Availability',
//           style: TextStyle(
//             color: Colors.black87,
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: const Color(0xFFF6F7FB),
//         iconTheme: const IconThemeData(color: Colors.black87),
//         elevation: 0,
//         actions: [
//           if (_searchController.text.isNotEmpty)
//             IconButton(
//               onPressed: _clearSearch,
//               icon: const Icon(Icons.clear),
//               tooltip: 'Clear search',
//             ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Search Bar with enhanced styling
//             Container(
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 3,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: TextField(
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'Search medicines (e.g., Paracetamol, Aspirin)...',
//                   hintStyle: TextStyle(color: Colors.grey.shade500),
//                   prefixIcon: const Icon(Icons.search, color: Colors.blue),
//                   suffixIcon:
//                       _loading
//                           ? const Padding(
//                             padding: EdgeInsets.all(12.0),
//                             child: SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(strokeWidth: 2),
//                             ),
//                           )
//                           : _searchController.text.isNotEmpty
//                           ? IconButton(
//                             onPressed: _clearSearch,
//                             icon: const Icon(Icons.clear, color: Colors.grey),
//                           )
//                           : null,
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey.shade300),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: Colors.blue, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     vertical: 16,
//                     horizontal: 16,
//                   ),
//                 ),
//                 onChanged: (value) {
//                   // Debounce search to avoid too many API calls
//                   Future.delayed(const Duration(milliseconds: 300), () {
//                     if (value == _searchController.text) {
//                       _searchMedicines(value);
//                     }
//                   });
//                 },
//                 onSubmitted: (value) => _searchMedicines(value),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Search hint
//             if (_medicines.isEmpty && !_loading && _error == null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.info_outline, color: Colors.blue.shade700),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Enter medicine name to search for availability in nearby pharmacies',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 16),

//             // Results section
//             Expanded(child: _buildResultsSection()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildResultsSection() {
//     if (_loading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text('Searching for medicines...', style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
//             const SizedBox(height: 16),
//             Text(
//               _error!,
//               style: const TextStyle(color: Colors.red, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 setState(() => _error = null);
//                 if (_searchController.text.isNotEmpty) {
//                   _searchMedicines(_searchController.text);
//                 } else {
//                   _testConnection();
//                 }
//               },
//               icon: const Icon(Icons.refresh),
//               label: const Text('Retry'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_medicines.isEmpty) {
//       if (_searchController.text.isNotEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
//               const SizedBox(height: 16),
//               Text(
//                 'No medicines found for "${_searchController.text}"',
//                 style: const TextStyle(fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Try searching with a different name or check spelling',
//                 style: TextStyle(fontSize: 14, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         );
//       }
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(bottom: 12),
//           child: Text(
//             'Found ${_medicines.length} result${_medicines.length == 1 ? '' : 's'}',
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//         ),
//         Expanded(
//           child: ListView.separated(
//             itemCount: _medicines.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final medicine = _medicines[index];
//               return _MedicineCard(
//                 medicine: medicine,
//                 onTap: () => _showMedicineDetails(medicine),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Medicine item model
// class MedicineItem {
//   final String itemName;
//   final int quantity;
//   final String pharmacyName;
//   final String location;

//   MedicineItem({
//     required this.itemName,
//     required this.quantity,
//     required this.pharmacyName,
//     required this.location,
//   });

//   factory MedicineItem.fromJson(Map<String, dynamic> json) {
//     return MedicineItem(
//       itemName: json['itemName']?.toString() ?? 'Unknown Medicine',
//       quantity:
//           (json['quantity'] is int)
//               ? json['quantity']
//               : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
//       pharmacyName: json['pharmacyName']?.toString() ?? 'Unknown Pharmacy',
//       location: json['location']?.toString() ?? 'Location not specified',
//     );
//   }
// }

// // Medicine card widget
// class _MedicineCard extends StatelessWidget {
//   final MedicineItem medicine;
//   final VoidCallback onTap;

//   const _MedicineCard({required this.medicine, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     Color quantityColor;
//     String quantityStatus;

//     if (medicine.quantity == 0) {
//       quantityColor = Colors.red;
//       quantityStatus = 'Out of Stock';
//     } else if (medicine.quantity <= 5) {
//       quantityColor = Colors.orange;
//       quantityStatus = 'Low Stock';
//     } else {
//       quantityColor = Colors.green;
//       quantityStatus = 'In Stock';
//     }

//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 3,
//       shadowColor: Colors.grey.withOpacity(0.2),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           medicine.itemName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.store,
//                               size: 16,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 medicine.pharmacyName,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 2),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.location_on,
//                               size: 16,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 medicine.location,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: quantityColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(
//                             color: quantityColor.withOpacity(0.3),
//                           ),
//                         ),
//                         child: Text(
//                           quantityStatus,
//                           style: TextStyle(
//                             color: quantityColor,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Qty: ${medicine.quantity}',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w700,
//                           color: quantityColor,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Detail row widget for dialog
// class _DetailRow extends StatelessWidget {
//   final String label;
//   final String value;

//   const _DetailRow(this.label, this.value);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               label,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black54,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ---------- Medicine Availability Page ----------
class MedicineAvailabilityPage extends StatefulWidget {
  final String username; // optional if needed for future enhancements
  const MedicineAvailabilityPage({super.key, required this.username});

  @override
  State<MedicineAvailabilityPage> createState() =>
      _MedicineAvailabilityPageState();
}

class _MedicineAvailabilityPageState extends State<MedicineAvailabilityPage> {
  final TextEditingController _searchController = TextEditingController();
  List<MedicineItem> _medicines = [];
  bool _loading = false;
  String? _error;
  String _lastSearchQuery = '';

  static const String _apiBase = 'http://192.168.137.1:4001'; // backend IP

  @override
  void initState() {
    super.initState();
    print('🔍 Medicine page initialized for user: ${widget.username}');
    _testConnection();
  }

  // Test API connection
  Future<void> _testConnection() async {
    try {
      final uri = Uri.parse('$_apiBase/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      print('🔍 API Health check: ${response.statusCode}');
      if (response.statusCode != 200) {
        setState(() {
          _error = 'API server not accessible';
        });
      }
    } catch (e) {
      print('❌ API connection failed: $e');
      setState(() {
        _error = 'Cannot connect to server. Please check your connection.';
      });
    }
  }

  // Test debug endpoint to see database structure
  Future<void> _testDebugEndpoint() async {
    try {
      final uri = Uri.parse('$_apiBase/api/medicines/debug');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      print('🔍 Debug endpoint response: ${response.statusCode}');
      print('🔍 Debug data: ${response.body}');

      if (response.statusCode == 200) {
        final debugData = jsonDecode(response.body);
        _showDebugDialog(debugData);
      }
    } catch (e) {
      print('❌ Debug endpoint failed: $e');
    }
  }

  void _showDebugDialog(Map<String, dynamic> debugData) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Database Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collection: ${debugData['collectionName']}'),
                  Text('Total Documents: ${debugData['totalDocuments']}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Available Fields:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (debugData['availableFields'] != null)
                    ...List<String>.from(
                      debugData['availableFields'],
                    ).map((field) => Text('• $field')),
                  const SizedBox(height: 16),
                  const Text(
                    'Sample Data:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (debugData['sampleDocuments'] != null)
                    Text(
                      jsonEncode(debugData['sampleDocuments']),
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Future<void> _searchMedicines(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      setState(() {
        _medicines = [];
        _error = null;
        _lastSearchQuery = '';
      });
      return;
    }

    // Avoid duplicate searches
    if (trimmedQuery == _lastSearchQuery && !_loading) {
      return;
    }

    _lastSearchQuery = trimmedQuery;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      print('🔍 Searching for medicines: $trimmedQuery');

      // URL encode the query to handle special characters
      final encodedQuery = Uri.encodeQueryComponent(trimmedQuery);
      final uri = Uri.parse('$_apiBase/api/medicine-search?q=$encodedQuery');

      print('🔍 API URL: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is List) {
          final List<MedicineItem> medicines =
              responseData
                  .map(
                    (item) =>
                        MedicineItem.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();

          setState(() {
            _medicines = medicines;
            _loading = false;
            _error = null;
          });

          print('✅ Found ${medicines.length} medicines');
        } else {
          setState(() {
            _error = 'Invalid response format';
            _medicines = [];
            _loading = false;
          });
        }
      } else if (response.statusCode == 400) {
        setState(() {
          _error = 'Invalid search query';
          _medicines = [];
          _loading = false;
        });
      } else if (response.statusCode == 503) {
        setState(() {
          _error = 'Database not ready. Please try again.';
          _medicines = [];
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error (${response.statusCode})';
          _medicines = [];
          _loading = false;
        });
      }
    } catch (e) {
      print('❌ Search error: $e');
      setState(() {
        _error = 'Network error: Unable to connect to server';
        _medicines = [];
        _loading = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _medicines = [];
      _error = null;
      _lastSearchQuery = '';
    });
  }

  void _showMedicineDetails(MedicineItem medicine) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(medicine.itemName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow('Pharmacy:', medicine.pharmacyName),
                _DetailRow('Location:', medicine.location),
                _DetailRow('Available Quantity:', medicine.quantity.toString()),
                if (medicine.quantity <= 5 && medicine.quantity > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '⚠️ Low stock available',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (medicine.quantity == 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      '❌ Out of stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Medicine Availability',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFF6F7FB),
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        actions: [
          // Debug button (remove in production)
          IconButton(
            onPressed: _testDebugEndpoint,
            icon: const Icon(Icons.bug_report, color: Colors.blue),
            tooltip: 'Debug Database',
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              tooltip: 'Clear search',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar with enhanced styling
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search medicines (e.g., Paracetamol, Aspirin)...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  suffixIcon:
                      _loading
                          ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Icons.clear, color: Colors.grey),
                          )
                          : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                ),
                onChanged: (value) {
                  // Debounce search to avoid too many API calls
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (value == _searchController.text) {
                      _searchMedicines(value);
                    }
                  });
                },
                onSubmitted: (value) => _searchMedicines(value),
              ),
            ),
            const SizedBox(height: 20),

            // Connection status and helpful hints
            if (_medicines.isEmpty && !_loading && _error == null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Enter medicine name to search for availability in nearby pharmacies',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try searching: Paracetamol, Aspirin, Crocin, Dolo, etc.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Debug info panel
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'If no results appear, tap the debug button above to check database',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Results section
            Expanded(child: _buildResultsSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for medicines...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _error = null);
                    if (_searchController.text.isNotEmpty) {
                      _searchMedicines(_searchController.text);
                    } else {
                      _testConnection();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _testDebugEndpoint,
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Debug'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_medicines.isEmpty) {
      if (_searchController.text.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No medicines found for "${_searchController.text}"',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Try searching with a different name or check spelling',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _testDebugEndpoint,
                icon: const Icon(Icons.bug_report),
                label: const Text('Check Database Structure'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Found ${_medicines.length} result${_medicines.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _medicines.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final medicine = _medicines[index];
              return _MedicineCard(
                medicine: medicine,
                onTap: () => _showMedicineDetails(medicine),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Medicine item model
class MedicineItem {
  final String itemName;
  final int quantity;
  final String pharmacyName;
  final String location;

  MedicineItem({
    required this.itemName,
    required this.quantity,
    required this.pharmacyName,
    required this.location,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      itemName: json['itemName']?.toString() ?? 'Unknown Medicine',
      quantity:
          (json['quantity'] is int)
              ? json['quantity']
              : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      pharmacyName: json['pharmacyName']?.toString() ?? 'Unknown Pharmacy',
      location: json['location']?.toString() ?? 'Location not specified',
    );
  }
}

// Medicine card widget
class _MedicineCard extends StatelessWidget {
  final MedicineItem medicine;
  final VoidCallback onTap;

  const _MedicineCard({required this.medicine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color quantityColor;
    String quantityStatus;

    if (medicine.quantity == 0) {
      quantityColor = Colors.red;
      quantityStatus = 'Out of Stock';
    } else if (medicine.quantity <= 5) {
      quantityColor = Colors.orange;
      quantityStatus = 'Low Stock';
    } else {
      quantityColor = Colors.green;
      quantityStatus = 'In Stock';
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medicine.itemName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                medicine.pharmacyName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                medicine.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: quantityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: quantityColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          quantityStatus,
                          style: TextStyle(
                            color: quantityColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Qty: ${medicine.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: quantityColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detail row widget for dialog
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
