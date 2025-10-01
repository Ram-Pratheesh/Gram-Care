// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:gramcare/frontend/patients/patientappoinment1.dart';
// import 'package:gramcare/frontend/patients/telemedicine_consultation.dart';
// import 'package:http/http.dart' as http;

// // ====================== Custom Date Parsing ======================
// DateTime parseCustomDate(String dateStr) {
//   final parts = dateStr.split(' ');
//   if (parts.length == 2) {
//     final day = int.tryParse(parts[0]);
//     final monthStr = parts[1].toLowerCase();

//     final months = {
//       'january': 1,
//       'february': 2,
//       'march': 3,
//       'april': 4,
//       'may': 5,
//       'june': 6,
//       'july': 7,
//       'august': 8,
//       'september': 9,
//       'october': 10,
//       'november': 11,
//       'december': 12,
//     };

//     final month = months[monthStr];
//     if (day != null && month != null) {
//       final year = DateTime.now().year;
//       return DateTime(year, month, day);
//     }
//   }
//   throw FormatException('Invalid date format: $dateStr');
// }

// // ====================== Data Model ======================
// class AppointmentDto {
//   final String patientLogin;
//   final String doctorId;
//   final String doctorName;
//   final String doctorSpecialty;
//   final String appointmentDate; // Expected backend format like "20 September"
//   final String appointmentTime;
//   final String slotLabel;
//   final String mode;
//   final String? status;

//   AppointmentDto({
//     required this.patientLogin,
//     required this.doctorId,
//     required this.doctorName,
//     required this.doctorSpecialty,
//     required this.appointmentDate,
//     required this.appointmentTime,
//     required this.slotLabel,
//     required this.mode,
//     this.status,
//   });

//   factory AppointmentDto.fromJson(Map<String, dynamic> j) {
//     return AppointmentDto(
//       patientLogin: (j['patientLogin'] ?? '') as String,
//       doctorId: (j['doctorId'] ?? '') as String,
//       doctorName: (j['doctorName'] ?? '') as String,
//       doctorSpecialty: (j['doctorSpecialty'] ?? '') as String,
//       appointmentDate: (j['appointmentDate'] ?? '') as String,
//       appointmentTime: (j['appointmentTime'] ?? '') as String,
//       slotLabel: (j['slotLabel'] ?? '') as String,
//       mode: (j['mode'] ?? '') as String,
//       status: j['status'] as String?,
//     );
//   }

//   // Map to the UI card props used by your widgets
//   String get dateTimeTitle => '$appointmentDate, $appointmentTime';
//   String get doctor => doctorName;
//   String get statusText => status ?? 'Confirmed';
//   bool get isOngoing => statusText.toLowerCase() == 'ongoing';
//   bool get isCompleted => statusText.toLowerCase() == 'completed';
//   bool get isCancelled => statusText.toLowerCase() == 'cancelled';

//   DateTime get appointmentDateTime => parseCustomDate(appointmentDate);

//   // Create a copy with updated status
//   AppointmentDto copyWith({
//     String? patientLogin,
//     String? doctorId,
//     String? doctorName,
//     String? doctorSpecialty,
//     String? appointmentDate,
//     String? appointmentTime,
//     String? slotLabel,
//     String? mode,
//     String? status,
//   }) {
//     return AppointmentDto(
//       patientLogin: patientLogin ?? this.patientLogin,
//       doctorId: doctorId ?? this.doctorId,
//       doctorName: doctorName ?? this.doctorName,
//       doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
//       appointmentDate: appointmentDate ?? this.appointmentDate,
//       appointmentTime: appointmentTime ?? this.appointmentTime,
//       slotLabel: slotLabel ?? this.slotLabel,
//       mode: mode ?? this.mode,
//       status: status ?? this.status,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'patientLogin': patientLogin,
//       'doctorId': doctorId,
//       'doctorName': doctorName,
//       'doctorSpecialty': doctorSpecialty,
//       'appointmentDate': appointmentDate,
//       'appointmentTime': appointmentTime,
//       'slotLabel': slotLabel,
//       'mode': mode,
//       'status': status,
//     };
//   }

//   // Generate a unique identifier for this appointment
//   String get uniqueId =>
//       '$patientLogin-$doctorId-$appointmentDate-$appointmentTime';
// }

// // ====================== API Client ======================
// class ApptApi {
//   final String baseUrl;
//   ApptApi(this.baseUrl);

//   Future<List<AppointmentDto>> fetchAppointments(String patientLogin) async {
//     final uri = Uri.parse(
//       '$baseUrl/api/appointments',
//     ).replace(queryParameters: {'patientLogin': patientLogin});
//     final res = await http.get(uri);
//     if (res.statusCode != 200) {
//       throw Exception('Failed to load appointments: ${res.statusCode}');
//     }
//     final Map<String, dynamic> body = json.decode(res.body);
//     final List list = body['appointments'] as List? ?? [];
//     return list
//         .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
//         .toList();
//   }

//   Future<void> updateAppointmentStatus(
//     AppointmentDto appointment,
//     String newStatus,
//   ) async {
//     final uri = Uri.parse('$baseUrl/api/appointment/update');
//     final response = await http.patch(
//       uri,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'patientLogin': appointment.patientLogin,
//         'doctorId': appointment.doctorId,
//         'appointmentDate': appointment.appointmentDate,
//         'appointmentTime': appointment.appointmentTime,
//         'status': newStatus,
//       }),
//     );

//     if (response.statusCode != 200) {
//       throw Exception(
//         'Failed to update appointment status: ${response.statusCode}',
//       );
//     }
//   }
// }

// // ====================== UI Widgets ======================
// class AppointmentsScreen extends StatefulWidget {
//   final String username;
//   const AppointmentsScreen({super.key, required this.username});

//   @override
//   State<AppointmentsScreen> createState() => _AppointmentsScreenState();
// }

// class _AppointmentsScreenState extends State<AppointmentsScreen>
//     with SingleTickerProviderStateMixin {
//   late final TabController _tab;
//   late Future<List<AppointmentDto>> _future;

//   // Store appointments locally for optimistic updates
//   List<AppointmentDto> _appointments = [];
//   bool _isLoading = true;
//   String? _error;

//   final ApptApi api = ApptApi('http://192.168.137.1:4001');

//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 3, vsync: this);
//     _loadAppointments();
//   }

//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }

//   // Load appointments and store locally
//   void _loadAppointments() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final appointments = await api.fetchAppointments(widget.username);
//       setState(() {
//         _appointments = appointments;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   void _refresh() {
//     _loadAppointments();
//   }

//   void _snack(String m) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(m, style: const TextStyle(fontWeight: FontWeight.w800)),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: const Color(0xFF0A84FF),
//         duration: const Duration(milliseconds: 900),
//       ),
//     );
//   }

//   // Optimistically update appointment status locally
//   void _updateAppointmentOptimistically(
//     AppointmentDto appointment,
//     String newStatus,
//   ) {
//     setState(() {
//       final index = _appointments.indexWhere(
//         (a) => a.uniqueId == appointment.uniqueId,
//       );
//       if (index != -1) {
//         _appointments[index] = appointment.copyWith(status: newStatus);
//       }
//     });
//   }

//   // Revert optimistic update if API call fails
//   void _revertOptimisticUpdate(AppointmentDto originalAppointment) {
//     setState(() {
//       final index = _appointments.indexWhere(
//         (a) => a.uniqueId == originalAppointment.uniqueId,
//       );
//       if (index != -1) {
//         _appointments[index] = originalAppointment;
//       }
//     });
//   }

//   void _editAppointmentFromApi(AppointmentDto a) async {
//     _snack('Open reschedule flow (implement API)');
//   }

//   void _cancelUpcomingFromApi(AppointmentDto a) async {
//     // Store original for potential rollback
//     final originalAppointment = a;

//     // Optimistically update UI
//     _updateAppointmentOptimistically(a, 'Cancelled');
//     _snack('Cancelling appointment...');

//     try {
//       await api.updateAppointmentStatus(a, 'Cancelled');
//       _snack('Appointment cancelled successfully');
//     } catch (e) {
//       // Revert optimistic update on failure
//       _revertOptimisticUpdate(originalAppointment);
//       _snack('Failed to cancel appointment: ${e.toString()}');
//     }
//   }

//   void _attendPresentFromApi(AppointmentDto a) async {
//     // Store original for potential rollback
//     final originalAppointment = a;

//     // Optimistically update UI immediately - move to completed
//     _updateAppointmentOptimistically(a, 'Completed');

//     try {
//       // Navigate to ConsultationScreen
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder:
//               (context) => ConsultationScreen(
//                 appointment: a,
//                 patientUsername: widget.username,
//               ),
//         ),
//       );

//       // Update status on server regardless of consultation result
//       await api.updateAppointmentStatus(a, 'Completed');
//       _snack('Consultation completed successfully');
//     } catch (e) {
//       // Revert optimistic update on failure
//       _revertOptimisticUpdate(originalAppointment);
//       _snack('Failed to complete consultation: ${e.toString()}');
//     }
//   }

//   void _cancelPresentFromApi(AppointmentDto a) async {
//     // Store original for potential rollback
//     final originalAppointment = a;

//     // Optimistically update UI
//     _updateAppointmentOptimistically(a, 'Cancelled');
//     _snack('Cancelling present appointment...');

//     try {
//       await api.updateAppointmentStatus(a, 'Cancelled');
//       _snack('Present appointment cancelled');
//     } catch (e) {
//       // Revert optimistic update on failure
//       _revertOptimisticUpdate(originalAppointment);
//       _snack('Failed to cancel present appointment: ${e.toString()}');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bookButton = SafeArea(
//       minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//       child: PrimaryCtaButton(
//         label: 'Book New Appointment',
//         icon: Icons.add_circle_outline,
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (context) => BookAppointmentFlow(username: widget.username),
//             ),
//           );
//         },
//       ),
//     );

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFFF6F7FB),
//         foregroundColor: const Color(0xFF111827),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: const Text(
//           'Appointments',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.2,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings_outlined),
//             onPressed: () {
//               Navigator.pushNamed(
//                 context,
//                 '/settings',
//                 arguments: widget.username,
//               );
//             },
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(44),
//           child: Align(
//             alignment: Alignment.centerLeft,
//             child: TabBar(
//               controller: _tab,
//               isScrollable: true,
//               indicatorColor: const Color(0xFF0A84FF),
//               labelColor: const Color(0xFF0A84FF),
//               unselectedLabelColor: const Color(0xFF6B7280),
//               labelStyle: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w800,
//               ),
//               unselectedLabelStyle: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w700,
//               ),
//               tabs: const [
//                 Tab(text: 'Upcoming'),
//                 Tab(text: 'Present'),
//                 Tab(text: 'Past'),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: Builder(
//         builder: (context) {
//           if (_isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (_error != null) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.error_outline, color: Colors.red),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Failed to load: $_error',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                     const SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: _refresh,
//                       child: const Text('Retry'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final now = DateTime.now();
//           final today = DateTime(now.year, now.month, now.day);

//           final present =
//               _appointments.where((a) {
//                 final d = a.appointmentDateTime;
//                 final ad = DateTime(d.year, d.month, d.day);
//                 return ad == today && !a.isCompleted && !a.isCancelled;
//               }).toList();

//           final past =
//               _appointments.where((a) {
//                 final d = a.appointmentDateTime;
//                 final ad = DateTime(d.year, d.month, d.day);
//                 return ad.isBefore(today) || a.isCompleted || a.isCancelled;
//               }).toList();

//           final upcoming =
//               _appointments.where((a) {
//                 final d = a.appointmentDateTime;
//                 final ad = DateTime(d.year, d.month, d.day);
//                 return ad.isAfter(today) && !a.isCancelled;
//               }).toList();

//           Widget buildUpcoming() {
//             if (upcoming.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.event_available, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No upcoming appointments',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               itemCount: upcoming.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (context, i) {
//                 final a = upcoming[i];
//                 final isConfirmed = a.statusText == 'Confirmed';
//                 return AppointmentCard(
//                   dateTimeTitle: a.dateTimeTitle,
//                   doctor: a.doctor,
//                   statusText: a.statusText,
//                   statusBg:
//                       isConfirmed
//                           ? const Color(0xFFE6F6E9)
//                           : const Color(0xFFFFF6D9),
//                   statusFg:
//                       isConfirmed
//                           ? const Color(0xFF188038)
//                           : const Color(0xFF9A6700),
//                   onReschedule: () => _editAppointmentFromApi(a),
//                   onCancel: () => _cancelUpcomingFromApi(a),
//                 );
//               },
//             );
//           }

//           Widget buildPresent() {
//             if (present.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.access_time, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No appointments today',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               itemCount: present.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (context, i) {
//                 final a = present[i];
//                 return AppointmentCard.present(
//                   dateTimeTitle: a.dateTimeTitle,
//                   doctor: a.doctor,
//                   statusText: 'Ongoing',
//                   statusBg: const Color(0xFFE8F2FF),
//                   statusFg: const Color(0xFF0A84FF),
//                   onAttend: () => _attendPresentFromApi(a),
//                   onCancel: () => _cancelPresentFromApi(a),
//                 );
//               },
//             );
//           }

//           Widget buildPast() {
//             if (past.isEmpty) {
//               return const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.history, size: 64, color: Colors.grey),
//                     SizedBox(height: 16),
//                     Text(
//                       'No past appointments',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               itemCount: past.length,
//               separatorBuilder: (_, __) => const SizedBox(height: 16),
//               itemBuilder: (context, i) {
//                 final a = past[i];
//                 final isCompleted = a.isCompleted;
//                 return AppointmentCard(
//                   dateTimeTitle: a.dateTimeTitle,
//                   doctor: a.doctor,
//                   statusText: a.statusText,
//                   statusBg:
//                       isCompleted
//                           ? const Color(0xFFE8F2FF)
//                           : const Color(0xFFFDE2E0),
//                   statusFg:
//                       isCompleted
//                           ? const Color(0xFF0A84FF)
//                           : const Color(0xFFB42318),
//                   showActions: false,
//                 );
//               },
//             );
//           }

//           return Stack(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 76),
//                 child: TabBarView(
//                   controller: _tab,
//                   children: [buildUpcoming(), buildPresent(), buildPast()],
//                 ),
//               ),
//               Align(alignment: Alignment.bottomCenter, child: bookButton),
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1,
//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacementNamed(
//               context,
//               '/',
//               arguments: widget.username,
//             );
//           } else if (index == 2) {
//             Navigator.pushReplacementNamed(
//               context,
//               '/profile',
//               arguments: widget.username,
//             );
//           }
//         },
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFF0A84FF),
//         unselectedItemColor: const Color(0xFF94A3B8),
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
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

// // ====================== Reuse your existing UI components ======================

// class AppointmentCard extends StatelessWidget {
//   final String dateTimeTitle;
//   final String doctor;
//   final String statusText;
//   final Color statusBg;
//   final Color statusFg;
//   final VoidCallback? onReschedule;
//   final VoidCallback? onCancel;
//   final bool showActions;
//   final VoidCallback? onAttend;

//   const AppointmentCard({
//     super.key,
//     required this.dateTimeTitle,
//     required this.doctor,
//     required this.statusText,
//     required this.statusBg,
//     required this.statusFg,
//     this.onReschedule,
//     this.onCancel,
//     this.showActions = true,
//     this.onAttend,
//   });

//   factory AppointmentCard.present({
//     Key? key,
//     required String dateTimeTitle,
//     required String doctor,
//     required String statusText,
//     required Color statusBg,
//     required Color statusFg,
//     required VoidCallback onAttend,
//     required VoidCallback onCancel,
//   }) {
//     return AppointmentCard(
//       key: key,
//       dateTimeTitle: dateTimeTitle,
//       doctor: doctor,
//       statusText: statusText,
//       statusBg: statusBg,
//       statusFg: statusFg,
//       onAttend: onAttend,
//       onCancel: onCancel,
//       showActions: true,
//       onReschedule: null,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isPresent = onAttend != null;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x14000000),
//             blurRadius: 12,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(
//               left: 16,
//               right: 16,
//               top: 16,
//               bottom: 12,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const _IconBadge(
//                   icon: Icons.calendar_month_outlined,
//                   bg: Color(0xFFE8F2FF),
//                   fg: Color(0xFF0A84FF),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         dateTimeTitle,
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w800,
//                           height: 1.1,
//                           color: Color(0xFF0F172A),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         doctor,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF64748B),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 _StatusPill(text: statusText, bg: statusBg, fg: statusFg),
//               ],
//             ),
//           ),
//           if (showActions)
//             Container(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(
//                   bottom: Radius.circular(18),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: _SoftButton(
//                       label: isPresent ? 'Attend' : 'Reschedule',
//                       color: const Color(0xFFD7EAF9),
//                       labelColor: const Color(0xFF0B6FB3),
//                       onTap: isPresent ? onAttend : onReschedule,
//                     ),
//                   ),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: _SoftButton(
//                       label: 'Cancel',
//                       color: const Color(0xFFF8D7D6),
//                       labelColor: const Color(0xFFB42318),
//                       onTap: onCancel,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class _IconBadge extends StatelessWidget {
//   final IconData icon;
//   final Color bg;
//   final Color fg;
//   const _IconBadge({required this.icon, required this.bg, required this.fg});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 56,
//       height: 56,
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(28),
//       ),
//       child: Icon(icon, color: fg, size: 28),
//     );
//   }
// }

// class _StatusPill extends StatelessWidget {
//   final String text;
//   final Color bg;
//   final Color fg;
//   const _StatusPill({required this.text, required this.bg, required this.fg});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(22),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: fg, fontWeight: FontWeight.w800),
//       ),
//     );
//   }
// }

// class _SoftButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color labelColor;
//   final VoidCallback? onTap;

//   const _SoftButton({
//     required this.label,
//     required this.color,
//     required this.labelColor,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 46,
//       child: TextButton(
//         onPressed: onTap,
//         style: TextButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//             side: const BorderSide(color: Color(0xFFE5E7EB)),
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: labelColor,
//             fontWeight: FontWeight.w800,
//             fontSize: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class PrimaryCtaButton extends StatelessWidget {
//   final String label;
//   final IconData? icon;
//   final VoidCallback onPressed;
//   const PrimaryCtaButton({
//     super.key,
//     required this.label,
//     required this.onPressed,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Color(0x1A000000),
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: SizedBox(
//         height: 56,
//         width: double.infinity,
//         child: ElevatedButton.icon(
//           onPressed: onPressed,
//           icon:
//               icon == null
//                   ? const SizedBox.shrink()
//                   : Icon(icon, color: Colors.white),
//           label: Text(
//             label,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w800,
//               letterSpacing: 0.2,
//             ),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF0A84FF),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             elevation: 0,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gramcare/frontend/patients/patientappoinment1.dart';
import 'package:gramcare/frontend/patients/telemedicine_consultation.dart';
import 'package:http/http.dart' as http;

// ====================== Custom Date Parsing ======================
DateTime parseCustomDate(String dateStr) {
  final parts = dateStr.split(' ');
  if (parts.length == 2) {
    final day = int.tryParse(parts[0]);
    final monthStr = parts[1].toLowerCase();

    final months = {
      'january': 1,
      'february': 2,
      'march': 3,
      'april': 4,
      'may': 5,
      'june': 6,
      'july': 7,
      'august': 8,
      'september': 9,
      'october': 10,
      'november': 11,
      'december': 12,
    };

    final month = months[monthStr];
    if (day != null && month != null) {
      final year = DateTime.now().year;
      return DateTime(year, month, day);
    }
  }
  throw FormatException('Invalid date format: $dateStr');
}

// ====================== Data Model ======================
class AppointmentDto {
  final String patientLogin;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String appointmentDate; // Expected backend format like "20 September"
  final String appointmentTime;
  final String slotLabel;
  final String mode;
  final String? status;

  AppointmentDto({
    required this.patientLogin,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.slotLabel,
    required this.mode,
    this.status,
  });

  factory AppointmentDto.fromJson(Map<String, dynamic> j) {
    return AppointmentDto(
      patientLogin: (j['patientLogin'] ?? '') as String,
      doctorId: (j['doctorId'] ?? '') as String,
      doctorName: (j['doctorName'] ?? '') as String,
      doctorSpecialty: (j['doctorSpecialty'] ?? '') as String,
      appointmentDate: (j['appointmentDate'] ?? '') as String,
      appointmentTime: (j['appointmentTime'] ?? '') as String,
      slotLabel: (j['slotLabel'] ?? '') as String,
      mode: (j['mode'] ?? '') as String,
      status: j['status'] as String?,
    );
  }

  // Map to the UI card props used by your widgets
  String get dateTimeTitle => '$appointmentDate, $appointmentTime';
  String get doctor => doctorName;
  String get statusText => status ?? 'Confirmed';
  bool get isOngoing => statusText.toLowerCase() == 'ongoing';
  bool get isCompleted => statusText.toLowerCase() == 'completed';
  bool get isCancelled => statusText.toLowerCase() == 'cancelled';

  DateTime get appointmentDateTime => parseCustomDate(appointmentDate);

  // Create a copy with updated status
  AppointmentDto copyWith({
    String? patientLogin,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? appointmentDate,
    String? appointmentTime,
    String? slotLabel,
    String? mode,
    String? status,
  }) {
    return AppointmentDto(
      patientLogin: patientLogin ?? this.patientLogin,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      appointmentTime: appointmentTime ?? this.appointmentTime,
      slotLabel: slotLabel ?? this.slotLabel,
      mode: mode ?? this.mode,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientLogin': patientLogin,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'appointmentDate': appointmentDate,
      'appointmentTime': appointmentTime,
      'slotLabel': slotLabel,
      'mode': mode,
      'status': status,
    };
  }

  // Generate a unique identifier for this appointment
  String get uniqueId =>
      '$patientLogin-$doctorId-$appointmentDate-$appointmentTime';
}

// ====================== API Client ======================
class ApptApi {
  final String baseUrl;
  ApptApi(this.baseUrl);

  Future<List<AppointmentDto>> fetchAppointments(String patientLogin) async {
    final uri = Uri.parse(
      '$baseUrl/api/appointments',
    ).replace(queryParameters: {'patientLogin': patientLogin});
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load appointments: ${res.statusCode}');
    }
    final Map<String, dynamic> body = json.decode(res.body);
    final List list = body['appointments'] as List? ?? [];
    return list
        .map((e) => AppointmentDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateAppointmentStatus(
    AppointmentDto appointment,
    String newStatus,
  ) async {
    final uri = Uri.parse('$baseUrl/api/appointment/update');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'patientLogin': appointment.patientLogin,
        'doctorId': appointment.doctorId,
        'appointmentDate': appointment.appointmentDate,
        'appointmentTime': appointment.appointmentTime,
        'status': newStatus,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update appointment status: ${response.statusCode}',
      );
    }
  }
}

// ====================== UI Widgets ======================
class AppointmentsScreen extends StatefulWidget {
  final String username;
  const AppointmentsScreen({super.key, required this.username});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late Future<List<AppointmentDto>> _future;

  // Store appointments locally for optimistic updates
  List<AppointmentDto> _appointments = [];
  bool _isLoading = true;
  String? _error;

  final ApptApi api = ApptApi('http://192.168.137.1:4001');

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  // Load appointments and store locally
  void _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointments = await api.fetchAppointments(widget.username);
      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refresh() {
    _loadAppointments();
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontWeight: FontWeight.w800)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0A84FF),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  // Optimistically update appointment status locally
  void _updateAppointmentOptimistically(
    AppointmentDto appointment,
    String newStatus,
  ) {
    setState(() {
      final index = _appointments.indexWhere(
        (a) => a.uniqueId == appointment.uniqueId,
      );
      if (index != -1) {
        _appointments[index] = appointment.copyWith(status: newStatus);
      }
    });
  }

  // Revert optimistic update if API call fails
  void _revertOptimisticUpdate(AppointmentDto originalAppointment) {
    setState(() {
      final index = _appointments.indexWhere(
        (a) => a.uniqueId == originalAppointment.uniqueId,
      );
      if (index != -1) {
        _appointments[index] = originalAppointment;
      }
    });
  }

  void _editAppointmentFromApi(AppointmentDto a) async {
    _snack('Open reschedule flow (implement API)');
  }

  void _cancelUpcomingFromApi(AppointmentDto a) async {
    // Store original for potential rollback
    final originalAppointment = a;

    // Optimistically update UI
    _updateAppointmentOptimistically(a, 'Cancelled');
    _snack('Cancelling appointment...');

    try {
      await api.updateAppointmentStatus(a, 'Cancelled');
      _snack('Appointment cancelled successfully');
    } catch (e) {
      // Revert optimistic update on failure
      _revertOptimisticUpdate(originalAppointment);
      _snack('Failed to cancel appointment: ${e.toString()}');
    }
  }

  void _attendPresentFromApi(AppointmentDto a) async {
    // Store original for potential rollback
    final originalAppointment = a;

    // Optimistically update UI immediately - move to completed
    _updateAppointmentOptimistically(a, 'Completed');

    try {
      // Navigate to ConsultationScreen with all appointment details
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => VideoConsultationScreen(
                // Pass complete appointment object
                appointment: a,
                patientUsername: widget.username,
                // Additional parameters that might be useful
                doctorName: a.doctorName,
                doctorSpecialty: a.doctorSpecialty,
                appointmentDate: a.appointmentDate,
                appointmentTime: a.appointmentTime,
                appointmentMode: a.mode,
                slotLabel: a.slotLabel,
                doctorId: a.doctorId,
              ),
        ),
      );

      // Update status on server regardless of consultation result
      await api.updateAppointmentStatus(a, 'Completed');
      _snack('Consultation completed successfully');
    } catch (e) {
      // Revert optimistic update on failure
      _revertOptimisticUpdate(originalAppointment);
      _snack('Failed to complete consultation: ${e.toString()}');
    }
  }

  void _cancelPresentFromApi(AppointmentDto a) async {
    // Store original for potential rollback
    final originalAppointment = a;

    // Optimistically update UI
    _updateAppointmentOptimistically(a, 'Cancelled');
    _snack('Cancelling present appointment...');

    try {
      await api.updateAppointmentStatus(a, 'Cancelled');
      _snack('Present appointment cancelled');
    } catch (e) {
      // Revert optimistic update on failure
      _revertOptimisticUpdate(originalAppointment);
      _snack('Failed to cancel present appointment: ${e.toString()}');
    }
  }

  // Method to view appointment details (can be used for past appointments)
  void _viewAppointmentDetails(AppointmentDto a) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AppointmentDetailsScreen(
              appointment: a,
              patientUsername: widget.username,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookButton = SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: PrimaryCtaButton(
        label: 'Book New Appointment',
        icon: Icons.add_circle_outline,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookAppointmentFlow(username: widget.username),
            ),
          );
        },
      ),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: const Color(0xFF111827),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Appointments',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/settings',
                arguments: widget.username,
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tab,
              isScrollable: true,
              indicatorColor: const Color(0xFF0A84FF),
              labelColor: const Color(0xFF0A84FF),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Present'),
                Tab(text: 'Past'),
              ],
            ),
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final present =
              _appointments.where((a) {
                final d = a.appointmentDateTime;
                final ad = DateTime(d.year, d.month, d.day);
                return ad == today && !a.isCompleted && !a.isCancelled;
              }).toList();

          final past =
              _appointments.where((a) {
                final d = a.appointmentDateTime;
                final ad = DateTime(d.year, d.month, d.day);
                return ad.isBefore(today) || a.isCompleted || a.isCancelled;
              }).toList();

          final upcoming =
              _appointments.where((a) {
                final d = a.appointmentDateTime;
                final ad = DateTime(d.year, d.month, d.day);
                return ad.isAfter(today) && !a.isCancelled;
              }).toList();

          Widget buildUpcoming() {
            if (upcoming.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No upcoming appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final a = upcoming[i];
                final isConfirmed = a.statusText == 'Confirmed';
                return AppointmentCard(
                  dateTimeTitle: a.dateTimeTitle,
                  doctor: a.doctor,
                  statusText: a.statusText,
                  statusBg:
                      isConfirmed
                          ? const Color(0xFFE6F6E9)
                          : const Color(0xFFFFF6D9),
                  statusFg:
                      isConfirmed
                          ? const Color(0xFF188038)
                          : const Color(0xFF9A6700),
                  onReschedule: () => _editAppointmentFromApi(a),
                  onCancel: () => _cancelUpcomingFromApi(a),
                  onTap: () => _viewAppointmentDetails(a), // Add tap handler
                );
              },
            );
          }

          Widget buildPresent() {
            if (present.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No appointments today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: present.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final a = present[i];
                return AppointmentCard.present(
                  dateTimeTitle: a.dateTimeTitle,
                  doctor: a.doctor,
                  statusText: 'Ongoing',
                  statusBg: const Color(0xFFE8F2FF),
                  statusFg: const Color(0xFF0A84FF),
                  onAttend: () => _attendPresentFromApi(a),
                  onCancel: () => _cancelPresentFromApi(a),
                  onTap: () => _viewAppointmentDetails(a), // Add tap handler
                );
              },
            );
          }

          Widget buildPast() {
            if (past.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No past appointments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: past.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final a = past[i];
                final isCompleted = a.isCompleted;
                return AppointmentCard(
                  dateTimeTitle: a.dateTimeTitle,
                  doctor: a.doctor,
                  statusText: a.statusText,
                  statusBg:
                      isCompleted
                          ? const Color(0xFFE8F2FF)
                          : const Color(0xFFFDE2E0),
                  statusFg:
                      isCompleted
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFFB42318),
                  showActions: false,
                  onTap: () => _viewAppointmentDetails(a), // Add tap handler
                );
              },
            );
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 76),
                child: TabBarView(
                  controller: _tab,
                  children: [buildUpcoming(), buildPresent(), buildPast()],
                ),
              ),
              Align(alignment: Alignment.bottomCenter, child: bookButton),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              '/',
              arguments: widget.username,
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/profile',
              arguments: widget.username,
            );
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0A84FF),
        unselectedItemColor: const Color(0xFF94A3B8),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
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

// ====================== Reuse your existing UI components ======================

class AppointmentCard extends StatelessWidget {
  final String dateTimeTitle;
  final String doctor;
  final String statusText;
  final Color statusBg;
  final Color statusFg;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final bool showActions;
  final VoidCallback? onAttend;
  final VoidCallback? onTap; // Add tap callback for card interaction

  const AppointmentCard({
    super.key,
    required this.dateTimeTitle,
    required this.doctor,
    required this.statusText,
    required this.statusBg,
    required this.statusFg,
    this.onReschedule,
    this.onCancel,
    this.showActions = true,
    this.onAttend,
    this.onTap,
  });

  factory AppointmentCard.present({
    Key? key,
    required String dateTimeTitle,
    required String doctor,
    required String statusText,
    required Color statusBg,
    required Color statusFg,
    required VoidCallback onAttend,
    required VoidCallback onCancel,
    VoidCallback? onTap,
  }) {
    return AppointmentCard(
      key: key,
      dateTimeTitle: dateTimeTitle,
      doctor: doctor,
      statusText: statusText,
      statusBg: statusBg,
      statusFg: statusFg,
      onAttend: onAttend,
      onCancel: onCancel,
      showActions: true,
      onReschedule: null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPresent = onAttend != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _IconBadge(
                    icon: Icons.calendar_month_outlined,
                    bg: Color(0xFFE8F2FF),
                    fg: Color(0xFF0A84FF),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateTimeTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          doctor,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusPill(text: statusText, bg: statusBg, fg: statusFg),
                ],
              ),
            ),
            if (showActions)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(18),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SoftButton(
                        label: isPresent ? 'Attend' : 'Reschedule',
                        color: const Color(0xFFD7EAF9),
                        labelColor: const Color(0xFF0B6FB3),
                        onTap: isPresent ? onAttend : onReschedule,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _SoftButton(
                        label: 'Cancel',
                        color: const Color(0xFFF8D7D6),
                        labelColor: const Color(0xFFB42318),
                        onTap: onCancel,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ====================== Appointment Details Screen ======================
class AppointmentDetailsScreen extends StatelessWidget {
  final AppointmentDto appointment;
  final String patientUsername;

  const AppointmentDetailsScreen({
    super.key,
    required this.appointment,
    required this.patientUsername,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: const Color(0xFFF6F7FB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doctor: ${appointment.doctorName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Specialty: ${appointment.doctorSpecialty}'),
                    Text('Date: ${appointment.appointmentDate}'),
                    Text('Time: ${appointment.appointmentTime}'),
                    Text('Mode: ${appointment.mode}'),
                    Text('Status: ${appointment.statusText}'),
                    Text('Slot: ${appointment.slotLabel}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _IconBadge({required this.icon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Icon(icon, color: fg, size: 28),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _StatusPill({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color labelColor;
  final VoidCallback? onTap;

  const _SoftButton({
    required this.label,
    required this.color,
    required this.labelColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon:
              icon == null
                  ? const SizedBox.shrink()
                  : Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A84FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
