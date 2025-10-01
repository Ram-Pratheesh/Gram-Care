// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// void main() => runApp(const BookAppointmentFlow(username: 'JohnDoe'));

// class BookAppointmentFlow extends StatelessWidget {
//   final String username;
//   const BookAppointmentFlow({super.key, required this.username});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Book Appointment',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'SFPro',
//         scaffoldBackgroundColor: const Color(0xFFF6F7FB),
//         useMaterial3: false,
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//           titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
//           bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//           bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
//         ),
//       ),
//       home: SelectDoctorStep(username: username),
//     );
//   }
// }

// /* --------------------- STEP 1: Select Doctor --------------------- */

// class SelectDoctorStep extends StatefulWidget {
//   final String username;
//   const SelectDoctorStep({Key? key, required this.username}) : super(key: key);

//   @override
//   State<SelectDoctorStep> createState() => _SelectDoctorStepState();
// }

// class Doctor {
//   final String name;
//   final String specialty;
//   final double rating;
//   final int reviews;
//   final String? avatarAsset;
//   final String about;

//   Doctor({
//     required this.name,
//     required this.specialty,
//     required this.rating,
//     required this.reviews,
//     this.avatarAsset,
//     required this.about,
//   });

//   factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
//     name: json['fullName'],
//     specialty: json['specialization'],
//     rating: (json['rating'] ?? 4.7).toDouble(),
//     reviews: (json['reviews'] ?? 0) as int,
//     avatarAsset: null, // or json['avatarAsset'] if available
//     about: (json['about'] ?? 'No description provided.'),
//   );
// }

// class _SelectDoctorStepState extends State<SelectDoctorStep> {
//   int? selectedIndex;
//   List<Doctor> doctors = [];
//   List<Doctor> filteredDoctors = [];
//   bool loading = true;
//   String searchQuery = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchDoctors();
//   }

//   void fetchDoctors([String? query]) async {
//     setState(() {
//       loading = true;
//     });
//     try {
//       final uri = Uri.parse(
//         'http://192.168.137.1:4000/api/doctors${query != null && query.isNotEmpty ? '?q=${Uri.encodeComponent(query)}' : ''}',
//       );
//       final resp = await http.get(uri);

//       if (resp.statusCode == 200) {
//         final List docList = json.decode(resp.body)['doctors'];
//         final dList = docList.map((e) => Doctor.fromJson(e)).toList();
//         setState(() {
//           doctors = List<Doctor>.from(dList);
//           filteredDoctors = List<Doctor>.from(dList);
//           loading = false;
//         });
//       } else {
//         setState(() {
//           doctors = [];
//           filteredDoctors = [];
//           loading = false;
//         });
//       }
//     } catch (_) {
//       setState(() {
//         doctors = [];
//         filteredDoctors = [];
//         loading = false;
//       });
//     }
//   }

//   void _onSearch(String q) {
//     setState(() {
//       searchQuery = q;
//     });
//     fetchDoctors(q);
//   }

//   void _goNext() {
//     if (selectedIndex == null) return;
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => SelectSlotStep(doctor: filteredDoctors[selectedIndex!]),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final canContinue = selectedIndex != null && !loading;

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
//           'Book Appointment',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           const _StepperHeader(activeStep: 1),
//           const Divider(color: Color(0xFFE5E7EB), height: 1),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               onChanged: _onSearch,
//               decoration: InputDecoration(
//                 hintText: 'Search doctors...',
//                 prefixIcon: Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 0,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child:
//                 loading
//                     ? Center(child: CircularProgressIndicator())
//                     : doctors.isEmpty
//                     ? Center(child: Text('No doctors found'))
//                     : ListView.builder(
//                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                       itemCount: filteredDoctors.length,
//                       itemBuilder: (context, i) {
//                         final d = filteredDoctors[i];
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 14),
//                           child: _DoctorTile(
//                             doctor: d,
//                             selected: selectedIndex == i,
//                             onTap: () => setState(() => selectedIndex = i),
//                           ),
//                         );
//                       },
//                     ),
//           ),
//           SafeArea(
//             minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: SizedBox(
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: canContinue ? _goNext : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       canContinue
//                           ? const Color(0xFF0A84FF)
//                           : const Color(0xFFBFE4FF),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Select a Time Slot',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.5,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: 0.2,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DoctorTile extends StatelessWidget {
//   final Doctor doctor;
//   final VoidCallback onTap;
//   final bool selected;
//   const _DoctorTile({
//     required this.doctor,
//     required this.onTap,
//     required this.selected,
//   });

//   static String _initials(String name) {
//     final parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.isEmpty) return '?';
//     if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
//     return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
//         .toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final borderColor =
//         selected ? const Color(0xFF0A84FF) : const Color(0xFFE5E7EB);
//     return InkWell(
//       borderRadius: BorderRadius.circular(18),
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x14000000),
//               blurRadius: 10,
//               offset: Offset(0, 3),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _Avatar(
//               initials: _initials(doctor.name),
//               asset: doctor.avatarAsset,
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     doctor.name,
//                     style: const TextStyle(
//                       fontSize: 16.5,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF0F172A),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     doctor.specialty,
//                     style: const TextStyle(
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF64748B),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star_rounded,
//                         size: 18,
//                         color: Color(0xFFFFB300),
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF4B5563),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     doctor.about,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF475569),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Icon(Icons.chevron_right, color: Color(0xFF4B5563)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Avatar extends StatelessWidget {
//   final String? asset;
//   final String initials;
//   const _Avatar({required this.initials, this.asset});

//   @override
//   Widget build(BuildContext context) {
//     if (asset != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Image.asset(asset!, width: 48, height: 48, fit: BoxFit.cover),
//       );
//     }
//     return Container(
//       width: 48,
//       height: 48,
//       decoration: BoxDecoration(
//         color: const Color(0xFFE8F2FF),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         initials,
//         style: const TextStyle(
//           color: Color(0xFF0A84FF),
//           fontWeight: FontWeight.w800,
//           fontSize: 16,
//         ),
//       ),
//     );
//   }
// }

// /* --------------------- STEP 2: Select Slot --------------------- */

// class SelectSlotStep extends StatefulWidget {
//   final Doctor doctor;
//   const SelectSlotStep({super.key, required this.doctor});
//   @override
//   State<SelectSlotStep> createState() => _SelectSlotStepState();
// }

// class _SelectSlotStepState extends State<SelectSlotStep> {
//   DateTime currentDay = DateTime.now();
//   String? pickedSlot;
//   String mode = 'Video Call'; // default

//   final morning = const [
//     '09:00 AM',
//     '09:30 AM',
//     '10:00 AM',
//     '10:30 AM',
//     '11:00 AM',
//     '11:30 AM',
//   ];
//   final afternoon = const [
//     '01:00 PM',
//     '01:30 PM',
//     '02:00 PM',
//     '02:30 PM',
//     '03:00 PM',
//   ];
//   final evening = const ['05:00 PM', '05:30 PM', '06:00 PM'];

//   void _prevDay() =>
//       setState(() => currentDay = currentDay.subtract(const Duration(days: 1)));
//   void _nextDay() =>
//       setState(() => currentDay = currentDay.add(const Duration(days: 1)));

//   String _friendlyDay(DateTime d) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final that = DateTime(d.year, d.month, d.day);
//     final diff = that.difference(today).inDays;
//     if (diff == 0) return 'Today';
//     if (diff == -1) return 'Yest';
//     if (diff == 1) return 'Tomorrow';
//     const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return weekdays[that.weekday - 1];
//   }

//   String _dateLabel(DateTime d) {
//     const months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     return '${_friendlyDay(d)}, ${d.day} ${months[d.month - 1]}';
//   }

//   void _confirm() {
//     if (pickedSlot == null) return;
//     final dateOnly = _dateLabel(currentDay)
//         .replaceFirst('Today, ', '')
//         .replaceFirst('Yest, ', '')
//         .replaceFirst('Tomorrow, ', '');
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder:
//             (_) => ConfirmStep(
//               doctor: widget.doctor,
//               slot: '$dateOnly, $pickedSlot',
//               dateOnly: dateOnly,
//               timeOnly: pickedSlot!,
//               mode: mode,
//             ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final canConfirm = pickedSlot != null;

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFFF6F7FB),
//         foregroundColor: const Color(0xFF111827),
//         centerTitle: true,
//         title: const Text(
//           'Book Appointment',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.2,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           const _StepperHeader(activeStep: 2),
//           const Divider(color: Color(0xFFE5E7EB), height: 1),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
//               children: [
//                 _SelectedDoctorCard(
//                   doctor: widget.doctor,
//                   onChange: () => Navigator.pop(context),
//                 ),
//                 const SizedBox(height: 14),
//                 Row(
//                   children: [
//                     const Expanded(
//                       child: Text(
//                         'Select a Time Slot',
//                         style: TextStyle(
//                           fontSize: 16.5,
//                           fontWeight: FontWeight.w800,
//                           color: Color(0xFF0F172A),
//                         ),
//                       ),
//                     ),
//                     _ArrowCircle(
//                       icon: Icons.chevron_left_rounded,
//                       onTap: _prevDay,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       _dateLabel(currentDay),
//                       style: const TextStyle(
//                         fontSize: 13.5,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF334155),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     _ArrowCircle(
//                       icon: Icons.chevron_right_rounded,
//                       onTap: _nextDay,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 const Text(
//                   'Mode of Consultation',
//                   style: TextStyle(
//                     fontSize: 13.5,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF0F172A),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _ModeButton(
//                         label: 'Audio Call',
//                         icon: Icons.call_outlined,
//                         selected: mode == 'Audio Call',
//                         onTap: () => setState(() => mode = 'Audio Call'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _ModeButton(
//                         label: 'Video Call',
//                         icon: Icons.videocam_outlined,
//                         selected: mode == 'Video Call',
//                         onTap: () => setState(() => mode = 'Video Call'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: _ModeButton(
//                         label: 'IVR Mode',
//                         icon: Icons.dialpad_outlined,
//                         selected: mode == 'IVR Mode',
//                         onTap: () => setState(() => mode = 'IVR Mode'),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _SlotSection(
//                   title: 'Morning',
//                   slots: morning,
//                   picked: pickedSlot,
//                   onPick: (s) => setState(() => pickedSlot = s),
//                 ),
//                 const SizedBox(height: 10),
//                 _SlotSection(
//                   title: 'Afternoon',
//                   slots: afternoon,
//                   picked: pickedSlot,
//                   onPick: (s) => setState(() => pickedSlot = s),
//                 ),
//                 const SizedBox(height: 10),
//                 _SlotSection(
//                   title: 'Evening',
//                   slots: evening,
//                   picked: pickedSlot,
//                   onPick: (s) => setState(() => pickedSlot = s),
//                 ),
//               ],
//             ),
//           ),
//           SafeArea(
//             minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: SizedBox(
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: canConfirm ? _confirm : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       canConfirm
//                           ? const Color(0xFF0A84FF)
//                           : const Color(0xFFBFE4FF),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Confirm Appointment',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ModeButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final bool selected;
//   final VoidCallback onTap;
//   const _ModeButton({
//     required this.label,
//     required this.icon,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = selected ? const Color(0xFF0A84FF) : Colors.white;
//     final fg = selected ? Colors.white : const Color(0xFF0F172A);
//     final side = selected ? Colors.transparent : const Color(0xFFE5E7EB);
//     return SizedBox(
//       height: 44,
//       child: TextButton.icon(
//         onPressed: onTap,
//         style: TextButton.styleFrom(
//           backgroundColor: bg,
//           foregroundColor: fg,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           side: BorderSide(color: side),
//         ),
//         icon: Icon(icon, size: 18),
//         label: Text(
//           label,
//           style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
//         ),
//       ),
//     );
//   }
// }

// class _SelectedDoctorCard extends StatelessWidget {
//   final Doctor doctor;
//   final VoidCallback onChange;
//   const _SelectedDoctorCard({required this.doctor, required this.onChange});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFE5E7EB)),
//         boxShadow: const [
//           BoxShadow(
//             color: Color(0x14000000),
//             blurRadius: 10,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _Avatar(
//             initials: _DoctorTile._initials(doctor.name),
//             asset: doctor.avatarAsset,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   doctor.name,
//                   style: const TextStyle(
//                     fontSize: 16.5,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF0F172A),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   doctor.specialty,
//                   style: const TextStyle(
//                     fontSize: 13.5,
//                     fontWeight: FontWeight.w700,
//                     color: Color(0xFF64748B),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.star_rounded,
//                       size: 18,
//                       color: Color(0xFFFFB300),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
//                       style: const TextStyle(
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w700,
//                         color: Color(0xFF4B5563),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           TextButton(
//             onPressed: onChange,
//             child: const Text(
//               'Change',
//               style: TextStyle(
//                 color: Color(0xFF0A84FF),
//                 fontWeight: FontWeight.w800,
//                 fontSize: 13.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ArrowCircle extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _ArrowCircle({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       customBorder: const CircleBorder(),
//       child: Container(
//         width: 34,
//         height: 34,
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: [
//             BoxShadow(
//               color: Color(0x14000000),
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: const Color(0xFF334155), size: 20),
//       ),
//     );
//   }
// }

// class _SlotSection extends StatelessWidget {
//   final String title;
//   final List<String> slots;
//   final String? picked;
//   final ValueChanged<String> onPick;

//   const _SlotSection({
//     required this.title,
//     required this.slots,
//     required this.picked,
//     required this.onPick,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16.5,
//             fontWeight: FontWeight.w900,
//             color: Color(0xFF0F172A),
//           ),
//         ),
//         const SizedBox(height: 10),
//         Wrap(
//           spacing: 12,
//           runSpacing: 10,
//           children:
//               slots
//                   .map(
//                     (s) => _TimeChip(
//                       value: s,
//                       picked: picked == s,
//                       onTap: () => onPick(s),
//                     ),
//                   )
//                   .toList(),
//         ),
//       ],
//     );
//   }
// }

// class _TimeChip extends StatelessWidget {
//   final String value;
//   final bool picked;
//   final VoidCallback onTap;
//   const _TimeChip({
//     required this.value,
//     required this.picked,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bg = picked ? const Color(0xFF0A84FF) : Colors.white;
//     final fg = picked ? Colors.white : const Color(0xFF0F172A);
//     final side = picked ? Colors.transparent : const Color(0xFFE5E7EB);

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         width: 118,
//         height: 46,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: side),
//           boxShadow: const [
//             BoxShadow(
//               color: Color(0x08000000),
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           value,
//           style: TextStyle(
//             color: fg,
//             fontWeight: FontWeight.w900,
//             fontSize: 13.5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* --------------------- STEP 3: Confirm --------------------- */

// class ConfirmStep extends StatelessWidget {
//   final Doctor doctor;
//   final String slot; // "24 July, 10:30 AM"
//   final String? dateOnly; // "Wednesday, 24 July"
//   final String? timeOnly; // "10:30 AM"
//   final String mode; // chosen mode
//   const ConfirmStep({
//     super.key,
//     required this.doctor,
//     required this.slot,
//     required this.mode,
//     this.dateOnly,
//     this.timeOnly,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final dateText = dateOnly ?? slot;
//     final timeText = timeOnly ?? '';

//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFFF6F7FB),
//         foregroundColor: const Color(0xFF111827),
//         centerTitle: true,
//         title: const Text(
//           'Confirm Appointment',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w800,
//             letterSpacing: 0.2,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           const _StepperHeader(activeStep: 3),
//           const Divider(color: Color(0xFFE5E7EB), height: 1),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
//               children: [
//                 const Text(
//                   'Appointment Summary',
//                   style: TextStyle(
//                     fontSize: 16.5,
//                     fontWeight: FontWeight.w900,
//                     color: Color(0xFF0F172A),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: const Color(0xFFE5E7EB)),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Color(0x14000000),
//                         blurRadius: 10,
//                         offset: Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           _Avatar(
//                             initials: _DoctorTile._initials(doctor.name),
//                             asset: doctor.avatarAsset,
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   doctor.name,
//                                   style: const TextStyle(
//                                     fontSize: 16.5,
//                                     fontWeight: FontWeight.w800,
//                                     color: Color(0xFF0F172A),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   doctor.specialty,
//                                   style: const TextStyle(
//                                     fontSize: 13.5,
//                                     fontWeight: FontWeight.w700,
//                                     color: Color(0xFF64748B),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.star_rounded,
//                                       size: 18,
//                                       color: Color(0xFFFFB300),
//                                     ),
//                                     const SizedBox(width: 6),
//                                     Text(
//                                       '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
//                                       style: const TextStyle(
//                                         fontSize: 12.5,
//                                         fontWeight: FontWeight.w700,
//                                         color: Color(0xFF4B5563),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text(
//                               'Edit',
//                               style: TextStyle(
//                                 color: Color(0xFF0A84FF),
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 13.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       const Divider(color: Color(0xFFE5E7EB), height: 1),
//                       const SizedBox(height: 10),
//                       _kv('Date', dateText),
//                       _kv('Time', timeText.isEmpty ? slot : timeText),
//                       _kv('Mode of Consultation', mode),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 const Text(
//                   "By confirming, you agree to GramCare's Terms of Service and Privacy Policy.",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: Color(0xFF64748B),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 12.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SafeArea(
//             minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: SizedBox(
//               height: 52,
//               child: ElevatedButton(
//                 onPressed: () {
//                   // TODO: Submit to backend, then navigate to success or root
//                   Navigator.popUntil(context, (r) => r.isFirst);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF0A84FF),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   'Confirm Appointment',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 15.5,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _kv(String k, String v) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               k,
//               style: const TextStyle(
//                 color: Color(0xFF64748B),
//                 fontWeight: FontWeight.w800,
//                 fontSize: 13,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               v,
//               textAlign: TextAlign.right,
//               style: const TextStyle(
//                 color: Color(0xFF0F172A),
//                 fontWeight: FontWeight.w900,
//                 fontSize: 14.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* --------------------- Shared --------------------- */

// class _StepperHeader extends StatelessWidget {
//   final int activeStep; // 1..3
//   const _StepperHeader({required this.activeStep});

//   @override
//   Widget build(BuildContext context) {
//     Widget dot(int n, String title) {
//       final active = n == activeStep;
//       return Expanded(
//         child: Column(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(
//                 color:
//                     active ? const Color(0xFF0A84FF) : const Color(0xFFE9EEF5),
//                 shape: BoxShape.circle,
//               ),
//               alignment: Alignment.center,
//               child: Text(
//                 '$n',
//                 style: TextStyle(
//                   color: active ? Colors.white : const Color(0xFF64748B),
//                   fontWeight: FontWeight.w900,
//                   fontSize: 15.5,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               title,
//               style: TextStyle(
//                 color:
//                     active ? const Color(0xFF0A84FF) : const Color(0xFF94A3B8),
//                 fontWeight: FontWeight.w800,
//                 fontSize: 13.5,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
//       child: Row(
//         children: [
//           dot(1, 'Select Doctor'),
//           dot(2, 'Select Slot'),
//           dot(3, 'Confirm'),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const BookAppointmentFlow(username: 'JohnDoe'));

class BookAppointmentFlow extends StatelessWidget {
  final String username;
  const BookAppointmentFlow({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Appointment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SFPro',
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        useMaterial3: false,
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      home: SelectDoctorStep(username: username),
    );
  }
}

/* --------------------- STEP 1: Select Doctor --------------------- */

class Doctor {
  final String id; // Add this for appointment DB
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String? avatarAsset;
  final String about;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    this.avatarAsset,
    required this.about,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['medicalRegNo'] ?? json['_id'] ?? '', // Use a unique identifier
    name: json['fullName'],
    specialty: json['specialization'],
    rating: (json['rating'] ?? 4.7).toDouble(),
    reviews: (json['reviews'] ?? 0) as int,
    avatarAsset: null,
    about: (json['about'] ?? 'No description provided.'),
  );
}

class SelectDoctorStep extends StatefulWidget {
  final String username;
  const SelectDoctorStep({Key? key, required this.username}) : super(key: key);

  @override
  State<SelectDoctorStep> createState() => _SelectDoctorStepState();
}

class _SelectDoctorStepState extends State<SelectDoctorStep> {
  int? selectedIndex;
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  void fetchDoctors([String? query]) async {
    setState(() {
      loading = true;
    });
    try {
      final uri = Uri.parse(
        'http://192.168.137.1:4001/api/doctors${query != null && query.isNotEmpty ? '?q=${Uri.encodeComponent(query)}' : ''}',
      );
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final List docList = json.decode(resp.body)['doctors'];
        final dList = docList.map((e) => Doctor.fromJson(e)).toList();
        setState(() {
          doctors = List<Doctor>.from(dList);
          filteredDoctors = List<Doctor>.from(dList);
          loading = false;
        });
      } else {
        setState(() {
          doctors = [];
          filteredDoctors = [];
          loading = false;
        });
      }
    } catch (_) {
      setState(() {
        doctors = [];
        filteredDoctors = [];
        loading = false;
      });
    }
  }

  void _onSearch(String q) => fetchDoctors(q);

  void _goNext() {
    if (selectedIndex == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => SelectSlotStep(
              doctor: filteredDoctors[selectedIndex!],
              patientLogin: widget.username,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = selectedIndex != null && !loading;

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
          'Book Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: Column(
        children: [
          const _StepperHeader(activeStep: 1),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                loading
                    ? const Center(child: CircularProgressIndicator())
                    : doctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredDoctors.length,
                      itemBuilder: (context, i) {
                        final d = filteredDoctors[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _DoctorTile(
                            doctor: d,
                            selected: selectedIndex == i,
                            onTap: () => setState(() => selectedIndex = i),
                          ),
                        );
                      },
                    ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canContinue ? _goNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canContinue
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFFBFE4FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Select a Time Slot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final bool selected;
  const _DoctorTile({
    required this.doctor,
    required this.onTap,
    required this.selected,
  });

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? const Color(0xFF0A84FF) : const Color(0xFFE5E7EB);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              initials: _initials(doctor.name),
              asset: doctor.avatarAsset,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFFFB300),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doctor.about,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF4B5563)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? asset;
  final String initials;
  const _Avatar({required this.initials, this.asset});

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(asset!, width: 48, height: 48, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Color(0xFF0A84FF),
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

/* --------------------- STEP 2: Select Slot --------------------- */

class SelectSlotStep extends StatefulWidget {
  final Doctor doctor;
  final String patientLogin;
  const SelectSlotStep({
    super.key,
    required this.doctor,
    required this.patientLogin,
  });
  @override
  State<SelectSlotStep> createState() => _SelectSlotStepState();
}

class _SelectSlotStepState extends State<SelectSlotStep> {
  DateTime currentDay = DateTime.now();
  String? pickedSlot;
  String mode = 'Video Call'; // default

  final morning = const [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
  ];
  final afternoon = const [
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
  ];
  final evening = const ['05:00 PM', '05:30 PM', '06:00 PM'];

  void _prevDay() =>
      setState(() => currentDay = currentDay.subtract(const Duration(days: 1)));
  void _nextDay() =>
      setState(() => currentDay = currentDay.add(const Duration(days: 1)));
  String _friendlyDay(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = that.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yest';
    if (diff == 1) return 'Tomorrow';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[that.weekday - 1];
  }

  String _dateLabel(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${_friendlyDay(d)}, ${d.day} ${months[d.month - 1]}';
  }

  void _confirm() {
    if (pickedSlot == null) return;
    final dateOnly = _dateLabel(currentDay)
        .replaceFirst('Today, ', '')
        .replaceFirst('Yest, ', '')
        .replaceFirst('Tomorrow, ', '');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ConfirmStep(
              doctor: widget.doctor,
              slot: '$dateOnly, $pickedSlot',
              dateOnly: dateOnly,
              timeOnly: pickedSlot!,
              mode: mode,
              patientLogin: widget.patientLogin,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = pickedSlot != null;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: const Color(0xFF111827),
        centerTitle: true,
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          const _StepperHeader(activeStep: 2),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              children: [
                _SelectedDoctorCard(
                  doctor: widget.doctor,
                  onChange: () => Navigator.pop(context),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select a Time Slot',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    _ArrowCircle(
                      icon: Icons.chevron_left_rounded,
                      onTap: _prevDay,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _dateLabel(currentDay),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ArrowCircle(
                      icon: Icons.chevron_right_rounded,
                      onTap: _nextDay,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Mode of Consultation',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        label: 'Audio Call',
                        icon: Icons.call_outlined,
                        selected: mode == 'Audio Call',
                        onTap: () => setState(() => mode = 'Audio Call'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        label: 'Video Call',
                        icon: Icons.videocam_outlined,
                        selected: mode == 'Video Call',
                        onTap: () => setState(() => mode = 'Video Call'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        label: 'IVR Mode',
                        icon: Icons.dialpad_outlined,
                        selected: mode == 'IVR Mode',
                        onTap: () => setState(() => mode = 'IVR Mode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SlotSection(
                  title: 'Morning',
                  slots: morning,
                  picked: pickedSlot,
                  onPick: (s) => setState(() => pickedSlot = s),
                ),
                const SizedBox(height: 10),
                _SlotSection(
                  title: 'Afternoon',
                  slots: afternoon,
                  picked: pickedSlot,
                  onPick: (s) => setState(() => pickedSlot = s),
                ),
                const SizedBox(height: 10),
                _SlotSection(
                  title: 'Evening',
                  slots: evening,
                  picked: pickedSlot,
                  onPick: (s) => setState(() => pickedSlot = s),
                ),
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: canConfirm ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      canConfirm
                          ? const Color(0xFF0A84FF)
                          : const Color(0xFFBFE4FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF0A84FF) : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF0F172A);
    final side = selected ? Colors.transparent : const Color(0xFFE5E7EB);
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: side),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
      ),
    );
  }
}

class _SelectedDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onChange;
  const _SelectedDoctorCard({required this.doctor, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(
            initials: _DoctorTile._initials(doctor.name),
            asset: doctor.avatarAsset,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text(
              'Change',
              style: TextStyle(
                color: Color(0xFF0A84FF),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowCircle extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowCircle({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF334155), size: 20),
      ),
    );
  }
}

class _SlotSection extends StatelessWidget {
  final String title;
  final List<String> slots;
  final String? picked;
  final ValueChanged<String> onPick;

  const _SlotSection({
    required this.title,
    required this.slots,
    required this.picked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children:
              slots
                  .map(
                    (s) => _TimeChip(
                      value: s,
                      picked: picked == s,
                      onTap: () => onPick(s),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String value;
  final bool picked;
  final VoidCallback onTap;
  const _TimeChip({
    required this.value,
    required this.picked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = picked ? const Color(0xFF0A84FF) : Colors.white;
    final fg = picked ? Colors.white : const Color(0xFF0F172A);
    final side = picked ? Colors.transparent : const Color(0xFFE5E7EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 118,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: side),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          value,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
/* --------------------- STEP 3: Confirm & Submit --------------------- */

class ConfirmStep extends StatelessWidget {
  final Doctor doctor;
  final String slot;
  final String? dateOnly;
  final String? timeOnly;
  final String mode;
  final String patientLogin;

  const ConfirmStep({
    super.key,
    required this.doctor,
    required this.slot,
    required this.mode,
    required this.patientLogin,
    this.dateOnly,
    this.timeOnly,
  });

  Future<void> _submitAppointment(BuildContext context) async {
    final payload = {
      'patientLogin': patientLogin,
      'doctorId': doctor.id,
      'doctorName': doctor.name,
      'doctorSpecialty': doctor.specialty,
      'appointmentDate': dateOnly ?? slot,
      'appointmentTime': timeOnly ?? '',
      'slotLabel': slot,
      'mode': mode,
    };

    final url = Uri.parse('http://192.168.137.1:4001/api/appointment');
    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (resp.statusCode == 201) {
        Navigator.popUntil(context, (r) => r.isFirst);
      } else {
        final errorMsg =
            jsonDecode(resp.body)['message'] ??
            jsonDecode(resp.body)['error'] ??
            'Booking failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $errorMsg')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = dateOnly ?? slot;
    final timeText = timeOnly ?? '';

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7FB),
        foregroundColor: const Color(0xFF111827),
        centerTitle: true,
        title: const Text(
          'Confirm Appointment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          const _StepperHeader(activeStep: 3),
          const Divider(color: Color(0xFFE5E7EB), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                const Text(
                  'Appointment Summary',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _Avatar(
                            initials: _DoctorTile._initials(doctor.name),
                            asset: doctor.avatarAsset,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doctor.specialty,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Color(0xFFFFB300),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${doctor.rating.toStringAsFixed(1)} (${doctor.reviews} reviews)',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: Color(0xFF0A84FF),
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFFE5E7EB), height: 1),
                      const SizedBox(height: 10),
                      _kv('Date', dateText),
                      _kv('Time', timeText.isEmpty ? slot : timeText),
                      _kv('Mode of Consultation', mode),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "By confirming, you agree to GramCare's Terms of Service and Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => _submitAppointment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A84FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              k,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* --------------------- Shared Stepper Header --------------------- */
class _StepperHeader extends StatelessWidget {
  final int activeStep; // 1..3
  const _StepperHeader({required this.activeStep});
  @override
  Widget build(BuildContext context) {
    Widget dot(int n, String title) {
      final active = n == activeStep;
      return Expanded(
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color:
                    active ? const Color(0xFF0A84FF) : const Color(0xFFE9EEF5),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$n',
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF64748B),
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color:
                    active ? const Color(0xFF0A84FF) : const Color(0xFF94A3B8),
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          dot(1, 'Select Doctor'),
          dot(2, 'Select Slot'),
          dot(3, 'Confirm'),
        ],
      ),
    );
  }
}
