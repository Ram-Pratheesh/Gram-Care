// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// void main() {
//   runApp(const GramCareApp());
// }

// class GramCareApp extends StatelessWidget {
//   const GramCareApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'GramCare',
//       theme: ThemeData(
//         useMaterial3: false,
//         scaffoldBackgroundColor: const Color(0xFFF7F8F5),
//         fontFamily: 'SFPro',
//         textTheme: const TextTheme(
//           titleLarge: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 0.2,
//             color: Color(0xFF0D0F10),
//           ),
//           titleMedium: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF0D0F10),
//           ),
//           bodyMedium: TextStyle(fontSize: 15, color: Color(0xFF0D0F10)),
//         ),
//         inputDecorationTheme: InputDecorationTheme(
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 16,
//             vertical: 18,
//           ),
//           hintStyle: const TextStyle(
//             color: Color(0xFF9AA3A7),
//             fontSize: 16,
//             fontWeight: FontWeight.w500,
//           ),
//           labelStyle: const TextStyle(
//             color: Color(0xFF0D0F10),
//             fontSize: 13,
//             fontWeight: FontWeight.w600,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: Color(0xFFE6E8E3), width: 1),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(14),
//             borderSide: const BorderSide(color: Color(0xFFE6E8E3), width: 1),
//           ),
//         ),
//       ),
//       home: const CreateAccountScreen(),
//     );
//   }
// }

// class CreateAccountScreen extends StatefulWidget {
//   const CreateAccountScreen({super.key});

//   @override
//   State<CreateAccountScreen> createState() => _CreateAccountScreenState();
// }

// class _CreateAccountScreenState extends State<CreateAccountScreen> {
//   final _scrollController = ScrollController();
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final fullNameCtrl = TextEditingController();
//   final dobCtrl = TextEditingController();
//   final addressCtrl = TextEditingController();
//   final primaryPhoneCtrl = TextEditingController();
//   final altPhoneCtrl = TextEditingController();
//   final emailCtrl = TextEditingController();
//   final govIdCtrl = TextEditingController();
//   final emergencyNameCtrl = TextEditingController();
//   final emergencyPhoneCtrl = TextEditingController();
//   final conditionsCtrl = TextEditingController();
//   final loginCtrl = TextEditingController();
//   final passwordCtrl = TextEditingController();

//   String? gender;
//   String? language;
//   bool agreePolicy = false;

//   // Configure backend base URL via --dart-define
//   // Android emulator: --dart-define=API_BASE=http://10.0.2.2:4000
//   // iOS simulator/Desktop/Web: --dart-define=API_BASE=http://localhost:4000
//   final _apiBaseRaw = const String.fromEnvironment(
//     'API_BASE',
//     // Default to emulator-friendly host to reduce misconfig
//     defaultValue: 'http://192.168.137.1:4000',
//   );

//   Uri _buildUri(String path, [Map<String, String>? qp]) {
//     final cleaned = _apiBaseRaw.trim().replaceFirst(RegExp(r'^%20+'), '');
//     // Basic guard: require http(s) scheme and host
//     final uri = Uri.tryParse(cleaned);
//     if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
//       throw FormatException('Invalid API_BASE "$cleaned"');
//     }
//     final basePath =
//         uri.path.endsWith('/')
//             ? uri.path.substring(0, uri.path.length - 1)
//             : uri.path;
//     return uri.replace(path: '$basePath$path', queryParameters: qp);
//   } // Build URLs safely with Uri and clear error if API_BASE is wrong. [web:29]

//   // DOB input: DD/MM/YYYY formatter
//   final List<TextInputFormatter> _dobFormatters = [
//     FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
//     _DdMmYyyyTextInputFormatter(),
//   ]; // InputFormatters constrain characters and insert slashes. [web:214]

//   String? _validateDob(String? v) {
//     final s = (v ?? '').trim();
//     if (s.isEmpty) return 'Enter date of birth (DD/MM/YYYY)';
//     final re = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
//     final m = re.firstMatch(s);
//     if (m == null) return 'Use DD/MM/YYYY';
//     final dd = int.parse(m.group(1)!);
//     final mm = int.parse(m.group(2)!);
//     final yyyy = int.parse(m.group(3)!);
//     if (mm < 1 || mm > 12) return 'Month must be 01-12';
//     final dim = <int>[
//       31,
//       _isLeap(yyyy) ? 29 : 28,
//       31,
//       30,
//       31,
//       30,
//       31,
//       31,
//       30,
//       31,
//       30,
//       31,
//     ];
//     if (dd < 1 || dd > dim[mm - 1]) return 'Invalid day for month';
//     if (yyyy < 1900 || yyyy > DateTime.now().year) return 'Enter a valid year';
//     return null;
//   } // Validates a plausible calendar date. [web:214]

//   static bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);

//   // Strict availability check: must get 200 with {available:true}
//   Future<bool> _requireLoginAvailable(String login) async {
//     try {
//       final uri = _buildUri('/api/patient-username-available', {
//         'login': login,
//       });
//       final resp = await http.get(uri);
//       debugPrint('Availability -> ${resp.statusCode} ${resp.body}');
//       if (resp.statusCode != 200) return false;
//       final data = jsonDecode(resp.body) as Map<String, dynamic>;
//       return data['available'] == true;
//     } catch (e) {
//       debugPrint('Availability error: $e');
//       return false;
//     }
//   } // Blocks if not definitively available to avoid accidental duplicates. [web:31][web:214]

//   Future<void> _submit() async {
//     final formOk = _formKey.currentState?.validate() ?? false;
//     if (!formOk) return;

//     if (!agreePolicy) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please accept the Telemedicine Policy')),
//       );
//       return;
//     }

//     final login = loginCtrl.text.trim();
//     if (login.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Login is required')));
//       return;
//     }

//     // Server-side uniqueness check for login
//     final available = await _requireLoginAvailable(login);
//     if (!mounted) return;
//     if (!available) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Username not available')));
//       return;
//     }

//     final payload = {
//       'fullName': fullNameCtrl.text.trim(),
//       'dob': dobCtrl.text.trim(),
//       'gender': gender,
//       'address': addressCtrl.text.trim(),
//       'primaryPhone': primaryPhoneCtrl.text.trim(),
//       'altPhone':
//           altPhoneCtrl.text.trim().isEmpty ? null : altPhoneCtrl.text.trim(),
//       'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
//       'govId': govIdCtrl.text.trim(),
//       'language': language,
//       'emergencyName': emergencyNameCtrl.text.trim(),
//       'emergencyPhone': emergencyPhoneCtrl.text.trim(),
//       'conditions':
//           conditionsCtrl.text.trim().isEmpty
//               ? null
//               : conditionsCtrl.text.trim(),
//       'login': login,
//       'password': passwordCtrl.text,
//       'agreePolicy': agreePolicy,
//     };

//     try {
//       final uri = _buildUri('/api/patientsigin');
//       final resp = await http.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(payload),
//       ); // JSON POST per Flutter networking docs. [web:29]

//       if (!mounted) return;

//       if (resp.statusCode == 201) {
//         final data = jsonDecode(resp.body) as Map<String, dynamic>;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Account created. ID: ${data['id']}')),
//         );
//       } else if (resp.statusCode == 409) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Username already exists')),
//         );
//       } else if (resp.statusCode == 400) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Invalid data: ${resp.body}')));
//       } else {
//         final msg =
//             resp.body.isNotEmpty ? resp.body : 'Failed with ${resp.statusCode}';
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Signup failed: $msg')));
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Network or URL error: $e')));
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     fullNameCtrl.dispose();
//     dobCtrl.dispose();
//     addressCtrl.dispose();
//     primaryPhoneCtrl.dispose();
//     altPhoneCtrl.dispose();
//     emailCtrl.dispose();
//     govIdCtrl.dispose();
//     emergencyNameCtrl.dispose();
//     emergencyPhoneCtrl.dispose();
//     conditionsCtrl.dispose();
//     loginCtrl.dispose();
//     passwordCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final topSafe = MediaQuery.of(context).padding.top;
//     return Scaffold(
//       body: Stack(
//         children: [
//           SafeArea(
//             bottom: false,
//             child: Column(
//               children: [
//                 // AppBar area
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: SizedBox(
//                     height: 56,
//                     child: Row(
//                       children: [
//                         _IconCircleButton(
//                           icon: Icons.close_rounded,
//                           onTap: () {},
//                         ),
//                         const SizedBox(width: 8),
//                         const Expanded(
//                           child: Text(
//                             'GramCare',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w700,
//                               color: Color(0xFF0D0F10),
//                               letterSpacing: 0.2,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 40),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Title
//                 const Padding(
//                   padding: EdgeInsets.fromLTRB(20, 6, 20, 12),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       'Create your account',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.w800,
//                         color: Color(0xFF0D0F10),
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Form
//                 Expanded(
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       final isNarrow = constraints.maxWidth < 380;
//                       return SingleChildScrollView(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
//                         child: Form(
//                           key: _formKey,
//                           autovalidateMode:
//                               AutovalidateMode
//                                   .onUserInteraction, // realtime validation [web:214]
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const _FieldLabel('Full Name'),
//                               _TextFieldBox(
//                                 hint: 'Enter your full name',
//                                 controller: fullNameCtrl,
//                                 keyboardType: TextInputType.name,
//                                 validator:
//                                     (v) =>
//                                         v == null || v.trim().isEmpty
//                                             ? 'Full name is required'
//                                             : null,
//                               ),
//                               const SizedBox(height: 16),

//                               // DOB + Gender Row
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const _FieldLabel('Date of Birth'),
//                                         _TextFieldBox(
//                                           hint: 'DD/MM/YYYY',
//                                           controller: dobCtrl,
//                                           keyboardType: TextInputType.datetime,
//                                           inputFormatters: _dobFormatters,
//                                           validator: _validateDob,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const _FieldLabel('Gender'),
//                                         _DropdownBox<String>(
//                                           value: gender,
//                                           hint: 'Select',
//                                           items: const [
//                                             'Male',
//                                             'Female',
//                                             'Other',
//                                           ],
//                                           onChanged:
//                                               (v) => setState(() => gender = v),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Address'),
//                               _TextFieldBox(
//                                 hint: 'Enter your full address',
//                                 controller: addressCtrl,
//                                 maxLines: 3,
//                                 textInputAction: TextInputAction.newline,
//                                 validator:
//                                     (v) =>
//                                         v == null || v.trim().isEmpty
//                                             ? 'Address is required'
//                                             : null,
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Primary Phone Number'),
//                               _TextFieldBox(
//                                 hint: 'Enter your primary phone number',
//                                 controller: primaryPhoneCtrl,
//                                 keyboardType: TextInputType.phone,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.allow(
//                                     RegExp(r'[0-9+\-\s]'),
//                                   ),
//                                 ],
//                                 validator:
//                                     (v) =>
//                                         v == null || v.trim().length < 7
//                                             ? 'Enter a valid phone'
//                                             : null,
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel(
//                                 'Alternate Phone Number (Optional)',
//                               ),
//                               _TextFieldBox(
//                                 hint: 'Enter alternate phone number',
//                                 controller: altPhoneCtrl,
//                                 keyboardType: TextInputType.phone,
//                                 inputFormatters: [
//                                   FilteringTextInputFormatter.allow(
//                                     RegExp(r'[0-9+\-\s]'),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Email (Optional)'),
//                               _TextFieldBox(
//                                 hint: 'Enter your email',
//                                 controller: emailCtrl,
//                                 keyboardType: TextInputType.emailAddress,
//                                 validator: (v) {
//                                   final s = (v ?? '').trim();
//                                   if (s.isEmpty) return null;
//                                   final re = RegExp(
//                                     r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
//                                   );
//                                   return re.hasMatch(s)
//                                       ? null
//                                       : 'Enter a valid email';
//                                 },
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Unique Government ID'),
//                               _TextFieldBox(
//                                 hint: 'Enter your government ID',
//                                 controller: govIdCtrl,
//                                 textCapitalization:
//                                     TextCapitalization.characters,
//                                 validator:
//                                     (v) =>
//                                         v == null || v.trim().isEmpty
//                                             ? 'Government ID is required'
//                                             : null,
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Language Preference'),
//                               _DropdownBox<String>(
//                                 value: language,
//                                 hint: 'Select Language',
//                                 items: const [
//                                   'English',
//                                   'Hindi',
//                                   'Bengali',
//                                   'Tamil',
//                                   'Telugu',
//                                   'Marathi',
//                                   'Gujarati',
//                                 ],
//                                 onChanged: (v) => setState(() => language = v),
//                               ),
//                               const SizedBox(height: 16),

//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const _FieldLabel(
//                                           'Emergency Contact\nName',
//                                         ),
//                                         _TextFieldBox(
//                                           hint: 'Name',
//                                           controller: emergencyNameCtrl,
//                                           keyboardType: TextInputType.name,
//                                           validator:
//                                               (v) =>
//                                                   v == null || v.trim().isEmpty
//                                                       ? 'Emergency contact name required'
//                                                       : null,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const _FieldLabel('Phone'),
//                                         _TextFieldBox(
//                                           hint: 'Phone number',
//                                           controller: emergencyPhoneCtrl,
//                                           keyboardType: TextInputType.phone,
//                                           inputFormatters: [
//                                             FilteringTextInputFormatter.allow(
//                                               RegExp(r'[0-9+\-\s]'),
//                                             ),
//                                           ],
//                                           validator:
//                                               (v) =>
//                                                   v == null ||
//                                                           v.trim().length < 7
//                                                       ? 'Enter a valid phone'
//                                                       : null,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel(
//                                 'Existing Medical Conditions / Allergies (Optional)',
//                               ),
//                               _TextFieldBox(
//                                 hint: 'List any conditions or allergies',
//                                 controller: conditionsCtrl,
//                                 maxLines: 3,
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel(
//                                 'Username or Phone Number for Login',
//                               ),
//                               _TextFieldBox(
//                                 hint: 'Enter username or phone number',
//                                 controller: loginCtrl,
//                                 validator:
//                                     (v) =>
//                                         v == null || v.trim().length < 3
//                                             ? 'Enter a username (min 3 chars)'
//                                             : null,
//                               ),
//                               const SizedBox(height: 16),

//                               const _FieldLabel('Password'),
//                               _TextFieldBox(
//                                 hint: 'Create a password',
//                                 controller: passwordCtrl,
//                                 obscureText: true,
//                                 validator:
//                                     (v) =>
//                                         v == null || v.length < 6
//                                             ? 'Minimum 6 characters'
//                                             : null,
//                               ),
//                               const SizedBox(height: 14),

//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 24,
//                                     height: 24,
//                                     child: Checkbox(
//                                       value: agreePolicy,
//                                       onChanged:
//                                           (v) => setState(
//                                             () => agreePolicy = v ?? false,
//                                           ),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       side: const BorderSide(
//                                         color: Color(0xFFE0E3DD),
//                                       ),
//                                       activeColor: const Color(0xFF22C55E),
//                                       materialTapTargetSize:
//                                           MaterialTapTargetSize.shrinkWrap,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   Expanded(
//                                     child: RichText(
//                                       text: TextSpan(
//                                         style: TextStyle(
//                                           color: Color(0xFF0D0F10),
//                                           fontSize: 14,
//                                           height: 1.4,
//                                         ),
//                                         children: [
//                                           TextSpan(text: 'I agree to the '),
//                                           TextSpan(
//                                             text: 'Telemedicine Policy',
//                                             style: TextStyle(
//                                               color: Color(0xFF0EA5E9),
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),

//                               SizedBox(
//                                 width: double.infinity,
//                                 height: 56,
//                                 child: ElevatedButton(
//                                   onPressed: _submit,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFF22C55E),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(14),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: const Text(
//                                     'Submit',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w700,
//                                       letterSpacing: 0.2,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: topSafe + 8),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
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

// // Widgets

// class _IconCircleButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _IconCircleButton({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(20),
//       child: Container(
//         width: 36,
//         height: 36,
//         decoration: BoxDecoration(
//           color: const Color(0xFFEFF2EC),
//           borderRadius: BorderRadius.circular(18),
//         ),
//         child: Icon(icon, size: 22, color: const Color(0xFF0D0F10)),
//       ),
//     );
//   }
// }

// class _FieldLabel extends StatelessWidget {
//   final String text;
//   const _FieldLabel(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontSize: 13,
//           fontWeight: FontWeight.w700,
//           color: Color(0xFF0D0F10),
//           letterSpacing: 0.15,
//         ),
//       ),
//     );
//   }
// }

// class _TextFieldBox extends StatelessWidget {
//   final String hint;
//   final TextEditingController controller;
//   final TextInputType? keyboardType;
//   final bool obscureText;
//   final int maxLines;
//   final TextInputAction? textInputAction;
//   final TextCapitalization textCapitalization;
//   final List<TextInputFormatter>? inputFormatters;
//   final String? Function(String?)? validator;

//   const _TextFieldBox({
//     required this.hint,
//     required this.controller,
//     this.keyboardType,
//     this.obscureText = false,
//     this.maxLines = 1,
//     this.textInputAction,
//     this.textCapitalization = TextCapitalization.none,
//     this.inputFormatters,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       obscureText: obscureText,
//       maxLines: obscureText ? 1 : maxLines,
//       textInputAction: textInputAction,
//       textCapitalization: textCapitalization,
//       inputFormatters: inputFormatters,
//       validator: validator,
//       style: const TextStyle(
//         fontSize: 16,
//         color: Color(0xFF0D0F10),
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: InputDecoration(hintText: hint),
//     );
//   }
// }

// class _DropdownBox<T> extends StatelessWidget {
//   final T? value;
//   final String hint;
//   final List<T> items;
//   final ValueChanged<T?> onChanged;

//   const _DropdownBox({
//     required this.value,
//     required this.hint,
//     required this.items,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return DropdownButtonFormField<T>(
//       value: value,
//       items:
//           items
//               .map(
//                 (e) => DropdownMenuItem<T>(
//                   value: e,
//                   child: Text(
//                     '$e',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Color(0xFF0D0F10),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               )
//               .toList(),
//       onChanged: onChanged,
//       icon: const Icon(
//         Icons.keyboard_arrow_down_rounded,
//         color: Color(0xFF6B7280),
//       ),
//       decoration: InputDecoration(hintText: hint),
//       style: const TextStyle(
//         fontSize: 16,
//         color: Color(0xFF0D0F10),
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }
// }

// // Custom formatter to build DD/MM/YYYY progressively
// class _DdMmYyyyTextInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
//     final buffer = StringBuffer();
//     for (var i = 0; i < digits.length && i < 8; i++) {
//       buffer.write(digits[i]);
//       if (i == 1 || i == 3) buffer.write('/');
//     }
//     final formatted = buffer.toString();
//     return TextEditingValue(
//       text: formatted,
//       selection: TextSelection.collapsed(offset: formatted.length),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// Add this: make sure the package name path matches your pubspec + lib folder layout
import 'package:gramcare/frontend/loginpage.dart'; // expects GramCareLoginApp widget. [Adjust if needed] [web:31]

void main() {
  runApp(const GramCareApp());
}

class GramCareApp extends StatelessWidget {
  const GramCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GramCare',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        fontFamily: 'SFPro',
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: Color(0xFF0D0F10),
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D0F10),
          ),
          bodyMedium: TextStyle(fontSize: 15, color: Color(0xFF0D0F10)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF9AA3A7),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF0D0F10),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8E3), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE6E8E3), width: 1),
          ),
        ),
      ),
      home: const CreateAccountScreen(),
    );
  }
}

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final fullNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final primaryPhoneCtrl = TextEditingController();
  final altPhoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final govIdCtrl = TextEditingController();
  final emergencyNameCtrl = TextEditingController();
  final emergencyPhoneCtrl = TextEditingController();
  final conditionsCtrl = TextEditingController();
  final loginCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  String? gender;
  String? language;
  bool agreePolicy = false;

  // API base (LAN IP provided by you)
  final _apiBaseRaw = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://192.168.137.1:4001',
  );

  Uri _buildUri(String path, [Map<String, String>? qp]) {
    final cleaned = _apiBaseRaw.trim().replaceFirst(RegExp(r'^%20+'), '');
    final uri = Uri.tryParse(cleaned);
    if (uri == null || !(uri.hasScheme && uri.hasAuthority)) {
      throw FormatException('Invalid API_BASE "$cleaned"');
    }
    final basePath =
        uri.path.endsWith('/')
            ? uri.path.substring(0, uri.path.length - 1)
            : uri.path;
    return uri.replace(path: '$basePath$path', queryParameters: qp);
  } // Build URLs safely. [web:29]

  // DOB input: DD/MM/YYYY
  final List<TextInputFormatter> _dobFormatters = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
    _DdMmYyyyTextInputFormatter(),
  ]; // Slashes auto-inserted. [web:214]

  String? _validateDob(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Enter date of birth (DD/MM/YYYY)';
    final re = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final m = re.firstMatch(s);
    if (m == null) return 'Use DD/MM/YYYY';
    final dd = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final yyyy = int.parse(m.group(3)!);
    if (mm < 1 || mm > 12) return 'Month must be 01-12';
    final dim = <int>[
      31,
      _isLeap(yyyy) ? 29 : 28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];
    if (dd < 1 || dd > dim[mm - 1]) return 'Invalid day for month';
    if (yyyy < 1900 || yyyy > DateTime.now().year) return 'Enter a valid year';
    return null;
  } // Date validation. [web:214]

  static bool _isLeap(int y) => (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0);

  // Require definitive available:true
  Future<bool> _requireLoginAvailable(String login) async {
    try {
      final uri = _buildUri('/api/patient-username-available', {
        'login': login,
      });
      final resp = await http.get(uri);
      debugPrint('Availability -> ${resp.statusCode} ${resp.body}');
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['available'] == true;
    } catch (e) {
      debugPrint('Availability error: $e');
      return false;
    }
  } // Strict check. [web:31][web:214]

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return;

    if (!agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Telemedicine Policy')),
      );
      return;
    }

    final login = loginCtrl.text.trim();
    if (login.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login is required')));
      return;
    }

    final available = await _requireLoginAvailable(login);
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username not available')));
      return;
    }

    final payload = {
      'fullName': fullNameCtrl.text.trim(),
      'dob': dobCtrl.text.trim(),
      'gender': gender,
      'address': addressCtrl.text.trim(),
      'primaryPhone': primaryPhoneCtrl.text.trim(),
      'altPhone':
          altPhoneCtrl.text.trim().isEmpty ? null : altPhoneCtrl.text.trim(),
      'email': emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      'govId': govIdCtrl.text.trim(),
      'language': language,
      'emergencyName': emergencyNameCtrl.text.trim(),
      'emergencyPhone': emergencyPhoneCtrl.text.trim(),
      'conditions':
          conditionsCtrl.text.trim().isEmpty
              ? null
              : conditionsCtrl.text.trim(),
      'login': login,
      'password': passwordCtrl.text,
      'agreePolicy': agreePolicy,
    };

    try {
      final uri = _buildUri('/api/patientsigin');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ); // JSON POST. [web:29]

      if (!mounted) return;

      if (resp.statusCode == 201) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created. ID: ${data['id']}')),
        );
      } else if (resp.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      } else if (resp.statusCode == 400) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid data: ${resp.body}')));
      } else {
        final msg =
            resp.body.isNotEmpty ? resp.body : 'Failed with ${resp.statusCode}';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Signup failed: $msg')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network or URL error: $e')));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    fullNameCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    primaryPhoneCtrl.dispose();
    altPhoneCtrl.dispose();
    emailCtrl.dispose();
    govIdCtrl.dispose();
    emergencyNameCtrl.dispose();
    emergencyPhoneCtrl.dispose();
    conditionsCtrl.dispose();
    loginCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topSafe = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // AppBar area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        _IconCircleButton(
                          icon: Icons.close_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'GramCare',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0D0F10),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                ),
                // Title
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0D0F10),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                // Form
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 380;
                      return SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                        child: Form(
                          key: _formKey,
                          autovalidateMode:
                              AutovalidateMode
                                  .onUserInteraction, // realtime validation [web:214]
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Full Name'),
                              _TextFieldBox(
                                hint: 'Enter your full name',
                                controller: fullNameCtrl,
                                keyboardType: TextInputType.name,
                                validator:
                                    (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Full name is required'
                                            : null,
                              ),
                              const SizedBox(height: 16),

                              // DOB + Gender Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _FieldLabel('Date of Birth'),
                                        _TextFieldBox(
                                          hint: 'DD/MM/YYYY',
                                          controller: dobCtrl,
                                          keyboardType: TextInputType.datetime,
                                          inputFormatters: _dobFormatters,
                                          validator: _validateDob,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _FieldLabel('Gender'),
                                        _DropdownBox<String>(
                                          value: gender,
                                          hint: 'Select',
                                          items: const [
                                            'Male',
                                            'Female',
                                            'Other',
                                          ],
                                          onChanged:
                                              (v) => setState(() => gender = v),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Address'),
                              _TextFieldBox(
                                hint: 'Enter your full address',
                                controller: addressCtrl,
                                maxLines: 3,
                                textInputAction: TextInputAction.newline,
                                validator:
                                    (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Address is required'
                                            : null,
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Primary Phone Number'),
                              _TextFieldBox(
                                hint: 'Enter your primary phone number',
                                controller: primaryPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+\-\s]'),
                                  ),
                                ],
                                validator:
                                    (v) =>
                                        v == null || v.trim().length < 7
                                            ? 'Enter a valid phone'
                                            : null,
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel(
                                'Alternate Phone Number (Optional)',
                              ),
                              _TextFieldBox(
                                hint: 'Enter alternate phone number',
                                controller: altPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9+\-\s]'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Email (Optional)'),
                              _TextFieldBox(
                                hint: 'Enter your email',
                                controller: emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  final s = (v ?? '').trim();
                                  if (s.isEmpty) return null;
                                  final re = RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  );
                                  return re.hasMatch(s)
                                      ? null
                                      : 'Enter a valid email';
                                },
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Unique Government ID'),
                              _TextFieldBox(
                                hint: 'Enter your government ID',
                                controller: govIdCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator:
                                    (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Government ID is required'
                                            : null,
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Language Preference'),
                              _DropdownBox<String>(
                                value: language,
                                hint: 'Select Language',
                                items: const [
                                  'English',
                                  'Hindi',
                                  'Bengali',
                                  'Tamil',
                                  'Telugu',
                                  'Marathi',
                                  'Gujarati',
                                ],
                                onChanged: (v) => setState(() => language = v),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _FieldLabel(
                                          'Emergency Contact\nName',
                                        ),
                                        _TextFieldBox(
                                          hint: 'Name',
                                          controller: emergencyNameCtrl,
                                          keyboardType: TextInputType.name,
                                          validator:
                                              (v) =>
                                                  v == null || v.trim().isEmpty
                                                      ? 'Emergency contact name required'
                                                      : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const _FieldLabel('Phone'),
                                        _TextFieldBox(
                                          hint: 'Phone number',
                                          controller: emergencyPhoneCtrl,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9+\-\s]'),
                                            ),
                                          ],
                                          validator:
                                              (v) =>
                                                  v == null ||
                                                          v.trim().length < 7
                                                      ? 'Enter a valid phone'
                                                      : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel(
                                'Existing Medical Conditions / Allergies (Optional)',
                              ),
                              _TextFieldBox(
                                hint: 'List any conditions or allergies',
                                controller: conditionsCtrl,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel(
                                'Username or Phone Number for Login',
                              ),
                              _TextFieldBox(
                                hint: 'Enter username or phone number',
                                controller: loginCtrl,
                                validator:
                                    (v) =>
                                        v == null || v.trim().length < 3
                                            ? 'Enter a username (min 3 chars)'
                                            : null,
                              ),
                              const SizedBox(height: 16),

                              const _FieldLabel('Password'),
                              _TextFieldBox(
                                hint: 'Create a password',
                                controller: passwordCtrl,
                                obscureText: true,
                                validator:
                                    (v) =>
                                        v == null || v.length < 6
                                            ? 'Minimum 6 characters'
                                            : null,
                              ),
                              const SizedBox(height: 14),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: agreePolicy,
                                      onChanged:
                                          (v) => setState(
                                            () => agreePolicy = v ?? false,
                                          ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFFE0E3DD),
                                      ),
                                      activeColor: const Color(0xFF22C55E),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          color: Color(0xFF0D0F10),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                        children: [
                                          TextSpan(text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Telemedicine Policy',
                                            style: TextStyle(
                                              color: Color(0xFF0EA5E9),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF22C55E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Added: Already have an account? Log in
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  children: [
                                    const Text(
                                      'Already have an account?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF4B5563),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder:
                                                (_) => const GramCareLoginApp(),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        'Log in',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF0EA5E9),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: topSafe + 8),
                            ],
                          ),
                        ),
                      );
                    },
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

// Widgets

class _IconCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2EC),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 22, color: const Color(0xFF0D0F10)),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D0F10),
          letterSpacing: 0.15,
        ),
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _TextFieldBox({
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : maxLines,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF0D0F10),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(hintText: hint),
    );
  }
}

class _DropdownBox<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items:
          items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(
                    '$e',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D0F10),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF6B7280),
      ),
      decoration: InputDecoration(hintText: hint),
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF0D0F10),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Custom formatter to build DD/MM/YYYY progressively
class _DdMmYyyyTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 3) buffer.write('/');
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
