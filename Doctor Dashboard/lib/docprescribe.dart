import 'package:flutter/material.dart';
import 'package:gramcare/docpatprescselect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PrescribeApp extends StatelessWidget {
  final Patient selectedPatient; // ✅ Store the passed patient

  const PrescribeApp({super.key, required this.selectedPatient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prescribe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
        useMaterial3: false,
      ),
      home: PrescribeScreen(
        selectedPatient: selectedPatient,
      ), // ✅ Pass it forward
    );
  }
}

class PrescribeScreen extends StatefulWidget {
  final Patient selectedPatient; // ✅ Receive patient data

  const PrescribeScreen({super.key, required this.selectedPatient});

  @override
  State<PrescribeScreen> createState() => _PrescribeScreenState();
}

class _PrescribeScreenState extends State<PrescribeScreen> {
  // API Configuration
  static const String baseUrl = 'http://172.16.58.254:4000';
  static const String apiEndpoint = '$baseUrl/api/doctor/issue';

  // Controllers
  final TextEditingController patientIdCtrl = TextEditingController();
  final TextEditingController ageCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController issuesCtrl = TextEditingController();
  final TextEditingController medsCtrl = TextEditingController();
  final TextEditingController doseCtrl = TextEditingController();
  final TextEditingController freqCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();
  final TextEditingController consultationDateCtrl = TextEditingController();
  final TextEditingController expiryDateCtrl = TextEditingController();

  final ScrollController _scroll = ScrollController();
  final GlobalKey _reviewKey = GlobalKey();

  String selectedGender = 'Female';
  File? selectedFile;
  bool isSubmitting = false;

  final List<_ReviewEntry> _review = [];

  @override
  void initState() {
    super.initState();
    // ✅ Auto-fill with selected patient details
    patientIdCtrl.text = widget.selectedPatient.id;
  }

  void _snack(String msg, [bool isError = false]) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : const Color(0xFF1E3A8A),
        duration: Duration(milliseconds: isError ? 2500 : 1500),
      ),
    );
  }

  void _addToReview() {
    final name = medsCtrl.text.trim();
    final dose = doseCtrl.text.trim();
    final freq = freqCtrl.text.trim();

    if (name.isEmpty || dose.isEmpty || freq.isEmpty) {
      _snack('Enter medication, dosage, and frequency', true);
      return;
    }

    setState(() {
      _review.insert(
        0,
        _ReviewEntry(name: name, dosage: dose, frequency: freq),
      );
      medsCtrl.clear();
      doseCtrl.clear();
      freqCtrl.clear();
    });

    _snack('Added to Review');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _reviewKey.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.1,
        );
      }
    });
  }

  Future<void> _selectDate(
    TextEditingController controller,
    String title,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: title,
    );

    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
        _snack('File selected: ${result.files.single.name}');
      }
    } catch (e) {
      _snack('Error selecting file: $e', true);
    }
  }

  bool _validateForm() {
    if (patientIdCtrl.text.trim().isEmpty) {
      _snack('Please enter patient ID', true);
      return false;
    }
    if (ageCtrl.text.trim().isEmpty) {
      _snack('Please enter patient age', true);
      return false;
    }
    if (addressCtrl.text.trim().isEmpty) {
      _snack('Please enter patient address', true);
      return false;
    }
    if (_review.isEmpty) {
      _snack('Please add at least one medication to review', true);
      return false;
    }
    return true;
  }

  Future<void> _submitPrescription() async {
    if (!_validateForm()) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      List<String> medicines = _review.map((e) => e.name).toList();
      List<String> dosages = _review.map((e) => e.dosage).toList();

      var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
      request.fields.addAll({
        // ✅ Use selected patient's actual name
        'name': widget.selectedPatient.name,
        'patientId': patientIdCtrl.text.trim(),
        'age': ageCtrl.text.trim(),
        'gender': selectedGender,
        'address': addressCtrl.text.trim(),
        'medicines': jsonEncode(medicines),
        'dosages': jsonEncode(dosages),
        'consultationDate': consultationDateCtrl.text.trim(),
        'expiryDate': expiryDateCtrl.text.trim(),
      });

      if (selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'prescriptionFile',
            selectedFile!.path,
          ),
        );
      }

      request.headers['Authorization'] =
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2OGNkNTQ5MzdjOGY3NmMxNTc2NzM1MWQiLCJyb2xlIjoiZG9jdG9yIiwidXNlclR5cGUiOiJkb2N0b3IiLCJpYXQiOjE3NTg0MDM0MDcsImV4cCI6MTc1ODQ4OTgwN30.7zie8uUhayOr-sHYR_lE6f6XqN2Fl8OQ9ZMJ6XMzF0w';

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _showSuccessDialog(responseData);
        _clearForm();
      } else {
        final errorData = jsonDecode(response.body);
        _snack(
          'Error: ${errorData['error'] ?? 'Failed to submit prescription'}',
          true,
        );
      }
    } catch (e) {
      _snack('Network error: Please check your connection', true);
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog(Map<String, dynamic> responseData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prescription Issued Successfully!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prescription ID: ${responseData['prescriptionId']}'),
              const SizedBox(height: 8),
              Text('Transaction Hash: ${responseData['txHash']}'),
              const SizedBox(height: 8),
              if (responseData['pdfUrl'] != null)
                const Text('PDF: Available for download'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    patientIdCtrl.clear();
    ageCtrl.clear();
    addressCtrl.clear();
    issuesCtrl.clear();
    consultationDateCtrl.clear();
    expiryDateCtrl.clear();
    notesCtrl.clear();
    setState(() {
      selectedGender = 'Female';
      selectedFile = null;
      _review.clear();
    });
  }

  @override
  void dispose() {
    patientIdCtrl.dispose();
    ageCtrl.dispose();
    addressCtrl.dispose();
    issuesCtrl.dispose();
    medsCtrl.dispose();
    doseCtrl.dispose();
    freqCtrl.dispose();
    notesCtrl.dispose();
    consultationDateCtrl.dispose();
    expiryDateCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const pagePadding = EdgeInsets.symmetric(horizontal: 16);
    return Scaffold(
      appBar: const _TopBar(),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(text: 'Patient'),
                    const SizedBox(height: 8),
                    PatientHeader(selectedPatient: widget.selectedPatient),
                    const SizedBox(height: 16),

                    // Patient Information Section (Backend Required Fields)
                    const SectionHeader(text: 'Patient Details'),
                    const SizedBox(height: 8),
                    ShadowedField(
                      child: _SingleLineBox(
                        controller: patientIdCtrl,
                        hint: 'Patient ID *',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ShadowedField(
                            child: _SingleLineBox(
                              controller: ageCtrl,
                              hint: 'Age *',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShadowedField(
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1EEF8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedGender,
                                  isExpanded: true,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0F172A),
                                  ),
                                  items:
                                      ['Male', 'Female', 'Other'].map((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedGender = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ShadowedField(
                      child: _MultilineBox(
                        controller: addressCtrl,
                        hint: 'Patient Address *',
                        minLines: 2,
                      ),
                    ),

                    // Date Fields
                    const SizedBox(height: 16),
                    const SectionHeader(text: 'Consultation Details'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ShadowedField(
                            child: GestureDetector(
                              onTap:
                                  () => _selectDate(
                                    consultationDateCtrl,
                                    'Select Consultation Date',
                                  ),
                              child: AbsorbPointer(
                                child: _SingleLineBox(
                                  controller: consultationDateCtrl,
                                  hint: 'Consultation Date',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ShadowedField(
                            child: GestureDetector(
                              onTap:
                                  () => _selectDate(
                                    expiryDateCtrl,
                                    'Select Expiry Date',
                                  ),
                              child: AbsorbPointer(
                                child: _SingleLineBox(
                                  controller: expiryDateCtrl,
                                  hint: 'Prescription Expiry',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const SectionHeader(text: 'Health Issues'),
                    const SizedBox(height: 8),
                    ShadowedField(
                      child: _MultilineBox(
                        controller: issuesCtrl,
                        hint: 'Enter health issues',
                        minLines: 3,
                      ),
                    ),

                    const SizedBox(height: 16),
                    const SectionHeader(text: 'Critical Alerts'),
                    const SizedBox(height: 8),
                    const AlertRow(
                      iconBg: Color(0xFFF1EDF8),
                      iconColor: Color(0xFF6B5CA5),
                      text: 'Allergy: Penicillin',
                    ),
                    const SizedBox(height: 10),
                    const AlertRow(
                      iconBg: Color(0xFFF1EDF8),
                      iconColor: Color(0xFF6B5CA5),
                      text: 'Adverse Drug Reaction: Ibuprofen',
                    ),

                    const SizedBox(height: 16),
                    const SectionHeader(text: 'Medication'),
                    const SizedBox(height: 10),
                    ShadowedField(
                      child: _IconTextField(
                        controller: medsCtrl,
                        hint: 'Search for medications',
                        icon: Icons.search,
                        onSubmitted: (_) {},
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShadowedField(
                      child: _SingleLineBox(
                        controller: doseCtrl,
                        hint: 'Dosage (e.g., 500mg)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShadowedField(
                      child: _SingleLineBox(
                        controller: freqCtrl,
                        hint: 'Frequency (e.g., Twice daily)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ShadowedField(
                      child: _MultilineBox(
                        controller: notesCtrl,
                        hint: 'Special Instructions',
                        minLines: 3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _addToReview,
                        child: const Text(
                          'Add to Review',
                          style: TextStyle(
                            color: Color(0xFF1E40FF),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    KeyedSubtree(
                      key: _reviewKey,
                      child: const SectionHeader(text: 'Review Medications'),
                    ),
                    const SizedBox(height: 8),
                    if (_review.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No medications added yet',
                            style: TextStyle(
                              color: Color(0xFF8A94A6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ..._review.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ReviewItem(
                          title: e.name,
                          detail:
                              'Dosage: ${e.dosage}, Frequency: ${e.frequency}',
                          onRemove: () {
                            setState(() => _review.remove(e));
                            _snack('Removed ${e.name}');
                          },
                        ),
                      ),
                    ),

                    // File Upload Section
                    const SizedBox(height: 16),
                    const SectionHeader(text: 'Prescription File (Optional)'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _selectFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EEF8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            style: BorderStyle.solid,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.upload_file,
                              color: Color(0xFF8B8CA6),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedFile != null
                                    ? 'File: ${selectedFile!.path.split('/').last}'
                                    : 'Tap to upload prescription file',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      selectedFile != null
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFF8B8CA6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor:
                    isSubmitting
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1E40FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSubmitting ? null : _submitPrescription,
              child:
                  isSubmitting
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Submitting...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      )
                      : const Text(
                        'Submit Prescription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

/* --------- Models --------- */
class _ReviewEntry {
  final String name;
  final String dosage;
  final String frequency;
  const _ReviewEntry({
    required this.name,
    required this.dosage,
    required this.frequency,
  });
}

/* --------- Shared UI --------- */
class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  const _TopBar();
  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
        onPressed: () {},
      ),
      title: const Text(
        'Issue Prescription',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String text;
  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0F172A),
      ),
    );
  }
}

class PatientHeader extends StatelessWidget {
  final Patient selectedPatient;

  const PatientHeader({super.key, required this.selectedPatient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1E40FF),
            ),
            child: Center(
              child: Text(
                selectedPatient.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedPatient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID: ${selectedPatient.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7C8AA0),
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '✓ Selected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShadowedField extends StatelessWidget {
  final Widget child;
  const ShadowedField({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _IconTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final ValueChanged<String>? onSubmitted;

  const _IconTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEF8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B8CA6)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B8CA6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleLineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _SingleLineBox({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEF8),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B8CA6),
          ),
        ),
      ),
    );
  }
}

class _MultilineBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;

  const _MultilineBox({
    required this.controller,
    required this.hint,
    required this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EEF8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: 6,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF8B8CA6),
          ),
        ),
      ),
    );
  }
}

class AlertRow extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final String text;

  const AlertRow({
    super.key,
    required this.iconBg,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.error_outline, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String title;
  final String detail;
  final VoidCallback? onRemove;
  const ReviewItem({
    super.key,
    required this.title,
    required this.detail,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A94A6),
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: Color(0xFF8A94A6)),
              tooltip: 'Remove',
            ),
        ],
      ),
    );
  }
}
