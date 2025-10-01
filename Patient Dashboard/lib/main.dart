import 'package:flutter/material.dart';

import 'package:gramcare/frontend/testing/videocall.dart'; // make sure CallPage is here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GramCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // 🚀 Start directly with CallPage
      home: const CallPage(roomId: "test-room"),
    );
  }
}
