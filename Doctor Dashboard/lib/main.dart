import 'package:flutter/material.dart';
import 'package:gramcare/docreg.dart';

void main() {
  runApp(const GramCareApp());
}

class GramCareApp extends StatelessWidget {
  const GramCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F9FB),
      ),
      home: const DoctorRegistrationPage(),
    );
  }
}
