import 'package:flutter/material.dart';
import '../../../events/models/event.dart';

class EventListPanel extends StatelessWidget {
  final List<Event> events;
  final void Function(Event) onSelect;

  const EventListPanel({
    super.key,
    required this.events,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Akce v okolí",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, i) {
              final e = events[i];
              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(e.title),
                subtitle: Text(e.description),
                onTap: () => onSelect(e),
              );
            },
          ),
        ),
      ],
    );
  }
}
