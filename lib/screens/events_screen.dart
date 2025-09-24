import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Zde bude seznam akcí v okolí',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
