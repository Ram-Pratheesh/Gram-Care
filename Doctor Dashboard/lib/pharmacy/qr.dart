import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Dummy storage for dispensed prescriptions
class DispenseStorage {
  static final Set<String> _dispensedPrescriptions = {};

  static bool isDispensed(String prescriptionId) {
    return _dispensedPrescriptions.contains(prescriptionId);
  }

  static void markAsDispensed(String prescriptionId) {
    _dispensedPrescriptions.add(prescriptionId);
  }

  static void reset() {
    _dispensedPrescriptions.clear();
  }
}

// API Service Class
class ApiService {
  static const String baseUrl =
      'http://172.16.58.254:4000/api'; // Change to your backend URL

  // Verify QR code prescription
  static Future<Map<String, dynamic>> verifyQRCode(
    String prescriptionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prescription/verify-qr/$prescriptionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Override isDispensed with local storage
        data['isDispensed'] = DispenseStorage.isDispensed(prescriptionId);
        data['canDispense'] =
            data['valid'] == true &&
            !DispenseStorage.isDispensed(prescriptionId);

        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'data': json.decode(response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('API Error: $e');
      // Return dummy data for testing when API is not available
      return _getDummyPrescriptionData(prescriptionId);
    }
  }

  // Dummy data for testing
  static Map<String, dynamic> _getDummyPrescriptionData(String prescriptionId) {
    final isDispensed = DispenseStorage.isDispensed(prescriptionId);
    return {
      'success': true,
      'data': {
        'success': true,
        'valid': true,
        'prescription': {
          'id': int.tryParse(prescriptionId) ?? 123,
          'doctorName': 'Dr. Sarah Johnson',
          'date': '2025-01-21',
          'diagnosis': 'Common Cold',
          'medicines': ['Paracetamol 500mg', 'Cetirizine 10mg', 'Vitamin C'],
          'dosages': ['3 times daily', 'Once daily at bedtime', 'Once daily'],
        },
        'patient': {
          'name': 'John Doe',
          'patientId': 'P12345',
          'age': 35,
          'gender': 'Male',
          'address': '456 Oak Street, Chennai',
        },
        'isDispensed': isDispensed,
        'canDispense': !isDispensed,
      },
      'statusCode': 200,
    };
  }

  // Download prescription PDF
  static Future<String> getPrescriptionDownloadUrl(
    String prescriptionId,
  ) async {
    return '$baseUrl/prescription/$prescriptionId/download';
  }

  // Get patient prescription with QR code
  static Future<Map<String, dynamic>> getPatientPrescription(
    String patientId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patient/$patientId/prescription'),
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': response.statusCode == 200,
        'data': json.decode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
        'statusCode': 500,
      };
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  void _login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter both email and password', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    // Simulate login delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    // Dummy login - accept any email/password
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const QRHomePage()),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade400, Colors.blue.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  const Text(
                    'Pharmacy Portal',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'QR Prescription Scanner',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 48),

                  // Login Form
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter your password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed:
                                    () => setState(
                                      () => obscurePassword = !obscurePassword,
                                    ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: isLoading ? null : _login,
                            child:
                                isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text('Login'),
                          ),
                          const SizedBox(height: 16),

                          // Demo credentials info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Demo Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enter any email and password to login',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class QRHomePage extends StatelessWidget {
  const QRHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription QR Scanner"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else if (value == 'reset') {
                DispenseStorage.reset();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dispensed prescriptions reset'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Reset Dispensed'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  size: 120,
                  color: Colors.blue,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Pharmacy QR Scanner",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Scan prescription QR codes to verify and dispense medications",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QRScannerPage()),
                    );
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 28),
                  label: const Text("Start Scanning"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = true;
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!isScanning || isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
          isProcessing = true;
        });

        await _processScanResult(barcode.rawValue!);
        break;
      }
    }
  }

  Future<void> _processScanResult(String qrData) async {
    try {
      // Parse QR data
      Map<String, dynamic> qrJson;
      try {
        qrJson = json.decode(qrData);
      } catch (e) {
        // If not JSON, try to extract prescription ID from URL or plain text
        String prescriptionId = _extractPrescriptionId(qrData);
        if (prescriptionId.isEmpty) {
          _showErrorDialog('Invalid QR Code', 'QR code format not recognized');
          return;
        }
        qrJson = {'prescriptionId': prescriptionId};
      }

      String prescriptionId = qrJson['prescriptionId']?.toString() ?? '';
      if (prescriptionId.isEmpty) {
        _showErrorDialog(
          'Invalid QR Code',
          'No prescription ID found in QR code',
        );
        return;
      }

      // Show loading dialog
      _showLoadingDialog();

      // Verify prescription
      final result = await ApiService.verifyQRCode(prescriptionId);
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success']) {
        _showPrescriptionDetails(result['data']);
      } else {
        String errorMessage =
            result['data']?['error'] ?? 'Unknown error occurred';
        _showErrorDialog('Verification Failed', errorMessage);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog if open
      _showErrorDialog('Processing Error', 'Failed to process QR code: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  String _extractPrescriptionId(String qrData) {
    // Try to extract prescription ID from various formats
    if (qrData.contains('prescriptionId')) {
      RegExp regExp = RegExp(r'prescriptionId["\s]*[:=]["\s]*(\d+)');
      Match? match = regExp.firstMatch(qrData);
      if (match != null) return match.group(1)!;
    }

    // Check if it's just a number
    if (RegExp(r'^\d+$').hasMatch(qrData)) {
      return qrData;
    }

    // Extract from URL
    if (qrData.contains('/verify-qr/')) {
      RegExp regExp = RegExp(r'/verify-qr/(\d+)');
      Match? match = regExp.firstMatch(qrData);
      if (match != null) return match.group(1)!;
    }

    return '';
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Verifying prescription..."),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetScanner();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  void _showPrescriptionDetails(Map<String, dynamic> data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => PrescriptionDetailsPage(
              prescriptionData: data,
              onClose: _resetScanner,
            ),
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Prescription QR"),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QRScannerOverlayShape(
                borderColor: Colors.white,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 8,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          // Bottom instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Position the QR code within the frame",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isProcessing ? "Processing..." : "Ready to scan",
                    style: TextStyle(
                      color: isProcessing ? Colors.orange : Colors.green,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Try scanning: 123, 456, or 789",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QRScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path innerPath =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: rect.center,
              width: cutOutSize,
              height: cutOutSize,
            ),
            Radius.circular(borderRadius),
          ),
        );
    return Path.combine(PathOperation.difference, path, innerPath);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final center = rect.center;
    final cutOutRect = Rect.fromCenter(
      center: center,
      width: cutOutSize,
      height: cutOutSize,
    );

    final paint =
        Paint()
          ..color = borderColor
          ..strokeWidth = borderWidth
          ..style = PaintingStyle.stroke;

    // Draw corner brackets
    final path = Path();

    // Top-left corner
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top + borderRadius);
    path.quadraticBezierTo(
      cutOutRect.left,
      cutOutRect.top,
      cutOutRect.left + borderRadius,
      cutOutRect.top,
    );
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    // Top-right corner
    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right - borderRadius, cutOutRect.top);
    path.quadraticBezierTo(
      cutOutRect.right,
      cutOutRect.top,
      cutOutRect.right,
      cutOutRect.top + borderRadius,
    );
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    // Bottom-right corner
    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius);
    path.quadraticBezierTo(
      cutOutRect.right,
      cutOutRect.bottom,
      cutOutRect.right - borderRadius,
      cutOutRect.bottom,
    );
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    // Bottom-left corner
    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom);
    path.quadraticBezierTo(
      cutOutRect.left,
      cutOutRect.bottom,
      cutOutRect.left,
      cutOutRect.bottom - borderRadius,
    );
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return QRScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
      borderLength: borderLength,
      cutOutSize: cutOutSize,
    );
  }
}

class PrescriptionDetailsPage extends StatelessWidget {
  final Map<String, dynamic> prescriptionData;
  final VoidCallback onClose;

  const PrescriptionDetailsPage({
    super.key,
    required this.prescriptionData,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final prescription = prescriptionData['prescription'] ?? {};
    final patient = prescriptionData['patient'];
    final isDispensed = prescriptionData['isDispensed'] ?? false;
    final canDispense = prescriptionData['canDispense'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prescription Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            onClose();
          },
        ),
        actions: [
          if (prescription['id'] != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed:
                  () => _downloadPrescription(
                    context,
                    prescription['id'].toString(),
                  ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color:
                  isDispensed
                      ? Colors.grey.shade100
                      : canDispense
                      ? Colors.green.shade50
                      : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isDispensed
                          ? Icons.check_circle
                          : canDispense
                          ? Icons.medication
                          : Icons.error,
                      color:
                          isDispensed
                              ? Colors.grey
                              : canDispense
                              ? Colors.green
                              : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDispensed
                                ? "Already Dispensed"
                                : canDispense
                                ? "Ready to Dispense"
                                : "Cannot Dispense",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDispensed
                                      ? Colors.grey.shade700
                                      : canDispense
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                            ),
                          ),
                          Text(
                            isDispensed
                                ? "This prescription has already been dispensed"
                                : canDispense
                                ? "Prescription is valid and ready for dispensing"
                                : "Prescription is invalid or expired",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Patient Information
            if (patient != null) ...[
              _buildSectionCard(
                title: "Patient Information",
                icon: Icons.person,
                children: [
                  _buildInfoRow("Name", patient['name']?.toString() ?? 'N/A'),
                  _buildInfoRow(
                    "Patient ID",
                    patient['patientId']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow("Age", patient['age']?.toString() ?? 'N/A'),
                  _buildInfoRow(
                    "Gender",
                    patient['gender']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow(
                    "Address",
                    patient['address']?.toString() ?? 'N/A',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Prescription Information
            _buildSectionCard(
              title: "Prescription Details",
              icon: Icons.receipt_long,
              children: [
                _buildInfoRow(
                  "Prescription ID",
                  prescription['id']?.toString() ?? 'N/A',
                ),
                if (prescription['doctorName'] != null)
                  _buildInfoRow(
                    "Doctor",
                    prescription['doctorName'].toString(),
                  ),
                if (prescription['date'] != null)
                  _buildInfoRow("Date", prescription['date'].toString()),
                if (prescription['diagnosis'] != null)
                  _buildInfoRow(
                    "Diagnosis",
                    prescription['diagnosis'].toString(),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Medicines
            if (prescription['medicines'] != null &&
                prescription['medicines'].isNotEmpty) ...[
              _buildSectionCard(
                title: "Prescribed Medicines",
                icon: Icons.medication,
                children: [
                  ...List.generate(
                    prescription['medicines'].length,
                    (index) => _buildMedicineItem(
                      prescription['medicines'][index].toString(),
                      prescription['dosages'] != null &&
                              prescription['dosages'].length > index
                          ? prescription['dosages'][index].toString()
                          : 'N/A',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Action Button
            if (canDispense && !isDispensed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _confirmDispense(context),
                  icon: const Icon(Icons.medication),
                  label: const Text("Mark as Dispensed"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(String medicine, String dosage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.medical_services, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Dosage: $dosage",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _downloadPrescription(
    BuildContext context,
    String prescriptionId,
  ) async {
    try {
      // Show info dialog since API might not be available
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Download Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PDF Download URL:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'http://172.16.58.254:4000/api/prescription/$prescriptionId/download',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: This would normally download the prescription PDF when your backend server is running.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final url = await ApiService.getPrescriptionDownloadUrl(
                    prescriptionId,
                  );
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not open download link - server may be offline',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Try Download'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  void _confirmDispense(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Dispensing'),
          content: const Text(
            'Are you sure you want to mark this prescription as dispensed? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.of(context).pop();

                // Mark as dispensed in local storage
                final prescriptionId =
                    prescriptionData['prescription']?['id']?.toString();
                if (prescriptionId != null) {
                  DispenseStorage.markAsDispensed(prescriptionId);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Prescription marked as dispensed'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
                onClose();
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
