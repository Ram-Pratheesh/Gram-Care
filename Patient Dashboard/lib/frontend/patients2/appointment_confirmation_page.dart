import 'package:flutter/material.dart';

void main() {
  runApp(const AppointmentConfirmationPage());
}

class AppointmentConfirmationPage extends StatelessWidget {
  const AppointmentConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    String date = args?['date'] ?? "Unknown";
    String time = args?['time'] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Book an Appointment",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.thumb_up_alt,
                size: 100,
                color: Colors.blue, // ✅ Blue instead of deepPurple
              ),
              const SizedBox(height: 20),
              const Text(
                "Thank You!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your Appointment Created.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "You booked an appointment\nwith Dr. John Doe\non $date, at $time",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue, // ✅ Same theme color
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
