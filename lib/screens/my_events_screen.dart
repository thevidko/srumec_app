import 'package:flutter/material.dart';

class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Zde budou moje vytvořené akce',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
