// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gramcare/frontend/patients/medicine_avail.dart';
// import 'package:gramcare/frontend/patients/patientappoinment1.dart';
// import 'package:http/http.dart' as http;
// import 'health_records_app.dart'; // Add this import
// import 'symptom_checker.dart'; // Add this import
// import 'patientappoinment.dart'; // Add this import
// import 'patientprofile.dart'; // Add this import
// // Add this import (ensure the file name matches where BookAppointmentFlow is defined)

// void main() =>
//     runApp(const GramCareHomeApp(username: '')); // Optional stub for local run

// class GramCareHomeApp extends StatelessWidget {
//   final String username;
//   const GramCareHomeApp({super.key, required this.username});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'GramCare',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: false,
//         scaffoldBackgroundColor: const Color(0xFFF6F7FB),
//         fontFamily: 'SFPro',
//       ),
//       routes: {
//         '/': (_) => GramCareHome(username: username),
//         '/appointments': (context) {
//           final args =
//               ModalRoute.of(context)?.settings.arguments as String? ?? username;
//           return BookAppointmentFlow(username: args);
//         },
//         '/profile': (context) {
//           final args =
//               ModalRoute.of(context)?.settings.arguments as String? ?? username;
//           return PatientProfileScreen(username: args);
//         },
//         '/book': (context) {
//           final args =
//               ModalRoute.of(context)?.settings.arguments as String? ?? '';
//           return AppointmentsScreen(username: args);
//         },

//         '/medicines': (_) => MedicineAvailabilityPage(username: username),

//         '/symptoms': (_) => const DummyScreen(title: 'Symptoms'),
//         '/records': (_) => const DummyScreen(title: 'Full Records'),
//         '/settings': (_) => const DummyScreen(title: 'Settings'),
//         '/doctor_detail': (_) => const DummyScreen(title: 'Doctor Detail'),
//         '/reschedule': (_) => const DummyScreen(title: 'Reschedule'),
//         '/cancel': (_) => const DummyScreen(title: 'Cancel Appointment'),
//         '/health_records':
//             (context) => HealthRecordsApp(username: username), // Add this route
//         '/symptom_checker': (context) {
//           final args =
//               ModalRoute.of(context)?.settings.arguments as String? ?? '';
//           return SymptomCheckerScreen(username: args);
//         },
//       },
//     );
//   }
// }

// class DummyScreen extends StatelessWidget {
//   final String title;
//   const DummyScreen({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title, style: const TextStyle(color: Color(0xFF111827))),
//         backgroundColor: const Color(0xFFF6F7FB),
//         iconTheme: const IconThemeData(color: Color(0xFF111827)),
//         elevation: 0,
//       ),
//       body: Center(
//         child: Text(
//           '$title Screen',
//           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }
// }

// // ---------- Color Tokens ----------
// class GcColors {
//   static const bg = Color(0xFFF6F7FB);
//   static const card = Colors.white;
//   static const textPrimary = Color(0xFF111827);
//   static const textSecondary = Color(0xFF6B7280);
//   static const border = Color(0xFFE5E7EB);
//   static const shadow = Color(0x1A000000);
//   static const primaryBlue = Color(0xFF0A84FF);
//   static const iconBlueBg = Color(0xFFE8F2FF);
//   static const softBlue = Color(0xFFEFF6FF);
//   static const pillBlue = Color(0xFFDDEBFF);
// }

// // ---------- Home Screen ----------
// class GramCareHome extends StatefulWidget {
//   final String username; // patient's login
//   const GramCareHome({super.key, required this.username});

//   @override
//   State<GramCareHome> createState() => _GramCareHomeState();
// }

// class _GramCareHomeState extends State<GramCareHome> {
//   int currentTab = 0;

//   void _onBottomTap(int index) {
//     setState(() => currentTab = index);
//     switch (index) {
//       case 0:
//         break;
//       case 1:
//         Navigator.pushNamed(
//           context,
//           '/appointments',
//           arguments: widget.username,
//         );
//         break;
//       case 2:
//         Navigator.pushNamed(context, '/profile', arguments: widget.username);
//         break;
//     }
//   }

//   void _goto(String route) => Navigator.pushNamed(context, route);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: GcColors.bg,
//       appBar: AppBar(
//         backgroundColor: GcColors.bg,
//         elevation: 0,
//         centerTitle: true,
//         leadingWidth: 24,
//         title: const Text(
//           'GramCare',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: GcColors.textPrimary,
//             letterSpacing: 0.2,
//           ),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () => _goto('/settings'),
//             icon: const Icon(
//               Icons.settings_outlined,
//               color: GcColors.textPrimary,
//             ),
//           ),
//         ],
//       ),
//       body: _HomeBody(
//         username: widget.username, // pass login to summary
//         onBook: () => _goto('/book'),
//         onMedicines: () => _goto('/medicines'),
//         onSymptoms: () {
//           Navigator.pushNamed(
//             context,
//             '/symptom_checker',
//             arguments: widget.username,
//           );
//         },
//         onOpenDoctor: () => _goto('/doctor_detail'),
//         onReschedule: () => _goto('/reschedule'),
//         onCancel: () => _goto('/cancel'),
//         onRecords: () => _goto('/records'),
//         onLanguageChanged: (lang) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Language: $lang',
//                 style: const TextStyle(fontWeight: FontWeight.w700),
//               ),
//               behavior: SnackBarBehavior.floating,
//               backgroundColor: GcColors.primaryBlue,
//               duration: const Duration(milliseconds: 900),
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentTab,
//         onTap: _onBottomTap,
//         backgroundColor: GcColors.card,
//         selectedItemColor: GcColors.primaryBlue,
//         unselectedItemColor: GcColors.textSecondary,
//         showUnselectedLabels: true,
//         selectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w700,
//           fontSize: 11,
//         ),
//         unselectedLabelStyle: const TextStyle(
//           fontWeight: FontWeight.w500,
//           fontSize: 11,
//         ),
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.event_note_outlined),
//             label: 'Appointments',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HomeBody extends StatelessWidget {
//   final String username; // login to query
//   final VoidCallback onBook;
//   final VoidCallback onMedicines;
//   final VoidCallback onSymptoms;
//   final VoidCallback onOpenDoctor;
//   final VoidCallback onReschedule;
//   final VoidCallback onCancel;
//   final VoidCallback onRecords;
//   final ValueChanged<String> onLanguageChanged;

//   const _HomeBody({
//     required this.username,
//     required this.onBook,
//     required this.onMedicines,
//     required this.onSymptoms,
//     required this.onOpenDoctor,
//     required this.onReschedule,
//     required this.onCancel,
//     required this.onRecords,
//     required this.onLanguageChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _PersonalHealthSummary(username: username), // dynamic fetch
//           const SizedBox(height: 14),
//           _QuickActionsRow(
//             onBook: () {
//               Navigator.pushNamed(context, '/book', arguments: username);
//             },
//             onMedicines: () {
//               Navigator.pushNamed(context, '/medicines', arguments: username);
//             },
//             onSymptoms: () {
//               Navigator.pushNamed(
//                 context,
//                 '/symptom_checker',
//                 arguments: username,
//               );
//             },
//           ),
//           const SizedBox(height: 18),
//           const _SectionHeader('Upcoming Appointments'),
//           const SizedBox(height: 10),
//           _UpcomingAppointmentCard(
//             onReschedule: onReschedule,
//             onCancel: onCancel,
//           ),
//           const SizedBox(height: 18),
//           const _SectionHeader('Recent Consultations'),
//           const SizedBox(height: 10),
//           _RecentConsultationItem(
//             name: 'Dr. Sharma',
//             date: 'July 20, 2024',
//             onTap: onOpenDoctor,
//           ),
//           const SizedBox(height: 10),
//           _RecentConsultationItem(
//             name: 'Dr. Verma',
//             date: 'June 15, 2024',
//             onTap: onOpenDoctor,
//           ),
//           const SizedBox(height: 18),
//           const _SectionHeader('Personalized Notifications'),
//           const SizedBox(height: 10),
//           const _NotificationTile(
//             icon: Icons.medication_outlined,
//             title: 'Medicine Refill Reminder',
//           ),
//           const SizedBox(height: 8),
//           const _NotificationTile(
//             icon: Icons.vaccines_outlined,
//             title: 'Vaccination Reminder',
//           ),
//           const SizedBox(height: 8),
//           const _NotificationTile(
//             icon: Icons.campaign_outlined,
//             title: 'Health Camp Alert',
//           ),
//           const SizedBox(height: 18),
//           const _SectionHeader('Health Record Snapshot'),
//           const SizedBox(height: 10),
//           _HealthRecordSnapshot(username: username),
//           const SizedBox(height: 18),
//           const _SectionHeader('Featured Health Education'),
//           const SizedBox(height: 10),
//           const _FeaturedEducationBanner(),
//           const SizedBox(height: 18),
//           const _SectionHeader('Language'),
//           const SizedBox(height: 10),
//           _LanguageRow(onChanged: onLanguageChanged),
//         ],
//       ),
//     );
//   }
// }

// // ---------- Building blocks ----------
// class _SectionHeader extends StatelessWidget {
//   final String text;
//   const _SectionHeader(this.text);
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w700,
//         color: GcColors.textPrimary,
//       ),
//     );
//   }
// }

// class _Card extends StatelessWidget {
//   final Widget child;
//   final EdgeInsetsGeometry padding;
//   const _Card({required this.child, this.padding = const EdgeInsets.all(14)});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: padding,
//       decoration: BoxDecoration(
//         color: GcColors.card,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: GcColors.border),
//         boxShadow: const [
//           BoxShadow(
//             color: GcColors.shadow,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// // ---------- Personal Health Summary (fetch + compute age) ----------
// class _PersonalHealthSummary extends StatefulWidget {
//   final String username; // patients.login value
//   const _PersonalHealthSummary({required this.username});

//   @override
//   State<_PersonalHealthSummary> createState() => _PersonalHealthSummaryState();
// }

// class _PersonalHealthSummaryState extends State<_PersonalHealthSummary> {
//   static const String _apiBase =
//       'http://192.168.137.1:4001'; // same as login base
//   String _displayName = '';
//   int? _age;
//   bool _loading = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _loadProfile();
//   }

//   Uri _buildUri(String path, Map<String, String> q) {
//     final base = Uri.parse(_apiBase);
//     final basePath =
//         base.path.endsWith('/')
//             ? base.path.substring(0, base.path.length - 1)
//             : base.path;
//     return base.replace(path: '$basePath$path', queryParameters: q);
//   }

//   int _ageFromDob(String ddmmyyyy) {
//     final parts = ddmmyyyy.split('/');
//     if (parts.length != 3) return 0;
//     final d = int.tryParse(parts[0]) ?? 1;
//     final m = int.tryParse(parts[1]) ?? 1;
//     final y = int.tryParse(parts[2]) ?? DateTime.now().year;
//     final birth = DateTime(y, m, d);
//     final now = DateTime.now();
//     int age = now.year - birth.year;
//     final hadBirthday =
//         (now.month > birth.month) ||
//         (now.month == birth.month && now.day >= birth.day);
//     if (!hadBirthday) age -= 1;
//     return age < 0 ? 0 : age;
//   }

//   Future<void> _loadProfile() async {
//     setState(() {
//       _loading = true;
//       _error = null;
//     });
//     try {
//       final uri = _buildUri('/api/patient-profile', {'login': widget.username});
//       final resp = await http.get(uri);
//       if (resp.statusCode == 200) {
//         final map = jsonDecode(resp.body) as Map<String, dynamic>;
//         final fullName = ((map['fullName'] ?? '') as String).trim();
//         final dob = ((map['dob'] ?? '') as String).trim();
//         final age = dob.isNotEmpty ? _ageFromDob(dob) : null;
//         if (!mounted) return;
//         setState(() {
//           _displayName = fullName.isEmpty ? widget.username : fullName;
//           _age = age;
//           _loading = false;
//         });
//       } else if (resp.statusCode == 404) {
//         if (!mounted) return;
//         setState(() {
//           _displayName = widget.username;
//           _age = null;
//           _loading = false;
//           _error = 'Profile not found';
//         });
//       } else {
//         if (!mounted) return;
//         setState(() {
//           _displayName = widget.username;
//           _age = null;
//           _loading = false;
//           _error = 'Failed: ${resp.statusCode}';
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _displayName = widget.username;
//         _age = null;
//         _loading = false;
//         _error = 'Network error';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ageText = _age == null ? '—' : _age.toString();
//     return _Card(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Personal Health Summary',
//             style: TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w700,
//               color: GcColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(22),
//                   color: const Color(0xFFF1F5F9),
//                 ),
//                 child: const Icon(Icons.person, color: GcColors.textSecondary),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child:
//                     _loading
//                         ? const Text(
//                           'Loading...',
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//                             color: GcColors.textSecondary,
//                           ),
//                         )
//                         : Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               _displayName,
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w700,
//                                 color: GcColors.textPrimary,
//                               ),
//                             ),
//                             const SizedBox(height: 2),
//                             Text(
//                               'Age: $ageText',
//                               style: const TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w400,
//                                 color: GcColors.textSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//             decoration: BoxDecoration(
//               color: GcColors.softBlue,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: const Color(0xFFD6E4FF)),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.info_outline, color: GcColors.primaryBlue),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Text(
//                     _error == null ? 'Critical Health Alerts: None' : _error!,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: GcColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------- Quick Actions ----------
// class _QuickActionsRow extends StatelessWidget {
//   final VoidCallback onBook;
//   final VoidCallback onMedicines;
//   final VoidCallback onSymptoms;
//   const _QuickActionsRow({
//     required this.onBook,
//     required this.onMedicines,
//     required this.onSymptoms,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, c) {
//         final isVeryNarrow = c.maxWidth < 320;
//         if (isVeryNarrow) {
//           return Column(
//             children: [
//               _QuickSquareCard(
//                 icon: Icons.assignment_turned_in_outlined,
//                 label: 'Symptoms',
//                 onPressed: onSymptoms,
//               ),
//               const SizedBox(height: 8),
//               _QuickSquareCard(
//                 icon: Icons.medication_outlined,
//                 label: 'Medicines',
//                 onPressed: onMedicines,
//               ),
//               const SizedBox(height: 8),
//               _QuickSquareCard(
//                 icon: Icons.add_circle_outline,
//                 label: 'Book',
//                 onPressed: onBook,
//               ),
//             ],
//           );
//         }
//         return Row(
//           textDirection: TextDirection.rtl,
//           children: [
//             Expanded(
//               child: _QuickSquareCard(
//                 icon: Icons.assignment_turned_in_outlined,
//                 label: 'Symptom \nchecker',
//                 onPressed: onSymptoms,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _QuickSquareCard(
//                 icon: Icons.medication_outlined,
//                 label: 'Medicines',
//                 onPressed: onMedicines,
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: _QuickSquareCard(
//                 icon: Icons.add_circle_outline,
//                 label: 'Book',
//                 onPressed: onBook,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// class _QuickSquareCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onPressed;
//   const _QuickSquareCard({
//     required this.icon,
//     required this.label,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       padding: EdgeInsets.zero,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(14),
//         onTap: onPressed,
//         child: Container(
//           height: 90,
//           decoration: BoxDecoration(
//             color: GcColors.softBlue,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: const Color(0xFFD6E4FF)),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: GcColors.iconBlueBg,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Icon(icon, color: GcColors.primaryBlue, size: 18),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   label,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 12.5,
//                     fontWeight: FontWeight.w600,
//                     color: GcColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------- Upcoming Appointment ----------
// class _UpcomingAppointmentCard extends StatelessWidget {
//   final VoidCallback onReschedule;
//   final VoidCallback onCancel;
//   const _UpcomingAppointmentCard({
//     required this.onReschedule,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: GcColors.iconBlueBg,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Icon(
//                   Icons.calendar_today_outlined,
//                   color: GcColors.primaryBlue,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               const Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Dr. Singh',
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w700,
//                         color: GcColors.textPrimary,
//                       ),
//                     ),
//                     SizedBox(height: 2),
//                     Text(
//                       'August 10, 2024',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                         color: GcColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _pillButton(
//                   label: 'Reschedule',
//                   background: GcColors.pillBlue,
//                   textColor: GcColors.primaryBlue,
//                   onTap: onReschedule,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _pillButton(
//                   label: 'Cancel',
//                   background: GcColors.softBlue,
//                   textColor: GcColors.textPrimary,
//                   onTap: onCancel,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   static Widget _pillButton({
//     required String label,
//     required Color background,
//     required Color textColor,
//     required VoidCallback onTap,
//   }) {
//     return SizedBox(
//       height: 40,
//       child: TextButton(
//         onPressed: onTap,
//         style: TextButton.styleFrom(
//           backgroundColor: background,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           side: const BorderSide(color: Color(0xFFD6E4FF)),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//             color: textColor,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ---------- Recent Consultations ----------
// class _RecentConsultationItem extends StatelessWidget {
//   final String name;
//   final String date;
//   final VoidCallback onTap;
//   const _RecentConsultationItem({
//     required this.name,
//     required this.date,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: onTap,
//         child: Row(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color: GcColors.iconBlueBg,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: const Icon(
//                 Icons.history,
//                 color: GcColors.primaryBlue,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.w700,
//                       color: GcColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     date,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w400,
//                       color: GcColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: GcColors.textSecondary),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- Notifications ----------
// class _NotificationTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   const _NotificationTile({required this.icon, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: GcColors.iconBlueBg,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: GcColors.primaryBlue, size: 20),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: GcColors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------- Health Record Snapshot ----------
// class _HealthRecordSnapshot extends StatelessWidget {
//   final VoidCallback? onRecords;
//   final String username;
//   const _HealthRecordSnapshot({required this.username, this.onRecords});

//   @override
//   Widget build(BuildContext context) {
//     return _Card(
//       child: Row(
//         children: [
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               color: GcColors.iconBlueBg,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: const Icon(
//               Icons.folder_open_outlined,
//               color: GcColors.primaryBlue,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Last Prescription: 2024-07-20',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: GcColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       '/health_records',
//                       arguments: username,
//                     );
//                   },
//                   behavior: HitTestBehavior.opaque,
//                   child: const Text(
//                     'View Full Records',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: GcColors.primaryBlue,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------- Featured Education ----------
// class _FeaturedEducationBanner extends StatelessWidget {
//   const _FeaturedEducationBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 140,
//       decoration: BoxDecoration(
//         color: Colors.black12,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: GcColors.border),
//         boxShadow: const [
//           BoxShadow(
//             color: GcColors.shadow,
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(14),
//           gradient: LinearGradient(
//             colors: [
//               Colors.black.withOpacity(0.05),
//               Colors.black.withOpacity(0.35),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         padding: const EdgeInsets.all(14),
//         alignment: Alignment.bottomLeft,
//         child: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Health Tip: Stay Hydrated',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.white,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 2,
//                     color: Colors.black54,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'Drink plenty of water to stay healthy.',
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.white,
//                 shadows: [
//                   Shadow(
//                     blurRadius: 2,
//                     color: Colors.black45,
//                     offset: Offset(0, 1),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ---------- Language ----------
// class _LanguageRow extends StatefulWidget {
//   final ValueChanged<String> onChanged;
//   const _LanguageRow({required this.onChanged});

//   @override
//   State<_LanguageRow> createState() => _LanguageRowState();
// }

// class _LanguageRowState extends State<_LanguageRow> {
//   String selected = 'English';
//   void _select(String lang) {
//     setState(() => selected = lang);
//     widget.onChanged(lang);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         _LangPill(
//           text: 'Punjabi',
//           selected: selected == 'Punjabi',
//           onTap: () => _select('Punjabi'),
//         ),
//         const SizedBox(width: 12),
//         _LangPill(
//           text: 'Hindi',
//           selected: selected == 'Hindi',
//           onTap: () => _select('Hindi'),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: _LangPill(
//             text: 'English',
//             selected: selected == 'English',
//             onTap: () => _select('English'),
//             expand: true,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _LangPill extends StatelessWidget {
//   final String text;
//   final bool selected;
//   final bool expand;
//   final VoidCallback onTap;
//   const _LangPill({
//     required this.text,
//     required this.selected,
//     required this.onTap,
//     this.expand = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = selected ? GcColors.primaryBlue : GcColors.card;
//     final border = selected ? GcColors.primaryBlue : GcColors.border;
//     final fg = selected ? Colors.white : GcColors.textPrimary;

//     final pill = InkWell(
//       borderRadius: BorderRadius.circular(12),
//       onTap: onTap,
//       child: Container(
//         height: 44,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: border),
//           boxShadow: const [
//             BoxShadow(
//               color: GcColors.shadow,
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           text,
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//             color: fg,
//           ),
//         ),
//       ),
//     );

//     return expand ? pill : SizedBox(width: 108, child: pill);
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gramcare/frontend/patients/medicine_avail.dart';
import 'package:gramcare/frontend/patients/patientappoinment1.dart';
import 'package:http/http.dart' as http;
import 'health_records_app.dart';
import 'symptom_checker.dart';
import 'patientappoinment.dart';
import 'patientprofile.dart';
import 'SOS.dart'; // Import SOS screen
import 'healthcare.dart'; // Import healthcare screen

void main() => runApp(const GramCareHomeApp(username: ''));

class GramCareHomeApp extends StatelessWidget {
  final String username;
  const GramCareHomeApp({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'SFPro',
      ),
      routes: {
        '/': (_) => GramCareHome(username: username),
        '/appointments': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as String? ?? username;
          return BookAppointmentFlow(username: args);
        },
        '/profile': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as String? ?? username;
          return PatientProfileScreen(username: args);
        },
        '/book': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return AppointmentsScreen(username: args);
        },
        '/medicines': (_) => MedicineAvailabilityPage(username: username),
        '/symptoms': (_) => const DummyScreen(title: 'Symptoms'),
        '/records': (_) => const DummyScreen(title: 'Full Records'),
        '/settings': (_) => const DummyScreen(title: 'Settings'),
        '/doctor_detail': (_) => const DummyScreen(title: 'Doctor Detail'),
        '/reschedule': (_) => const DummyScreen(title: 'Reschedule'),
        '/cancel': (_) => const DummyScreen(title: 'Cancel Appointment'),
        '/health_records': (context) => HealthRecordsApp(username: username),
        '/symptom_checker': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as String? ?? '';
          return SymptomCheckerScreen(username: args);
        },
        '/emergency': (_) => EmergencyServicesScreen(), // Add SOS route
      },
    );
  }
}

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Color(0xFF111827))),
        backgroundColor: const Color(0xFFF6F7FB),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ---------- Color Tokens ----------
class GcColors {
  static const bg = Color(0xFFF6F7FB);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const shadow = Color(0x1A000000);
  static const primaryBlue = Color(0xFF0A84FF);
  static const iconBlueBg = Color(0xFFE8F2FF);
  static const softBlue = Color(0xFFEFF6FF);
  static const pillBlue = Color(0xFFDDEBFF);
  static const emergencyRed = Color(0xFFFF3B30); // Add emergency color
}

// ---------- Home Screen ----------
class GramCareHome extends StatefulWidget {
  final String username;
  const GramCareHome({super.key, required this.username});

  @override
  State<GramCareHome> createState() => _GramCareHomeState();
}

class _GramCareHomeState extends State<GramCareHome> {
  int currentTab = 0;

  void _onBottomTap(int index) {
    setState(() => currentTab = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(
          context,
          '/appointments',
          arguments: widget.username,
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/profile', arguments: widget.username);
        break;
    }
  }

  void _goto(String route) => Navigator.pushNamed(context, route);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GcColors.bg,
      appBar: AppBar(
        backgroundColor: GcColors.bg,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 24,
        title: const Text(
          'GramCare',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: GcColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/emergency'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GcColors.emergencyRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
              ),
              child: const Text(
                'SOS',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: _HomeBody(
        username: widget.username,
        onBook: () => _goto('/book'),
        onMedicines: () => _goto('/medicines'),
        onSymptoms: () {
          Navigator.pushNamed(
            context,
            '/symptom_checker',
            arguments: widget.username,
          );
        },
        onOpenDoctor: () => _goto('/doctor_detail'),
        onReschedule: () => _goto('/reschedule'),
        onCancel: () => _goto('/cancel'),
        onRecords: () => _goto('/records'),
        onLanguageChanged: (lang) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Language: $lang',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: GcColors.primaryBlue,
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentTab,
        onTap: _onBottomTap,
        backgroundColor: GcColors.card,
        selectedItemColor: GcColors.primaryBlue,
        unselectedItemColor: GcColors.textSecondary,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final String username;
  final VoidCallback onBook;
  final VoidCallback onMedicines;
  final VoidCallback onSymptoms;
  final VoidCallback onOpenDoctor;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onRecords;
  final ValueChanged<String> onLanguageChanged;

  const _HomeBody({
    required this.username,
    required this.onBook,
    required this.onMedicines,
    required this.onSymptoms,
    required this.onOpenDoctor,
    required this.onReschedule,
    required this.onCancel,
    required this.onRecords,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PersonalHealthSummary(username: username),
          const SizedBox(height: 14),
          _QuickActionsRow(
            onBook: () {
              Navigator.pushNamed(context, '/book', arguments: username);
            },
            onMedicines: () {
              Navigator.pushNamed(context, '/medicines', arguments: username);
            },
            onSymptoms: () {
              Navigator.pushNamed(
                context,
                '/symptom_checker',
                arguments: username,
              );
            },
          ),
          const SizedBox(height: 18),
          const _SectionHeader('Upcoming Appointments'),
          const SizedBox(height: 10),
          _UpcomingAppointmentCard(
            onReschedule: onReschedule,
            onCancel: onCancel,
          ),
          const SizedBox(height: 18),
          const _SectionHeader('Recent Consultations'),
          const SizedBox(height: 10),
          _RecentConsultationItem(
            name: 'Dr. Sharma',
            date: 'July 20, 2024',
            onTap: onOpenDoctor,
          ),
          const SizedBox(height: 10),
          _RecentConsultationItem(
            name: 'Dr. Verma',
            date: 'June 15, 2024',
            onTap: onOpenDoctor,
          ),
          const SizedBox(height: 18),
          const _SectionHeader('Personalized Notifications'),
          const SizedBox(height: 10),
          const _NotificationTile(
            icon: Icons.medication_outlined,
            title: 'Medicine Refill Reminder',
          ),
          const SizedBox(height: 8),
          const _NotificationTile(
            icon: Icons.vaccines_outlined,
            title: 'Vaccination Reminder',
          ),
          const SizedBox(height: 8),
          const _NotificationTile(
            icon: Icons.campaign_outlined,
            title: 'Health Camp Alert',
          ),
          const SizedBox(height: 18),
          const _SectionHeader('Health Record Snapshot'),
          const SizedBox(height: 10),
          _HealthRecordSnapshot(username: username),
          const SizedBox(height: 18),
          const _SectionHeader('Health Hub'),
          const SizedBox(height: 10),
          _HealthHubWidget(
            username: username,
          ), // Replace featured education with HealthHub
          const SizedBox(height: 18),
          const _SectionHeader('Language'),
          const SizedBox(height: 10),
          _LanguageRow(onChanged: onLanguageChanged),
        ],
      ),
    );
  }
}

// ---------- Building blocks ----------
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: GcColors.textPrimary,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: GcColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GcColors.border),
        boxShadow: const [
          BoxShadow(
            color: GcColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------- Personal Health Summary (fetch + compute age) ----------
class _PersonalHealthSummary extends StatefulWidget {
  final String username;
  const _PersonalHealthSummary({required this.username});

  @override
  State<_PersonalHealthSummary> createState() => _PersonalHealthSummaryState();
}

class _PersonalHealthSummaryState extends State<_PersonalHealthSummary> {
  static const String _apiBase = 'http://192.168.137.1:4001';
  String _displayName = '';
  int? _age;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Uri _buildUri(String path, Map<String, String> q) {
    final base = Uri.parse(_apiBase);
    final basePath =
        base.path.endsWith('/')
            ? base.path.substring(0, base.path.length - 1)
            : base.path;
    return base.replace(path: '$basePath$path', queryParameters: q);
  }

  int _ageFromDob(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return 0;
    final d = int.tryParse(parts[0]) ?? 1;
    final m = int.tryParse(parts[1]) ?? 1;
    final y = int.tryParse(parts[2]) ?? DateTime.now().year;
    final birth = DateTime(y, m, d);
    final now = DateTime.now();
    int age = now.year - birth.year;
    final hadBirthday =
        (now.month > birth.month) ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) age -= 1;
    return age < 0 ? 0 : age;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uri = _buildUri('/api/patient-profile', {'login': widget.username});
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;
        final fullName = ((map['fullName'] ?? '') as String).trim();
        final dob = ((map['dob'] ?? '') as String).trim();
        final age = dob.isNotEmpty ? _ageFromDob(dob) : null;
        if (!mounted) return;
        setState(() {
          _displayName = fullName.isEmpty ? widget.username : fullName;
          _age = age;
          _loading = false;
        });
      } else if (resp.statusCode == 404) {
        if (!mounted) return;
        setState(() {
          _displayName = widget.username;
          _age = null;
          _loading = false;
          _error = 'Profile not found';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _displayName = widget.username;
          _age = null;
          _loading = false;
          _error = 'Failed: ${resp.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _displayName = widget.username;
        _age = null;
        _loading = false;
        _error = 'Network error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ageText = _age == null ? '—' : _age.toString();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Health Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: GcColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFFF1F5F9),
                ),
                child: const Icon(Icons.person, color: GcColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child:
                    _loading
                        ? const Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: GcColors.textSecondary,
                          ),
                        )
                        : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: GcColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Age: $ageText',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: GcColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: GcColors.softBlue,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD6E4FF)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: GcColors.primaryBlue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _error == null ? 'Critical Health Alerts: None' : _error!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GcColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Quick Actions ----------
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onMedicines;
  final VoidCallback onSymptoms;

  const _QuickActionsRow({
    required this.onBook,
    required this.onMedicines,
    required this.onSymptoms,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isVeryNarrow = c.maxWidth < 320;
        if (isVeryNarrow) {
          return Column(
            children: [
              _QuickSquareCard(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Symptoms',
                onPressed: onSymptoms,
              ),
              const SizedBox(height: 8),
              _QuickSquareCard(
                icon: Icons.medication_outlined,
                label: 'Medicines',
                onPressed: onMedicines,
              ),
              const SizedBox(height: 8),
              _QuickSquareCard(
                icon: Icons.add_circle_outline,
                label: 'Book',
                onPressed: onBook,
              ),
            ],
          );
        }
        return Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: _QuickSquareCard(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Symptom \nchecker',
                onPressed: onSymptoms,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickSquareCard(
                icon: Icons.medication_outlined,
                label: 'Medicines',
                onPressed: onMedicines,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickSquareCard(
                icon: Icons.add_circle_outline,
                label: 'Book',
                onPressed: onBook,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickSquareCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickSquareCard({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            color: GcColors.softBlue,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD6E4FF)),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: GcColors.iconBlueBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: GcColors.primaryBlue, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: GcColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Upcoming Appointment ----------
class _UpcomingAppointmentCard extends StatelessWidget {
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const _UpcomingAppointmentCard({
    required this.onReschedule,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: GcColors.iconBlueBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: GcColors.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. Singh',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: GcColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'August 10, 2024',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: GcColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _pillButton(
                  label: 'Reschedule',
                  background: GcColors.pillBlue,
                  textColor: GcColors.primaryBlue,
                  onTap: onReschedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pillButton(
                  label: 'Cancel',
                  background: GcColors.softBlue,
                  textColor: GcColors.textPrimary,
                  onTap: onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pillButton({
    required String label,
    required Color background,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: Color(0xFFD6E4FF)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ---------- Recent Consultations ----------
class _RecentConsultationItem extends StatelessWidget {
  final String name;
  final String date;
  final VoidCallback onTap;

  const _RecentConsultationItem({
    required this.name,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: GcColors.iconBlueBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.history,
                color: GcColors.primaryBlue,
                size: 20,
              ),
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
                      fontWeight: FontWeight.w700,
                      color: GcColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: GcColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: GcColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ---------- Notifications ----------
class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _NotificationTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GcColors.iconBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: GcColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GcColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Health Record Snapshot ----------
class _HealthRecordSnapshot extends StatelessWidget {
  final VoidCallback? onRecords;
  final String username;

  const _HealthRecordSnapshot({required this.username, this.onRecords});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: GcColors.iconBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              color: GcColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Prescription: 2024-07-20',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GcColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/health_records',
                      arguments: username,
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'View Full Records',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GcColors.primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Health Hub Widget (replaces Featured Education) ----------
class _HealthHubWidget extends StatelessWidget {
  final String username;

  const _HealthHubWidget({required this.username});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // Navigate to HealthHubApp
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HealthHubApp()),
          );
        },
        child: Container(
          height: 140,
          width: 660,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                GcColors.softBlue,
                GcColors.primaryBlue.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.health_and_safety_outlined,
                  color: GcColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Health Hub',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Access health resources and education',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Language ----------
class _LanguageRow extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _LanguageRow({required this.onChanged});

  @override
  State<_LanguageRow> createState() => _LanguageRowState();
}

class _LanguageRowState extends State<_LanguageRow> {
  String selected = 'English';

  void _select(String lang) {
    setState(() => selected = lang);
    widget.onChanged(lang);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LangPill(
          text: 'Punjabi',
          selected: selected == 'Punjabi',
          onTap: () => _select('Punjabi'),
        ),
        const SizedBox(width: 12),
        _LangPill(
          text: 'Hindi',
          selected: selected == 'Hindi',
          onTap: () => _select('Hindi'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LangPill(
            text: 'English',
            selected: selected == 'English',
            onTap: () => _select('English'),
            expand: true,
          ),
        ),
      ],
    );
  }
}

class _LangPill extends StatelessWidget {
  final String text;
  final bool selected;
  final bool expand;
  final VoidCallback onTap;

  const _LangPill({
    required this.text,
    required this.selected,
    required this.onTap,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? GcColors.primaryBlue : GcColors.card;
    final border = selected ? GcColors.primaryBlue : GcColors.border;
    final fg = selected ? Colors.white : GcColors.textPrimary;
    final pill = InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(
              color: GcColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
    return expand ? pill : SizedBox(width: 108, child: pill);
  }
}
