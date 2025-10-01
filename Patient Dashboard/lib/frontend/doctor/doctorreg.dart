import 'package:flutter/material.dart';
import 'package:gramcare/frontend/doctor/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorRegistrationPage extends StatefulWidget {
  const DoctorRegistrationPage({super.key});

  @override
  State<DoctorRegistrationPage> createState() => _DoctorRegistrationPageState();
}

class _DoctorRegistrationPageState extends State<DoctorRegistrationPage> {
  // Form controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController medicalRegNoController = TextEditingController();
  final TextEditingController qualificationsController =
      TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Form state
  String? selectedGender;
  String? selectedSpecialization;
  bool isLoading = false;
  bool isOtpVerified = false;

  // API configuration
  static const String baseUrl =
      'http://192.168.137.1:4001/api'; // Change to your backend URL

  final List<String> genders = ['Male', 'Female', 'Other'];
  final List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'General',
    'Orthopedics',
    'Pediatrics',
    'Gynecology',
    'Psychiatry',
  ];

  @override
  void dispose() {
    // Dispose all controllers
    fullNameController.dispose();
    dobController.dispose();
    medicalRegNoController.dispose();
    qualificationsController.dispose();
    experienceController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showOTPDialog() {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OTP Verification'),
          content: SizedBox(
            width: 300,
            height: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('OTP sent to ${mobileController.text}'),
                const SizedBox(height: 16),
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(
                    hintText: 'Enter OTP',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // For demo purposes, accept any 6-digit OTP
                if (otpController.text.length == 6) {
                  setState(() {
                    isOtpVerified = true;
                  });
                  Navigator.pop(context);
                  _showSnackBar('OTP Verified Successfully', Colors.green);
                } else {
                  _showSnackBar('Please enter a valid 6-digit OTP', Colors.red);
                }
              },
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    mobileController.addListener(() {
      setState(() {}); // rebuild when mobile number changes
    });
  }

  bool _validateForm() {
    if (fullNameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your full name', Colors.red);
      return false;
    }
    if (dobController.text.trim().isEmpty) {
      _showSnackBar('Please select your date of birth', Colors.red);
      return false;
    }
    if (selectedGender == null) {
      _showSnackBar('Please select your gender', Colors.red);
      return false;
    }
    if (medicalRegNoController.text.trim().isEmpty) {
      _showSnackBar(
        'Please enter your medical registration number',
        Colors.red,
      );
      return false;
    }
    if (qualificationsController.text.trim().isEmpty) {
      _showSnackBar('Please enter your qualifications', Colors.red);
      return false;
    }
    if (selectedSpecialization == null) {
      _showSnackBar('Please select your specialization', Colors.red);
      return false;
    }
    if (experienceController.text.trim().isEmpty) {
      _showSnackBar('Please enter your experience in years', Colors.red);
      return false;
    }
    if (mobileController.text.trim().isEmpty) {
      _showSnackBar('Please enter your mobile number', Colors.red);
      return false;
    }
    if (!isOtpVerified) {
      _showSnackBar('Please verify your mobile number with OTP', Colors.red);
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      _showSnackBar('Please enter your email address', Colors.red);
      return false;
    }
    if (!_isValidEmail(emailController.text.trim())) {
      _showSnackBar('Please enter a valid email address', Colors.red);
      return false;
    }
    if (passwordController.text.isEmpty) {
      _showSnackBar('Please enter a password', Colors.red);
      return false;
    }
    if (passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long', Colors.red);
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  String _formatDateForAPI(String displayDate) {
    // Convert from "dd-mm-yyyy" to "yyyy-mm-dd"
    final parts = displayDate.split('-');
    if (parts.length == 3) {
      return '${parts[2]}-${parts[1]}-${parts[0]}';
    }
    return displayDate;
  }

  Future<void> _registerDoctor() async {
    if (!_validateForm()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final registrationData = {
        'fullName': fullNameController.text.trim(),
        'dateOfBirth': _formatDateForAPI(dobController.text.trim()),
        'gender': selectedGender,
        'medicalRegNo': medicalRegNoController.text.trim(),
        'qualifications': qualificationsController.text.trim(),
        'specialization': selectedSpecialization,
        'experience': int.parse(experienceController.text.trim()),
        'mobileNumber': mobileController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'password': passwordController.text,
        'confirmPassword': confirmPasswordController.text,
      };

      final uri = Uri.parse('$baseUrl/doctor/register');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        // Save token and doctor payload (token may be null in current backend)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'auth_token',
          responseData['token']?.toString() ?? '',
        );
        await prefs.setString('user_type', 'doctor');
        await prefs.setString(
          'doctor_data',
          json.encode(responseData['doctor']),
        );

        _showSnackBar('Registration successful!', Colors.green);

        // Navigate to Dashboard (pass token even if empty string)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DoctorDashboardApp(
                  jwtToken: responseData['token']?.toString() ?? '',
                ),
          ),
        );
      } else {
        String errorMessage = 'Registration failed';
        if (responseData is Map && responseData['error'] != null) {
          errorMessage = responseData['error'].toString();
        } else if (responseData is Map && responseData['details'] != null) {
          errorMessage = responseData['details'].toString();
        }
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      _showSnackBar(
        'Network error. Please check your connection and try again.',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TopHeader(),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Doctor Registration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Create your account to join our telemedicine platform.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B6B6B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            controller: fullNameController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DateInputField(
                            label: 'Date of Birth',
                            hint: 'dd-mm-yyyy',
                            controller: dobController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownField(
                            label: 'Gender',
                            hint: 'Select Gender',
                            value: selectedGender,
                            items: genders,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomInputField(
                            label: 'Medical Reg No',
                            hint: 'Enter your registration number',
                            controller: medicalRegNoController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomInputField(
                            label: 'Qualifications',
                            hint: 'e.g., MBBS, MD',
                            controller: qualificationsController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownField(
                            label: 'Specialization',
                            hint: 'Select Specialization',
                            value: selectedSpecialization,
                            items: specializations,
                            onChanged: (value) {
                              setState(() {
                                selectedSpecialization = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Experience (Years)',
                      hint: 'Enter years of experience',
                      controller: experienceController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CustomInputField(
                            label: 'Mobile Number',
                            hint: 'Enter your mobile number',
                            controller: mobileController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(' ', style: TextStyle(fontSize: 13)),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 48,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      mobileController.text.isNotEmpty &&
                                              !isOtpVerified
                                          ? _showOTPDialog
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isOtpVerified
                                            ? Colors.green
                                            : const Color(0xFF4DB5E4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isOtpVerified ? 'Verified ✓' : 'Verify OTP',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Email address',
                      hint: 'Enter your email',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    PasswordField(controller: passwordController),
                    const SizedBox(height: 16),
                    CustomInputField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: confirmPasswordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _registerDoctor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Register',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6),
        const Text(
          'GramCare',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class CustomInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}

class DateInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;

  const DateInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.calendar_today,
              size: 18,
              color: Color(0xFF6B6B6B),
            ),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1),
            ),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              controller.text =
                  "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
            }
          },
        ),
      ],
    );
  }
}

class DropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final Function(String?) onChanged;

  const DropdownField({
    super.key,
    required this.label,
    required this.hint,
    this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                hint,
                style: const TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
              ),
              isExpanded: true,
              onChanged: onChanged,
              items:
                  items
                      .map(
                        (String item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController? controller;

  const PasswordField({super.key, this.controller});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: 'Create a password',
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9B9B9B)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF6B6B6B),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD9D9D9), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
