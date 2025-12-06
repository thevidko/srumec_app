import 'package:flutter/material.dart';
import 'package:srumec_app/comments/widgets/comments_section.dart';
import 'package:srumec_app/events/models/event.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onShowOnMap,
  });

  final Event event;
  final void Function(Event) onShowOnMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Titulek + podtitulek
          Text(
            event.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            event.description,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // (volitelné) místo pro další data – čas, místo, popis, atd.
          const SizedBox(height: 12),

          CommentsSection(eventId: event.id),

          const SizedBox(height: 24),

          // Primární akce – ukázat na mapě
          FilledButton.icon(
            icon: const Icon(Icons.map_outlined),
            label: const Text('Ukázat na mapě'),
            onPressed: () {
              // Vrátíme se na předchozí (EventsScreen/MainScreen) a pak přepneme na mapu
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onShowOnMap(event);
              });
            },
          ),
        ],
      ),
    );
  }
}
