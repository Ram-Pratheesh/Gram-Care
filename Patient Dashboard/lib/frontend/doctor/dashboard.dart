// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// const String apiBase = 'http://192.168.137.1:4001'; // adjust if needed

// class DoctorDashboardApp extends StatelessWidget {
//   final String jwtToken;
//   const DoctorDashboardApp({super.key, required this.jwtToken});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Doctor Dashboard',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFF7F8FB),
//         fontFamily: 'Inter',
//         useMaterial3: false,
//       ),
//       home: DoctorDashboardScreen(jwtToken: jwtToken),
//     );
//   }
// }

// class DoctorDashboardScreen extends StatefulWidget {
//   final String jwtToken;
//   const DoctorDashboardScreen({super.key, required this.jwtToken});

//   @override
//   State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
// }

// class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
//   int _navIndex = 0;
//   final TextEditingController _searchCtrl = TextEditingController();

//   String? doctorName;
//   String? doctorEmail;
//   bool _loadingProfile = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadDoctorProfile();
//   }

//   Future<void> _loadDoctorProfile() async {
//     try {
//       final uri = Uri.parse('$apiBase/api/doctor/me');
//       final headers = <String, String>{
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.jwtToken}',
//       };

//       final resp = await http.get(uri, headers: headers);

//       if (resp.statusCode == 200) {
//         final map = jsonDecode(resp.body) as Map<String, dynamic>;
//         setState(() {
//           doctorName = (map['fullName'] ?? '').toString().trim();
//           doctorEmail = (map['email'] ?? '').toString().trim();
//           _loadingProfile = false;
//         });
//       } else if (resp.statusCode == 401) {
//         setState(() {
//           doctorName = 'Doctor';
//           _loadingProfile = false;
//         });
//       } else {
//         setState(() {
//           doctorName = 'Doctor';
//           _loadingProfile = false;
//         });
//       }
//     } catch (_) {
//       setState(() {
//         doctorName = 'Doctor';
//         _loadingProfile = false;
//       });
//     }
//   }

//   void _snack(String msg) {
//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: const Color(0xFF2563EB),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final headerName =
//         _loadingProfile
//             ? 'Loading...'
//             : (doctorName == null || doctorName!.isEmpty
//                 ? 'Doctor'
//                 : doctorName!);

//     return Scaffold(
//       appBar: _HeaderBar(
//         onBellTap: () => _snack('Opening notifications'),
//         displayName: headerName,
//       ),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 6),
//                   SearchBarInteractive(
//                     controller: _searchCtrl,
//                     onSubmit: (v) => _snack('Searching: $v'),
//                     onTap: () => _snack('Search tapped'),
//                     onClear: () {
//                       _searchCtrl.clear();
//                       setState(() {});
//                       _snack('Search cleared');
//                     },
//                   ),
//                   const SizedBox(height: 14),
//                   const AlertsCard(),
//                   const SizedBox(height: 16),
//                   const _SectionTitle('Quick Actions'),
//                   const SizedBox(height: 10),
//                   QuickActionsGrid(onTap: (label) => _snack(label)),
//                   const SizedBox(height: 16),
//                   const _SectionTitle('Snapshot / Insights'),
//                   const SizedBox(height: 10),
//                   const SnapshotGrid(),
//                   const SizedBox(height: 18),
//                   const _SectionTitle('Upcoming Appointments'),
//                   const SizedBox(height: 10),
//                   AppointmentCard(
//                     name: 'Rohan Verma',
//                     subtitle: 'Follow-up',
//                     time: '10:30 AM',
//                     statusText: 'Confirmed',
//                     statusColor: const Color(0xFF34D399),
//                     onTap: () => _snack('Rohan Verma'),
//                     onDetails: () => _snack('View Details: Rohan Verma'),
//                   ),
//                   const SizedBox(height: 10),
//                   AppointmentCard(
//                     name: 'Priya Singh',
//                     subtitle: 'New Consultation',
//                     time: '11:00 AM',
//                     statusText: 'Pending',
//                     statusColor: const Color(0xFFF59E0B),
//                     onTap: () => _snack('Priya Singh'),
//                     onDetails: () => _snack('View Details: Priya Singh'),
//                   ),
//                   const SizedBox(height: 18),
//                   const _SectionTitle('Patient Health Worker Notes'),
//                   const SizedBox(height: 10),
//                   ASHANoteCardButton(
//                     onTap: () => _snack('Opening latest vitals'),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _BottomNav(
//         index: _navIndex,
//         onTap: (i, label) {
//           setState(() => _navIndex = i);
//           _snack('Nav: $label');
//         },
//       ),
//     );
//   }
// }

// class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
//   final VoidCallback onBellTap;
//   final String displayName;
//   const _HeaderBar({
//     super.key,
//     required this.onBellTap,
//     required this.displayName,
//   });
//   @override
//   Size get preferredSize => const Size.fromHeight(64);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: const Color(0xFFF7F8FB),
//       elevation: 0,
//       titleSpacing: 0,
//       title: Padding(
//         padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
//         child: Row(
//           children: [
//             const CircleAvatar(
//               radius: 18,
//               backgroundColor: Color(0xFFFFE7D6),
//               backgroundImage: AssetImage('dummy_image.png'),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     displayName,
//                     style: const TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF0D1B2A),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: const [
//                       Icon(Icons.circle, size: 8, color: Color(0xFF34D399)),
//                       SizedBox(width: 6),
//                       Text(
//                         'Online',
//                         style: TextStyle(
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF10B981),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 IconButton(
//                   onPressed: onBellTap,
//                   icon: const Icon(
//                     Icons.notifications_outlined,
//                     color: Color(0xFF4B5563),
//                   ),
//                   tooltip: 'Notifications',
//                 ),
//                 const Positioned(
//                   right: 8,
//                   top: 8,
//                   child: CircleAvatar(
//                     radius: 4,
//                     backgroundColor: Color(0xFFEF4444),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 4),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* ============== Interactive Search ============== */

// class SearchBarInteractive extends StatelessWidget {
//   final TextEditingController controller;
//   final ValueChanged<String> onSubmit;
//   final VoidCallback onTap;
//   final VoidCallback onClear;

//   const SearchBarInteractive({
//     super.key,
//     required this.controller,
//     required this.onSubmit,
//     required this.onTap,
//     required this.onClear,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           height: 46,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE6EAF0)),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: Row(
//             children: [
//               const Icon(Icons.search, color: Color(0xFF7B8794)),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   onSubmitted: onSubmit,
//                   style: const TextStyle(
//                     fontSize: 14.5,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF0F172A),
//                   ),
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     isCollapsed: true,
//                     hintText: 'Search patients, reports...',
//                     hintStyle: TextStyle(
//                       fontSize: 14.5,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF9AA3AF),
//                     ),
//                   ),
//                   textInputAction: TextInputAction.search,
//                 ),
//               ),
//               if (controller.text.isNotEmpty)
//                 IconButton(
//                   onPressed: onClear,
//                   icon: const Icon(
//                     Icons.close,
//                     color: Color(0xFF9AA3AF),
//                     size: 18,
//                   ),
//                   splashRadius: 18,
//                   tooltip: 'Clear',
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ============== Alerts ============== */

// class AlertsCard extends StatelessWidget {
//   const AlertsCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFEFEF),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFFBD5D5)),
//       ),
//       padding: const EdgeInsets.all(12),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: const [
//                 _AlertLine(
//                   bold: 'Medicine Shortage:',
//                   rest: ' Paracetamol stock is critically low.',
//                 ),
//                 SizedBox(height: 8),
//                 _AlertLine(
//                   bold: 'Emergency:',
//                   rest:
//                       ' New trauma case admitted. Immediate attention required.',
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             width: 22,
//             height: 22,
//             decoration: const BoxDecoration(
//               color: Color(0xFFFCA5A5),
//               shape: BoxShape.circle,
//             ),
//             alignment: Alignment.center,
//             child: const Text(
//               '2',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AlertLine extends StatelessWidget {
//   final String bold;
//   final String rest;
//   const _AlertLine({super.key, required this.bold, required this.rest});

//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: bold,
//             style: const TextStyle(
//               fontSize: 13.5,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF991B1B),
//             ),
//           ),
//           TextSpan(
//             text: rest,
//             style: const TextStyle(
//               fontSize: 13.5,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF7F1D1D),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* ============== Quick Actions ============== */

// class QuickActionsGrid extends StatelessWidget {
//   final void Function(String) onTap;
//   const QuickActionsGrid({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final tiles = [
//       _QAData('Start Consultation', Icons.smart_display_outlined),
//       _QAData('Prescribe', Icons.edit_note_outlined),
//       _QAData('Order Tests', Icons.science_outlined),
//       _QAData('Patient List', Icons.group_outlined),
//     ];
//     return GridView.builder(
//       shrinkWrap: true,
//       itemCount: tiles.length,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisExtent: 96,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//       ),
//       itemBuilder: (context, i) {
//         final t = tiles[i];
//         return Material(
//           color: const Color(0xFFEFF6FF),
//           borderRadius: BorderRadius.circular(12),
//           child: InkWell(
//             onTap: () => onTap(t.label),
//             borderRadius: BorderRadius.circular(12),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: const Color(0xFFEFF6FF),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(14),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(t.icon, color: const Color(0xFF2F80ED), size: 26),
//                   const SizedBox(height: 8),
//                   Text(
//                     t.label,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF1F2A37),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class _QAData {
//   final String label;
//   final IconData icon;
//   _QAData(this.label, this.icon);
// }

// /* ============== Snapshot Grid ============== */

// class SnapshotGrid extends StatelessWidget {
//   const SnapshotGrid({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = const [
//       _SnapshotItem('Total Patients', '324', accent: Color(0xFF111827)),
//       _SnapshotItem('Open Cases', '15', accent: Color(0xFF111827)),
//       _SnapshotItem('Reports to Review', '8', accent: Color(0xFFF59E0B)),
//       _SnapshotItem('Avg. Consult Time', '12m', accent: Color(0xFF111827)),
//     ];
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: items.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         mainAxisExtent: 84,
//       ),
//       itemBuilder: (context, i) {
//         final it = items[i];
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xFFE6EAF0)),
//           ),
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 it.title,
//                 style: const TextStyle(
//                   fontSize: 12.5,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF6B7280),
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 it.value,
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w800,
//                   color: it.accent,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// class _SnapshotItem {
//   final String title;
//   final String value;
//   final Color accent;
//   const _SnapshotItem(this.title, this.value, {required this.accent});
// }

// /* ============== Appointments ============== */

// class AppointmentCard extends StatelessWidget {
//   final String name;
//   final String subtitle;
//   final String time;
//   final String statusText;
//   final Color statusColor;
//   final VoidCallback onTap;
//   final VoidCallback onDetails;

//   const AppointmentCard({
//     super.key,
//     required this.name,
//     required this.subtitle,
//     required this.time,
//     required this.statusText,
//     required this.statusColor,
//     required this.onTap,
//     required this.onDetails,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             color: Colors.white,
//             border: Border.all(color: const Color(0xFFE6EAF0)),
//           ),
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 18,
//                 backgroundColor: const Color(0xFFE5E7EB),
//                 backgroundImage: const AssetImage('dummy_image.png'),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       subtitle,
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     time,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF2563EB),
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Container(
//                     decoration: BoxDecoration(
//                       color: statusColor.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(999),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     child: Text(
//                       statusText,
//                       style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w800,
//                         color: statusColor,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: onDetails,
//                     child: const Text(
//                       'View Details',
//                       style: TextStyle(
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF2563EB),
//                         decoration: TextDecoration.underline,
//                         decorationColor: Color(0xFF2563EB),
//                       ),
//                     ),
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

// /* ============== ASHA Note Button ============== */

// class ASHANoteCardButton extends StatelessWidget {
//   final VoidCallback onTap;
//   const ASHANoteCardButton({super.key, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(14),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(14),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: const Color(0xFFE6EAF0)),
//           ),
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               Row(
//                 children: [
//                   Icon(Icons.badge_outlined, color: Color(0xFF2563EB)),
//                   SizedBox(width: 8),
//                   Text(
//                     'Latest Vitals (ASHA Worker)',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF0F172A),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 8),
//               _VitalsText(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _VitalsText extends StatelessWidget {
//   const _VitalsText({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return RichText(
//       text: const TextSpan(
//         style: TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           color: Color(0xFF6B7280),
//         ),
//         children: [
//           TextSpan(text: 'Patient '),
//           TextSpan(
//             text: 'Sunita Devi',
//             style: TextStyle(
//               color: Color(0xFF111827),
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           TextSpan(text: ': BP 130/85, Sugar (F) 98mg/dL. No new complaints. '),
//           TextSpan(
//             text: ' - 2 hours ago',
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* ============== Bottom Navigation ============== */

// class _BottomNav extends StatelessWidget {
//   final int index;
//   final void Function(int, String) onTap;
//   const _BottomNav({super.key, required this.index, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final items = const [
//       _NavItemData(Icons.dashboard_outlined, 'Dashboard'),
//       _NavItemData(Icons.chat_bubble_outline, 'Messages'),
//       _NavItemData(Icons.event_note_outlined, 'Schedule'),
//       _NavItemData(Icons.settings_outlined, 'Settings'),
//     ];
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
//       ),
//       padding: const EdgeInsets.only(top: 6, bottom: 6),
//       child: SafeArea(
//         top: false,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: List.generate(items.length, (i) {
//             final selected = i == index;
//             final color =
//                 selected ? const Color(0xFF2563EB) : const Color(0xFF98A2B3);
//             return InkWell(
//               onTap: () => onTap(i, items[i].label),
//               borderRadius: BorderRadius.circular(10),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(items[i].icon, color: color, size: 22),
//                     const SizedBox(height: 2),
//                     Text(
//                       items[i].label,
//                       style: TextStyle(
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w800,
//                         color: color,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// class _NavItemData {
//   final IconData icon;
//   final String label;
//   const _NavItemData(this.icon, this.label);
// }

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   const _SectionTitle(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 16.5,
//         fontWeight: FontWeight.w800,
//         color: Color(0xFF0D1B2A),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gramcare/frontend/doctor/telemedicine_consultation.dart'; // Add this import

const String apiBase = 'http://192.168.137.1:4001'; // adjust if needed

class DoctorDashboardApp extends StatelessWidget {
  final String jwtToken;
  const DoctorDashboardApp({super.key, required this.jwtToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FB),
        fontFamily: 'Inter',
        useMaterial3: false,
      ),
      home: DoctorDashboardScreen(jwtToken: jwtToken),
    );
  }
}

class DoctorDashboardScreen extends StatefulWidget {
  final String jwtToken;
  const DoctorDashboardScreen({super.key, required this.jwtToken});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _navIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  String? doctorName;
  String? doctorEmail;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    try {
      final uri = Uri.parse('$apiBase/api/doctor/me');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.jwtToken}',
      };

      final resp = await http.get(uri, headers: headers);

      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          doctorName = (map['fullName'] ?? '').toString().trim();
          doctorEmail = (map['email'] ?? '').toString().trim();
          _loadingProfile = false;
        });
      } else if (resp.statusCode == 401) {
        setState(() {
          doctorName = 'Doctor';
          _loadingProfile = false;
        });
      } else {
        setState(() {
          doctorName = 'Doctor';
          _loadingProfile = false;
        });
      }
    } catch (_) {
      setState(() {
        doctorName = 'Doctor';
        _loadingProfile = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  // Navigation method for Start Consultation
  void _navigateToConsultation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => const ConsultationScreen(
              patientName: 'Test Patient',
              appointmentId: 'test_appointment', // This doesn't matter for now
            ),
      ),
    );
  }

  // Handle quick action taps with navigation
  void _handleQuickActionTap(String label) {
    switch (label) {
      case 'Start Consultation':
        _navigateToConsultation();
        break;
      case 'Prescribe':
        _snack('Opening prescription pad');
        // You can add navigation to prescription screen here
        break;
      case 'Order Tests':
        _snack('Opening test ordering');
        // You can add navigation to test ordering screen here
        break;
      case 'Patient List':
        _snack('Opening patient list');
        // You can add navigation to patient list screen here
        break;
      default:
        _snack(label);
    }
  }

  @override
  Widget build(BuildContext context) {
    final headerName =
        _loadingProfile
            ? 'Loading...'
            : (doctorName == null || doctorName!.isEmpty
                ? 'Doctor'
                : doctorName!);

    return Scaffold(
      appBar: _HeaderBar(
        onBellTap: () => _snack('Opening notifications'),
        displayName: headerName,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  SearchBarInteractive(
                    controller: _searchCtrl,
                    onSubmit: (v) => _snack('Searching: $v'),
                    onTap: () => _snack('Search tapped'),
                    onClear: () {
                      _searchCtrl.clear();
                      setState(() {});
                      _snack('Search cleared');
                    },
                  ),
                  const SizedBox(height: 14),
                  const AlertsCard(),
                  const SizedBox(height: 16),
                  const _SectionTitle('Quick Actions'),
                  const SizedBox(height: 10),
                  QuickActionsGrid(
                    onTap: _handleQuickActionTap,
                  ), // Updated to use the new handler
                  const SizedBox(height: 16),
                  const _SectionTitle('Snapshot / Insights'),
                  const SizedBox(height: 10),
                  const SnapshotGrid(),
                  const SizedBox(height: 18),
                  const _SectionTitle('Upcoming Appointments'),
                  const SizedBox(height: 10),
                  AppointmentCard(
                    name: 'Rohan Verma',
                    subtitle: 'Follow-up',
                    time: '10:30 AM',
                    statusText: 'Confirmed',
                    statusColor: const Color(0xFF34D399),
                    onTap: () => _snack('Rohan Verma'),
                    onDetails: () => _snack('View Details: Rohan Verma'),
                  ),
                  const SizedBox(height: 10),
                  AppointmentCard(
                    name: 'Priya Singh',
                    subtitle: 'New Consultation',
                    time: '11:00 AM',
                    statusText: 'Pending',
                    statusColor: const Color(0xFFF59E0B),
                    onTap: () => _snack('Priya Singh'),
                    onDetails: () => _snack('View Details: Priya Singh'),
                  ),
                  const SizedBox(height: 18),
                  const _SectionTitle('Patient Health Worker Notes'),
                  const SizedBox(height: 10),
                  ASHANoteCardButton(
                    onTap: () => _snack('Opening latest vitals'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i, label) {
          setState(() => _navIndex = i);
          _snack('Nav: $label');
        },
      ),
    );
  }
}

// Rest of the classes remain the same as in your original code...
// (I'll include them here to show the complete file)

class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBellTap;
  final String displayName;
  const _HeaderBar({
    super.key,
    required this.onBellTap,
    required this.displayName,
  });
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FB),
      elevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8, top: 4, bottom: 4),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFFFE7D6),
              backgroundImage: AssetImage('dummy_image.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: const [
                      Icon(Icons.circle, size: 8, color: Color(0xFF34D399)),
                      SizedBox(width: 6),
                      Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onBellTap,
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF4B5563),
                  ),
                  tooltip: 'Notifications',
                ),
                const Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class SearchBarInteractive extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const SearchBarInteractive({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF7B8794)),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: onSubmit,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Search patients, reports...',
                    hintStyle: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA3AF),
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ),
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9AA3AF),
                    size: 18,
                  ),
                  splashRadius: 18,
                  tooltip: 'Clear',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlertsCard extends StatelessWidget {
  const AlertsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFBD5D5)),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _AlertLine(
                  bold: 'Medicine Shortage:',
                  rest: ' Paracetamol stock is critically low.',
                ),
                SizedBox(height: 8),
                _AlertLine(
                  bold: 'Emergency:',
                  rest:
                      ' New trauma case admitted. Immediate attention required.',
                ),
              ],
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Color(0xFFFCA5A5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              '2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLine extends StatelessWidget {
  final String bold;
  final String rest;
  const _AlertLine({super.key, required this.bold, required this.rest});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: bold,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF991B1B),
            ),
          ),
          TextSpan(
            text: rest,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7F1D1D),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionsGrid extends StatelessWidget {
  final void Function(String) onTap;
  const QuickActionsGrid({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _QAData('Start Consultation', Icons.smart_display_outlined),
      _QAData('Prescribe', Icons.edit_note_outlined),
      _QAData('Order Tests', Icons.science_outlined),
      _QAData('Patient List', Icons.group_outlined),
    ];
    return GridView.builder(
      shrinkWrap: true,
      itemCount: tiles.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 96,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, i) {
        final t = tiles[i];
        return Material(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => onTap(t.label),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.icon, color: const Color(0xFF2F80ED), size: 26),
                  const SizedBox(height: 8),
                  Text(
                    t.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A37),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QAData {
  final String label;
  final IconData icon;
  _QAData(this.label, this.icon);
}

class SnapshotGrid extends StatelessWidget {
  const SnapshotGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _SnapshotItem('Total Patients', '324', accent: Color(0xFF111827)),
      _SnapshotItem('Open Cases', '15', accent: Color(0xFF111827)),
      _SnapshotItem('Reports to Review', '8', accent: Color(0xFFF59E0B)),
      _SnapshotItem('Avg. Consult Time', '12m', accent: Color(0xFF111827)),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 84,
      ),
      itemBuilder: (context, i) {
        final it = items[i];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                it.title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                it.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: it.accent,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SnapshotItem {
  final String title;
  final String value;
  final Color accent;
  const _SnapshotItem(this.title, this.value, {required this.accent});
}

class AppointmentCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String time;
  final String statusText;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  const AppointmentCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.time,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: const AssetImage('dummy_image.png'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: onDetails,
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF2563EB),
                      ),
                    ),
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

class ASHANoteCardButton extends StatelessWidget {
  final VoidCallback onTap;
  const ASHANoteCardButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.badge_outlined, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Text(
                    'Latest Vitals (ASHA Worker)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _VitalsText(),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalsText extends StatelessWidget {
  const _VitalsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
        ),
        children: [
          TextSpan(text: 'Patient '),
          TextSpan(
            text: 'Sunita Devi',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: ': BP 130/85, Sugar (F) 98mg/dL. No new complaints. '),
          TextSpan(
            text: ' - 2 hours ago',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final void Function(int, String) onTap;
  const _BottomNav({super.key, required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItemData(Icons.dashboard_outlined, 'Dashboard'),
      _NavItemData(Icons.chat_bubble_outline, 'Messages'),
      _NavItemData(Icons.event_note_outlined, 'Schedule'),
      _NavItemData(Icons.settings_outlined, 'Settings'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final selected = i == index;
            final color =
                selected ? const Color(0xFF2563EB) : const Color(0xFF98A2B3);
            return InkWell(
              onTap: () => onTap(i, items[i].label),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(items[i].icon, color: color, size: 22),
                    const SizedBox(height: 2),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData(this.icon, this.label);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0D1B2A),
      ),
    );
  }
}
