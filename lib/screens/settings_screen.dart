import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Zde bude nastavení aplikace',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
