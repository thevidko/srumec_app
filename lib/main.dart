import 'package:flutter/material.dart';
import 'package:srumec_app/screens/main_screen.dart';
//import 'package:srumec_app/screens/login_screen.dart'; TODO: až se zprovozní login naplno


void main() {
  runApp(const SrumecApp());
}

class SrumecApp extends StatelessWidget {
  const SrumecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Šrumec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Místo původního obsahu zde použijeme náš MainScreen
      home: const MainScreen(),
      debugShowCheckedModeBanner: false, // Vypne otravný banner "Debug"
    );
  }
}
