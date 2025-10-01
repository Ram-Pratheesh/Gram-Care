import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Patient signup
import 'package:gramcare/frontend/patients/siginpatient.dart'; // GramCareApp
// Patient home page
import 'package:gramcare/frontend/patients/patienthomepage.dart'; // GramCareHomeApp
// Doctor registration
import 'package:gramcare/frontend/doctor/doctorreg.dart';
// Doctor dashboard (expects jwtToken)
import 'package:gramcare/frontend/doctor/dashboard.dart';

void main() => runApp(const GramCareLoginApp());

class GramCareLoginApp extends StatelessWidget {
  const GramCareLoginApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        fontFamily: 'SFPro',
        primaryColor: const Color(0xFF0EA5E9),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF9AA3AF),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9DEE4), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD9DEE4), width: 1),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? userType; // 'Patient' or 'Doctor' etc.
  final usernameCtrl =
      TextEditingController(); // For Patient: username, Doctor: email
  final passwordCtrl = TextEditingController();
  bool obscure = true;
  bool rememberMe = false;
  bool _loading = false;

  // API base (LAN IP or emulator loopback)
  static const String _apiBase = 'http://192.168.137.1:4001';

  Uri _buildUri(String path) {
    final base = Uri.parse(_apiBase);
    final basePath =
        base.path.endsWith('/')
            ? base.path.substring(0, base.path.length - 1)
            : base.path;
    return base.replace(path: '$basePath$path');
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final type = (userType ?? '').trim();
    final userInput = usernameCtrl.text.trim();
    final password = passwordCtrl.text;

    if (type.isEmpty) {
      _toast('Please select a user type');
      return;
    }
    if (userInput.isEmpty) {
      _toast(type == 'Doctor' ? 'Enter email' : 'Enter username/phone/email');
      return;
    }
    if (password.isEmpty) {
      _toast('Enter password');
      return;
    }
    if (type == 'Doctor' && !_isValidEmail(userInput)) {
      _toast('Enter a valid email for Doctor login');
      return;
    }

    setState(() => _loading = true);
    try {
      final uri = _buildUri('/api/login');
      final body = <String, dynamic>{
        'userType': type,
        'username': userInput, // Patient: username; Doctor: email as username
        'password': password,
        'remember': rememberMe,
      };
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (resp.statusCode == 200) {
        // Optional: if your backend later returns a token, parse and use it
        String token = '';
        try {
          final data = jsonDecode(resp.body);
          token = data['token']?.toString() ?? '';
        } catch (_) {}

        _navigateHomeByRole(type, token);
      } else if (resp.statusCode == 401 || resp.statusCode == 404) {
        _toast("Account doesn't exist or wrong password");
      } else {
        final msg =
            resp.body.isNotEmpty ? resp.body : 'Failed with ${resp.statusCode}';
        _toast('Login failed: $msg');
      }
    } catch (e) {
      if (!mounted) return;
      _toast('Network or URL error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _navigateHomeByRole(String type, String token) {
    if (type == 'Patient') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GramCareHomeApp(username: usernameCtrl.text.trim()),
        ),
      );
      return;
    }
    if (type == 'Doctor') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DoctorDashboardApp(jwtToken: token)),
      );
      return;
    }
    // Other roles not implemented
    _toast('$type home not wired yet');
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _openRolePicker() async {
    String? picked;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD9DEE4), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: StatefulBuilder(
              builder: (ctx, setStateDialog) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Choose your role',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF6B7280),
                          ),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Select how to sign up to continue.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _roleTile(
                      'Patient',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 8),
                    _roleTile(
                      'Doctor',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 8),
                    _roleTile(
                      'Pharmacy',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 8),
                    _roleTile(
                      'HealthWorker',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 8),
                    _roleTile(
                      'GovernmentOfficial',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 8),
                    _roleTile(
                      'Admin',
                      picked,
                      (v) => setStateDialog(() => picked = v),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _GcDialogActionButton(
                            label: 'Cancel',
                            onPressed: () => Navigator.of(ctx).pop(),
                            filled: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _GcDialogActionButton(
                            label: 'Sign Up',
                            onPressed:
                                picked == null
                                    ? null
                                    : () {
                                      Navigator.of(ctx).pop();
                                      _navigateSignup(picked!);
                                    },
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _roleTile(String value, String? picked, ValueChanged<String> onPick) {
    final selected = picked == value;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onPick(value),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF0EA5E9) : const Color(0xFFD9DEE4),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD9DEE4)),
              ),
              child: Icon(
                Icons.badge_outlined,
                size: 16,
                color:
                    selected
                        ? const Color(0xFF0EA5E9)
                        : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: picked,
              onChanged: (v) {
                if (v != null) onPick(v);
              },
              activeColor: const Color(0xFF0EA5E9),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateSignup(String role) {
    if (role == 'Patient') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const GramCareApp()));
      return;
    }
    if (role == 'Doctor') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const DoctorRegistrationPage()));
      return;
    }
    _toast('Signup page for $role not implemented yet');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final p = MediaQuery.of(context).padding;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, cons) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 24 + p.top, 24, 24 + p.bottom),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: cons.maxHeight - p.vertical - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'GramCare',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          _RoundIconButton(
                            icon: Icons.language_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Login to continue your journey',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _FieldLabel(''),
                      DropdownButtonFormField<String>(
                        value: userType,
                        hint: const Text('Select User Type'),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF6B7280),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Patient',
                            child: Text('Patient'),
                          ),
                          DropdownMenuItem(
                            value: 'Doctor',
                            child: Text('Doctor'),
                          ),
                          DropdownMenuItem(
                            value: 'Pharmacy',
                            child: Text('Pharmacy'),
                          ),
                          DropdownMenuItem(
                            value: 'HealthWorker',
                            child: Text('HealthWorker'),
                          ),
                          DropdownMenuItem(
                            value: 'GovernmentOfficial',
                            child: Text('GovernmentOfficial'),
                          ),
                          DropdownMenuItem(
                            value: 'Admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (v) => setState(() => userType = v),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: usernameCtrl,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText:
                              userType == 'Doctor'
                                  ? 'Email'
                                  : 'Username / Phone Number / Email',
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordCtrl,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged:
                                  (v) =>
                                      setState(() => rememberMe = v ?? false),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              side: const BorderSide(color: Color(0xFFD1D5DB)),
                              activeColor: const Color(0xFF0EA5E9),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Remember Me',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color(0xFF0EA5E9),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EA5E9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              _loading
                                  ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Spacer(),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openRolePicker,
                              child: const Text(
                                'Sign up',
                                style: TextStyle(
                                  color: Color(0xFF0EA5E9),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
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
          },
        ),
      ),
    );
  }
}

// Helper widgets
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD9DEE4), width: 1),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF374151)),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: const Color(0xFFE5E7EB));
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
        ),
      ),
    );
  }
}

class _GcDialogActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  const _GcDialogActionButton({
    required this.label,
    required this.onPressed,
    required this.filled,
  });
  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF0EA5E9) : Colors.white;
    final fg = filled ? Colors.white : const Color(0xFF0EA5E9);
    final side = BorderSide(
      color: const Color(0xFF0EA5E9).withOpacity(0.9),
      width: 1,
    );
    return SizedBox(
      height: 46,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: filled ? BorderSide.none : side,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        child: Text(label),
      ),
    );
  }
}
