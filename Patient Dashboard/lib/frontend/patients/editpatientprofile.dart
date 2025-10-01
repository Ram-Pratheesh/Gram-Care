// import 'package:flutter/material.dart';

// class EditProfileScreen extends StatefulWidget {
//   final String username;
//   const EditProfileScreen({super.key, required this.username});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final nameCtrl = TextEditingController();
//   final dobCtrl = TextEditingController();
//   final phoneCtrl = TextEditingController();
//   final altPhoneCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final idNumberCtrl = TextEditingController();
//   final allergiesCtrl = TextEditingController();
//   final chronicCtrl = TextEditingController();
//   final medsCtrl = TextEditingController();
//   final doctorCtrl = TextEditingController();
//   final pharmacyCtrl = TextEditingController();
//   final heightCtrl = TextEditingController();
//   final weightCtrl = TextEditingController();
//   final bmiCtrl = TextEditingController();
//   final providerCtrl = TextEditingController();
//   final planCtrl = TextEditingController();
//   final policyIdCtrl = TextEditingController();
//   final expiryCtrl = TextEditingController();

//   String gender = 'Select';
//   String idType = 'Select';
//   String language = 'English';
//   String bloodGroup = 'Select';
//   String smoking = 'Select';
//   String activity = 'Select';
//   double fontSize = 1.0;
//   double contrast = 1.0;
//   bool voicePrompts = false;
//   bool pregnancy = false;
//   bool dataSharing = false;
//   bool telemedicine = false;
//   bool otpLogin = false;
//   bool twoFA = false;

//   final List<_EmergencyContact> _contacts = const [
//     _EmergencyContact(
//       name: 'Ethan Harper',
//       relation: 'Spouse',
//       phone: '+1 (555) 987-6543',
//     ),
//   ];

//   void _snack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800)),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: const Color(0xFF2F80ED),
//         duration: const Duration(milliseconds: 1100),
//       ),
//     );
//   }

//   Future<void> _addEmergencyContactDialog() async {
//     final name = TextEditingController();
//     final relation = TextEditingController();
//     final phone = TextEditingController();

//     await showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 16,
//             right: 16,
//             top: 12,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Add Emergency Contact',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                   color: Color(0xFF111827),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _FormField(label: 'Full Name', controller: name),
//               _FormField(label: 'Relation', controller: relation),
//               _FormField(
//                 label: 'Phone Number',
//                 controller: phone,
//                 keyboard: TextInputType.phone,
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Color(0xFFE6EAF0)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () => Navigator.pop(ctx),
//                       child: const Text(
//                         'Cancel',
//                         style: TextStyle(fontWeight: FontWeight.w800),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         elevation: 0,
//                         backgroundColor: const Color(0xFF1E40FF),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (name.text.trim().isEmpty ||
//                             relation.text.trim().isEmpty ||
//                             phone.text.trim().isEmpty) {
//                           _snack('Fill all fields');
//                           return;
//                         }
//                         setState(() {
//                           // In real app, append to list; here we show success
//                         });
//                         Navigator.pop(ctx);
//                         _snack('Emergency contact added');
//                       },
//                       child: const Text(
//                         'Add',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   bool get _isPregnancyEnabled => gender == 'Female';

//   @override
//   Widget build(BuildContext context) {
//     const hPad = 16.0;
//     return Scaffold(
//       appBar: const _TopBar(),
//       body: SafeArea(
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: hPad),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SectionTitle('Personal Info'),
//                     const SizedBox(height: 8),
//                     _TextField(label: 'Full Name', controller: nameCtrl),
//                     _TextField(
//                       label: 'Date of Birth',
//                       controller: dobCtrl,
//                       trailing: Icons.calendar_today_outlined,
//                     ),
//                     _DropdownField(
//                       label: 'Gender',
//                       value: gender,
//                       items: const ['Select', 'Female', 'Male', 'Other'],
//                       onChanged:
//                           (v) => setState(() {
//                             gender = v!;
//                             if (!_isPregnancyEnabled) pregnancy = false;
//                           }),
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Contacts'),
//                     const SizedBox(height: 8),
//                     _TextField(
//                       label: 'Primary Phone',
//                       controller: phoneCtrl,
//                       keyboard: TextInputType.phone,
//                     ),
//                     _TextField(
//                       label: 'Alternate Phone',
//                       controller: altPhoneCtrl,
//                       keyboard: TextInputType.phone,
//                     ),
//                     _TextField(
//                       label: 'Email',
//                       controller: emailCtrl,
//                       keyboard: TextInputType.emailAddress,
//                     ),
//                     _TextField(label: 'Address', controller: addressCtrl),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Government ID'),
//                     const SizedBox(height: 8),
//                     _DropdownField(
//                       label: 'ID Type',
//                       value: idType,
//                       items: const [
//                         'Select',
//                         'National ID',
//                         'Passport',
//                         'Driver License',
//                       ],
//                       onChanged: (v) => setState(() => idType = v!),
//                     ),
//                     _TextField(label: 'ID Number', controller: idNumberCtrl),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Language & Accessibility'),
//                     const SizedBox(height: 8),
//                     _DropdownField(
//                       label: 'Preferred Language',
//                       value: language,
//                       items: const ['English', 'Hindi', 'Punjabi', 'Tamil'],
//                       onChanged: (v) => setState(() => language = v!),
//                     ),
//                     _SliderField(
//                       label: 'Font Size',
//                       value: fontSize,
//                       onChanged: (v) => setState(() => fontSize = v),
//                     ),
//                     _SliderField(
//                       label: 'Contrast',
//                       value: contrast,
//                       onChanged: (v) => setState(() => contrast = v),
//                     ),
//                     _SwitchField(
//                       label: 'Voice Prompts',
//                       value: voicePrompts,
//                       onChanged: (v) => setState(() => voicePrompts = v),
//                       sub: 'Enable voice prompts for navigation',
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Emergency Contacts'),
//                     const SizedBox(height: 8),
//                     ..._contacts.map(
//                       (c) => _NavRow(
//                         label: c.name,
//                         sub: '${c.relation} · ${c.phone}',
//                         onTap: () {},
//                       ),
//                     ),
//                     _NavRow(
//                       label: 'Add Emergency Contact',
//                       onTap: _addEmergencyContactDialog,
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Medical Details'),
//                     const SizedBox(height: 8),
//                     _DropdownField(
//                       label: 'Blood Group',
//                       value: bloodGroup,
//                       items: const [
//                         'Select',
//                         'O+',
//                         'O-',
//                         'A+',
//                         'A-',
//                         'B+',
//                         'B-',
//                         'AB+',
//                         'AB-',
//                       ],
//                       onChanged: (v) => setState(() => bloodGroup = v!),
//                     ),
//                     _TextField(label: 'Allergies', controller: allergiesCtrl),
//                     _TextField(
//                       label: 'Chronic Conditions',
//                       controller: chronicCtrl,
//                     ),
//                     _TextField(label: 'Medications', controller: medsCtrl),
//                     _TextField(label: 'Doctor', controller: doctorCtrl),
//                     _TextField(label: 'Pharmacy', controller: pharmacyCtrl),
//                     Opacity(
//                       opacity: _isPregnancyEnabled ? 1.0 : 0.5,
//                       child: IgnorePointer(
//                         ignoring: !_isPregnancyEnabled,
//                         child: _SwitchField(
//                           label: 'Pregnancy Status',
//                           value: pregnancy,
//                           onChanged: (v) => setState(() => pregnancy = v),
//                           sub: 'Are you currently pregnant?',
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Vitals & Lifestyle'),
//                     const SizedBox(height: 8),
//                     _TextField(
//                       label: 'Height (cm)',
//                       controller: heightCtrl,
//                       keyboard: TextInputType.number,
//                     ),
//                     _TextField(
//                       label: 'Weight (kg)',
//                       controller: weightCtrl,
//                       keyboard: TextInputType.number,
//                     ),
//                     _TextField(
//                       label: 'BMI',
//                       controller: bmiCtrl,
//                       keyboard: TextInputType.number,
//                     ),
//                     _DropdownField(
//                       label: 'Smoking/Alcohol',
//                       value: smoking,
//                       items: const [
//                         'Select',
//                         'None',
//                         'Smoking',
//                         'Alcohol',
//                         'Both',
//                       ],
//                       onChanged: (v) => setState(() => smoking = v!),
//                     ),
//                     _DropdownField(
//                       label: 'Activity Level',
//                       value: activity,
//                       items: const ['Select', 'Low', 'Moderate', 'High'],
//                       onChanged: (v) => setState(() => activity = v!),
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Insurance'),
//                     const SizedBox(height: 8),
//                     _TextField(label: 'Provider', controller: providerCtrl),
//                     _TextField(label: 'Plan', controller: planCtrl),
//                     _TextField(label: 'ID', controller: policyIdCtrl),
//                     _TextField(label: 'Expiry', controller: expiryCtrl),
//                     _UploadRow(
//                       label: 'Upload Card Photo',
//                       onTap: () => _snack('Upload Insurance Photo'),
//                     ),
//                     const SizedBox(height: 8),
//                     const SectionTitle('Privacy & Consent'),
//                     const SizedBox(height: 8),
//                     _SwitchField(
//                       label: 'Data Sharing',
//                       value: dataSharing,
//                       onChanged: (v) => setState(() => dataSharing = v),
//                       sub: 'Share data with research partners',
//                     ),
//                     _SwitchField(
//                       label: 'Telemedicine',
//                       value: telemedicine,
//                       onChanged: (v) => setState(() => telemedicine = v),
//                       sub: 'Allow telemedicine appointments',
//                     ),
//                     _SwitchField(
//                       label: 'OTP Login',
//                       value: otpLogin,
//                       onChanged: (v) => setState(() => otpLogin = v),
//                       sub: 'Enable verification and logins',
//                     ),
//                     _SwitchField(
//                       label: '2FA',
//                       value: twoFA,
//                       onChanged: (v) => setState(() => twoFA = v),
//                       sub: 'Enable two-factor authentication',
//                     ),
//                     const SizedBox(height: 100),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           border: Border(top: BorderSide(color: Color(0xFFE6EAF0))),
//         ),
//         padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
//         child: SafeArea(
//           top: false,
//           child: Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   style: OutlinedButton.styleFrom(
//                     side: const BorderSide(color: Color(0xFFE6EAF0)),
//                     foregroundColor: const Color(0xFF111827),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () => _snack('Cancelled'),
//                   child: const Text(
//                     'Cancel',
//                     style: TextStyle(fontWeight: FontWeight.w800),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     elevation: 0,
//                     backgroundColor: const Color(0xFF1E40FF),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: () => _snack('Profile Saved'),
//                   child: const Text(
//                     'Save',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w800,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /* ---------- Models ---------- */

// class _EmergencyContact {
//   final String name;
//   final String relation;
//   final String phone;
//   const _EmergencyContact({
//     required this.name,
//     required this.relation,
//     required this.phone,
//   });
// }

// /* ---------- Shared UI ---------- */

// class _TopBar extends StatelessWidget implements PreferredSizeWidget {
//   const _TopBar({super.key});
//   @override
//   Size get preferredSize => const Size.fromHeight(44);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
//         onPressed: () {},
//       ),
//       centerTitle: true,
//       title: const Text(
//         'Edit Profile',
//         style: TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w800,
//           color: Color(0xFF0F172A),
//         ),
//       ),
//     );
//   }
// }

// class SectionTitle extends StatelessWidget {
//   final String text;
//   const SectionTitle(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 13.5,
//         fontWeight: FontWeight.w800,
//         color: Color(0xFF111827),
//       ),
//     );
//   }
// }

// class _FieldLabel extends StatelessWidget {
//   final String text;
//   const _FieldLabel({super.key, required this.text});

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w800,
//         color: Color(0xFF6B7280),
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final IconData? trailing;
//   final bool obscure;
//   final TextInputType? keyboard;

//   const _TextField({
//     super.key,
//     required this.label,
//     required this.controller,
//     this.trailing,
//     this.obscure = false,
//     this.keyboard,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _FieldLabel(text: label),
//           const SizedBox(height: 6),
//           Container(
//             height: 40,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF6F6FA),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE6EAF0)),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: controller,
//                     obscureText: obscure,
//                     keyboardType: keyboard,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF0F172A),
//                     ),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       isCollapsed: true,
//                     ),
//                   ),
//                 ),
//                 if (trailing != null)
//                   Icon(trailing, color: const Color(0xFF98A2B3), size: 18),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DropdownField extends StatelessWidget {
//   final String label;
//   final String value;
//   final List<String> items;
//   final ValueChanged<String?> onChanged;

//   const _DropdownField({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _FieldLabel(text: label),
//           const SizedBox(height: 6),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF6F6FA),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: const Color(0xFFE6EAF0)),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: value,
//                 icon: const Icon(Icons.expand_more, color: Color(0xFF98A2B3)),
//                 isExpanded: true,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: FontWeight.w700,
//                   color: Color(0xFF0F172A),
//                 ),
//                 items:
//                     items
//                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                         .toList(),
//                 onChanged: onChanged,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _UploadRow extends StatelessWidget {
//   final String label;
//   final VoidCallback onTap;
//   const _UploadRow({super.key, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Expanded(child: _FieldLabel(text: label)),
//           IconButton(
//             onPressed: onTap,
//             icon: const Icon(
//               Icons.upload_outlined,
//               color: Color(0xFF8F9BAD),
//               size: 18,
//             ),
//             splashRadius: 18,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SliderField extends StatelessWidget {
//   final String label;
//   final double value;
//   final ValueChanged<double> onChanged;
//   const _SliderField({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _FieldLabel(text: label),
//           SliderTheme(
//             data: SliderTheme.of(context).copyWith(
//               thumbColor: const Color(0xFF1E40FF),
//               activeTrackColor: const Color(0xFF1E40FF),
//               inactiveTrackColor: const Color(0xFFE5E7EB),
//             ),
//             child: Slider(
//               value: value,
//               onChanged: onChanged,
//               min: 0.5,
//               max: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SwitchField extends StatelessWidget {
//   final String label;
//   final String? sub;
//   final bool value;
//   final ValueChanged<bool> onChanged;

//   const _SwitchField({
//     super.key,
//     required this.label,
//     required this.value,
//     required this.onChanged,
//     this.sub,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _FieldLabel(text: label),
//                 if (sub != null)
//                   Text(
//                     sub!,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF9AA3AF),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Switch(
//             value: value,
//             activeColor: const Color(0xFF1E40FF),
//             onChanged: onChanged,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _NavRow extends StatelessWidget {
//   final String label;
//   final String? sub;
//   final VoidCallback onTap;
//   const _NavRow({
//     super.key,
//     required this.label,
//     required this.onTap,
//     this.sub,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: const Color(0xFFF6F6FA),
//       borderRadius: BorderRadius.circular(8),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8),
//         child: Container(
//           height: 44,
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF6F6FA),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: const Color(0xFFE6EAF0)),
//           ),
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       label,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF111827),
//                       ),
//                     ),
//                     if (sub != null)
//                       Text(
//                         sub!,
//                         style: const TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _FormField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;
//   final TextInputType? keyboard;

//   const _FormField({
//     super.key,
//     required this.label,
//     required this.controller,
//     this.keyboard,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w800,
//               color: Color(0xFF6B7280),
//             ),
//           ),
//           const SizedBox(height: 6),
//           Container(
//             height: 42,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF6F6FA),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: const Color(0xFFE6EAF0)),
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 12),
//             child: TextField(
//               controller: controller,
//               keyboardType: keyboard,
//               style: const TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w700,
//                 color: Color(0xFF0F172A),
//               ),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
//                 isCollapsed: true,
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

/*
  Edit Patient Profile (Dynamic)
  - Loads data by username from /api/patient-details
  - Populates controllers and state
  - Provides dropdowns for Allergies, Chronic Conditions, Medications, Doctor, Pharmacy
  - Saves changes to /api/patient-update
  - Removes Insurance section per request
  - Do not change anything else visually beyond requested inputs
*/

const String apiBase = 'http://192.168.137.1:4001';

class EditProfileScreen extends StatefulWidget {
  final String username;
  const EditProfileScreen({super.key, required this.username});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers
  final nameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final altPhoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final idNumberCtrl = TextEditingController();

  // Replaced with dropdowns as requested
  // final allergiesCtrl = TextEditingController();
  // final chronicCtrl = TextEditingController();
  // final medsCtrl = TextEditingController();
  // final doctorCtrl = TextEditingController();
  // final pharmacyCtrl = TextEditingController();

  final heightCtrl = TextEditingController();
  final weightCtrl = TextEditingController();
  final bmiCtrl = TextEditingController();

  // Removed Insurance inputs as requested
  // final providerCtrl = TextEditingController();
  // final planCtrl = TextEditingController();
  // final policyIdCtrl = TextEditingController();
  // final expiryCtrl = TextEditingController();

  String gender = 'Select';
  String idType = 'Select';
  String language = 'English';
  String bloodGroup = 'Select';
  String smoking = 'Select';
  String activity = 'Select';
  double fontSize = 1.0;
  double contrast = 1.0;
  bool voicePrompts = false;
  bool pregnancy = false;
  bool dataSharing = false;
  bool telemedicine = false;
  bool otpLogin = false;
  bool twoFA = false;

  // Dropdown model values (single-select for this UI)
  String allergies = 'None';
  String chronicConditions = 'None';
  String medications = 'None';
  String doctor = 'Unassigned';
  String pharmacy = 'Unassigned';

  // Options lists (could be fetched; kept static here)
  final List<String> allergyOptions = const [
    'None',
    'Penicillin',
    'Sulfa',
    'Peanuts',
    'Dust',
    'Pollen',
  ];
  final List<String> chronicOptions = const [
    'None',
    'Asthma',
    'Diabetes',
    'Hypertension',
    'Thyroid',
    'COPD',
  ];
  final List<String> medicationOptions = const [
    'None',
    'Albuterol',
    'Metformin',
    'Atorvastatin',
    'Amlodipine',
  ];
  final List<String> doctorOptions = const [
    'Unassigned',
    'Dr. Harper',
    'Dr. Verma',
    'Dr. Anjali Sharma',
  ];
  final List<String> pharmacyOptions = const [
    'Unassigned',
    'CVS Pharmacy',
    'Walgreens',
    'Apollo',
    '1mg',
  ];

  bool _saving = false;
  bool _loading = true;

  final List<_EmergencyContact> _contacts = const [
    _EmergencyContact(
      name: 'Ethan Harper',
      relation: 'Spouse',
      phone: '+1 (555) 987-6543',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Uri _buildUri(String path, [Map<String, String>? q]) {
    final base = Uri.parse(apiBase);
    final basePath =
        base.path.endsWith('/')
            ? base.path.substring(0, base.path.length - 1)
            : base.path;
    return base.replace(path: '$basePath$path', queryParameters: q);
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    try {
      final uri = _buildUri('/api/patient-details', {'login': widget.username});
      final resp = await http.get(uri);
      if (resp.statusCode == 200) {
        final map = jsonDecode(resp.body) as Map<String, dynamic>;

        nameCtrl.text = (map['fullName'] ?? '').toString();
        dobCtrl.text = (map['dob'] ?? '').toString();
        gender =
            ((map['gender'] ?? '') as String).isEmpty
                ? 'Select'
                : (map['gender'] as String);
        addressCtrl.text = (map['address'] ?? '').toString();
        phoneCtrl.text = (map['primaryPhone'] ?? '').toString();
        altPhoneCtrl.text = (map['altPhone'] ?? '').toString();
        emailCtrl.text = (map['email'] ?? '').toString();
        language =
            ((map['language'] ?? '') as String).isEmpty
                ? 'English'
                : (map['language'] as String);
        idNumberCtrl.text = (map['govId'] ?? '').toString();

        // Medical fields mapped to dropdowns
        allergies = _coerceOption(
          (map['allergies'] ?? 'None').toString(),
          allergyOptions,
          'None',
        );
        chronicConditions = _coerceOption(
          (map['conditions'] ?? 'None').toString(),
          chronicOptions,
          'None',
        );
        medications = _coerceOption(
          (map['chronicMeds'] ?? 'None').toString(),
          medicationOptions,
          'None',
        );

        // Doctor/pharmacy dropdowns
        doctor = _coerceOption(
          (map['primaryDoctor'] ?? 'Unassigned').toString(),
          doctorOptions,
          'Unassigned',
        );
        pharmacy = _coerceOption(
          (map['pharmacy'] ?? 'Unassigned').toString(),
          pharmacyOptions,
          'Unassigned',
        );

        // Blood group & vitals if present
        bloodGroup =
            ((map['bloodGroup'] ?? '') as String).isEmpty
                ? 'Select'
                : (map['bloodGroup'] as String);
        final vitals = (map['vitals'] ?? '').toString();
        // optional parsing vitals "Ht/Wt/BMI" not enforced; leave fields blank unless user inputs
        heightCtrl.text = '';
        weightCtrl.text = '';
        bmiCtrl.text = '';

        // Feature toggles (best-effort)
        dataSharing =
            (map['consentResearch'] ?? 'Yes').toString().toLowerCase() == 'yes';
        telemedicine =
            (map['telemedicine'] ?? 'Yes').toString().toLowerCase() == 'yes';
        otpLogin = (map['otpLogin'] ?? 'false').toString() == 'true';
        twoFA = (map['twoFA'] ?? 'false').toString() == 'true';

        setState(() => _loading = false);
      } else {
        setState(() {
          _loading = false;
        });
        _snack('Load failed: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _snack('Network error');
    }
  }

  String _coerceOption(String value, List<String> options, String fallback) {
    if (options.contains(value)) return value;
    // Try case-insensitive match
    final low = value.toLowerCase();
    for (final o in options) {
      if (o.toLowerCase() == low) return o;
    }
    return fallback;
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final uri = _buildUri('/api/patient-update');
      final body = {
        'login': widget.username,
        'fullName': nameCtrl.text.trim(),
        'dob': dobCtrl.text.trim(),
        'gender': gender == 'Select' ? '' : gender,
        'address': addressCtrl.text.trim(),
        'primaryPhone': phoneCtrl.text.trim(),
        'altPhone': altPhoneCtrl.text.trim(),
        'email': emailCtrl.text.trim(),
        'govId': idNumberCtrl.text.trim(),
        'language': language,

        // Dropdown-backed fields
        'allergies': allergies == 'None' ? '' : allergies,
        'conditions': chronicConditions == 'None' ? '' : chronicConditions,
        'chronicMeds': medications == 'None' ? '' : medications,
        'primaryDoctor': doctor == 'Unassigned' ? '' : doctor,
        'pharmacy': pharmacy == 'Unassigned' ? '' : pharmacy,

        'bloodGroup': bloodGroup == 'Select' ? '' : bloodGroup,

        // Optional extras (kept minimal)
        'consentResearch': dataSharing ? 'Yes' : 'No',
        'telemedicine': telemedicine ? 'Yes' : 'No',
        'otpLogin': otpLogin,
        'twoFA': twoFA,
      };

      final resp = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        _snack('Profile Saved');
      } else {
        _snack('Save failed: ${resp.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _snack('Network error while saving');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w800)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2F80ED),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  Future<void> _addEmergencyContactDialog() async {
    final name = TextEditingController();
    final relation = TextEditingController();
    final phone = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Emergency Contact',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              _FormField(label: 'Full Name', controller: name),
              _FormField(label: 'Relation', controller: relation),
              _FormField(
                label: 'Phone Number',
                controller: phone,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE6EAF0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF1E40FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (name.text.trim().isEmpty ||
                            relation.text.trim().isEmpty ||
                            phone.text.trim().isEmpty) {
                          _snack('Fill all fields');
                          return;
                        }
                        Navigator.pop(ctx);
                        _snack('Emergency contact added');
                      },
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _isPregnancyEnabled => gender == 'Female';

  @override
  Widget build(BuildContext context) {
    const hPad = 16.0;
    return Scaffold(
      appBar: const _TopBar(),
      body: SafeArea(
        child:
            _loading
                ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
                : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: hPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionTitle('Personal Info'),
                            const SizedBox(height: 8),
                            _TextField(
                              label: 'Full Name',
                              controller: nameCtrl,
                            ),
                            _TextField(
                              label: 'Date of Birth',
                              controller: dobCtrl,
                              trailing: Icons.calendar_today_outlined,
                            ),
                            _DropdownField(
                              label: 'Gender',
                              value: gender,
                              items: const [
                                'Select',
                                'Female',
                                'Male',
                                'Other',
                              ],
                              onChanged:
                                  (v) => setState(() {
                                    gender = v!;
                                    if (!_isPregnancyEnabled) pregnancy = false;
                                  }),
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Contacts'),
                            const SizedBox(height: 8),
                            _TextField(
                              label: 'Primary Phone',
                              controller: phoneCtrl,
                              keyboard: TextInputType.phone,
                            ),
                            _TextField(
                              label: 'Alternate Phone',
                              controller: altPhoneCtrl,
                              keyboard: TextInputType.phone,
                            ),
                            _TextField(
                              label: 'Email',
                              controller: emailCtrl,
                              keyboard: TextInputType.emailAddress,
                            ),
                            _TextField(
                              label: 'Address',
                              controller: addressCtrl,
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Government ID'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              label: 'ID Type',
                              value: idType,
                              items: const [
                                'Select',
                                'National ID',
                                'Passport',
                                'Driver License',
                              ],
                              onChanged: (v) => setState(() => idType = v!),
                            ),
                            _TextField(
                              label: 'ID Number',
                              controller: idNumberCtrl,
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Language & Accessibility'),
                            const SizedBox(height: 8),
                            _DropdownField(
                              label: 'Preferred Language',
                              value: language,
                              items: const [
                                'English',
                                'Hindi',
                                'Punjabi',
                                'Tamil',
                              ],
                              onChanged: (v) => setState(() => language = v!),
                            ),
                            _SliderField(
                              label: 'Font Size',
                              value: fontSize,
                              onChanged: (v) => setState(() => fontSize = v),
                            ),
                            _SliderField(
                              label: 'Contrast',
                              value: contrast,
                              onChanged: (v) => setState(() => contrast = v),
                            ),
                            _SwitchField(
                              label: 'Voice Prompts',
                              value: voicePrompts,
                              onChanged:
                                  (v) => setState(() => voicePrompts = v),
                              sub: 'Enable voice prompts for navigation',
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Emergency Contacts'),
                            const SizedBox(height: 8),
                            ..._contacts.map(
                              (c) => _NavRow(
                                label: c.name,
                                sub: '${c.relation} · ${c.phone}',
                                onTap: () {},
                              ),
                            ),
                            _NavRow(
                              label: 'Add Emergency Contact',
                              onTap: _addEmergencyContactDialog,
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Medical Details'),
                            const SizedBox(height: 8),

                            // Requested dropdowns
                            _DropdownField(
                              label: 'Blood Group',
                              value: bloodGroup,
                              items: const [
                                'Select',
                                'O+',
                                'O-',
                                'A+',
                                'A-',
                                'B+',
                                'B-',
                                'AB+',
                                'AB-',
                              ],
                              onChanged: (v) => setState(() => bloodGroup = v!),
                            ),
                            _DropdownField(
                              label: 'Allergies',
                              value: allergies,
                              items: allergyOptions,
                              onChanged: (v) => setState(() => allergies = v!),
                            ),
                            _DropdownField(
                              label: 'Chronic Conditions',
                              value: chronicConditions,
                              items: chronicOptions,
                              onChanged:
                                  (v) => setState(() => chronicConditions = v!),
                            ),
                            _DropdownField(
                              label: 'Medications',
                              value: medications,
                              items: medicationOptions,
                              onChanged:
                                  (v) => setState(() => medications = v!),
                            ),
                            _DropdownField(
                              label: 'Doctor',
                              value: doctor,
                              items: doctorOptions,
                              onChanged: (v) => setState(() => doctor = v!),
                            ),
                            _DropdownField(
                              label: 'Pharmacy',
                              value: pharmacy,
                              items: pharmacyOptions,
                              onChanged: (v) => setState(() => pharmacy = v!),
                            ),

                            Opacity(
                              opacity: _isPregnancyEnabled ? 1.0 : 0.5,
                              child: IgnorePointer(
                                ignoring: !_isPregnancyEnabled,
                                child: _SwitchField(
                                  label: 'Pregnancy Status',
                                  value: pregnancy,
                                  onChanged:
                                      (v) => setState(() => pregnancy = v),
                                  sub: 'Are you currently pregnant?',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const SectionTitle('Vitals & Lifestyle'),
                            const SizedBox(height: 8),
                            _TextField(
                              label: 'Height (cm)',
                              controller: heightCtrl,
                              keyboard: TextInputType.number,
                            ),
                            _TextField(
                              label: 'Weight (kg)',
                              controller: weightCtrl,
                              keyboard: TextInputType.number,
                            ),
                            _TextField(
                              label: 'BMI',
                              controller: bmiCtrl,
                              keyboard: TextInputType.number,
                            ),
                            _DropdownField(
                              label: 'Smoking/Alcohol',
                              value: smoking,
                              items: const [
                                'Select',
                                'None',
                                'Smoking',
                                'Alcohol',
                                'Both',
                              ],
                              onChanged: (v) => setState(() => smoking = v!),
                            ),
                            _DropdownField(
                              label: 'Activity Level',
                              value: activity,
                              items: const [
                                'Select',
                                'Low',
                                'Moderate',
                                'High',
                              ],
                              onChanged: (v) => setState(() => activity = v!),
                            ),

                            // Insurance section removed as requested
                            const SectionTitle('Privacy & Consent'),
                            const SizedBox(height: 8),
                            _SwitchField(
                              label: 'Data Sharing',
                              value: dataSharing,
                              onChanged: (v) => setState(() => dataSharing = v),
                              sub: 'Share data with research partners',
                            ),
                            _SwitchField(
                              label: 'Telemedicine',
                              value: telemedicine,
                              onChanged:
                                  (v) => setState(() => telemedicine = v),
                              sub: 'Allow telemedicine appointments',
                            ),
                            _SwitchField(
                              label: 'OTP Login',
                              value: otpLogin,
                              onChanged: (v) => setState(() => otpLogin = v),
                              sub: 'Enable verification and logins',
                            ),
                            _SwitchField(
                              label: '2FA',
                              value: twoFA,
                              onChanged: (v) => setState(() => twoFA = v),
                              sub: 'Enable two-factor authentication',
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE6EAF0))),
        ),
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE6EAF0)),
                    foregroundColor: const Color(0xFF111827),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saving ? null : () => Navigator.maybePop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1E40FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saving ? null : _saveProfile,
                  child:
                      _saving
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------- Models ---------- */
class _EmergencyContact {
  final String name;
  final String relation;
  final String phone;
  const _EmergencyContact({
    required this.name,
    required this.relation,
    required this.phone,
  });
}

/* ---------- Shared UI (unchanged) ---------- */
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        onPressed: () => Navigator.maybePop(context),
      ),
      centerTitle: true,
      title: const Text(
        'Edit Profile',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? trailing;
  final bool obscure;
  final TextInputType? keyboard;

  const _TextField({
    super.key,
    required this.label,
    required this.controller,
    this.trailing,
    this.obscure = false,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: label),
          const SizedBox(height: 6),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    obscureText: obscure,
                    keyboardType: keyboard,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
                if (trailing != null)
                  Icon(trailing, color: const Color(0xFF98A2B3), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: label),
          const SizedBox(height: 6),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                icon: const Icon(Icons.expand_more, color: Color(0xFF98A2B3)),
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                items:
                    items
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _UploadRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: _FieldLabel(text: label)),
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.upload_outlined,
              color: Color(0xFF8F9BAD),
              size: 18,
            ),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _SliderField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(text: label),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbColor: const Color(0xFF1E40FF),
              activeTrackColor: const Color(0xFF1E40FF),
              inactiveTrackColor: const Color(0xFFE5E7EB),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.5,
              max: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchField extends StatelessWidget {
  final String label;
  final String? sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(text: label),
                if (sub != null)
                  Text(
                    sub!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA3AF),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF1E40FF),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  final String label;
  final String? sub;
  final VoidCallback onTap;
  const _NavRow({
    super.key,
    required this.label,
    required this.onTap,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F6FA),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE6EAF0)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    if (sub != null)
                      Text(
                        sub!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  const _FormField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6FA),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE6EAF0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              keyboardType: keyboard,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
