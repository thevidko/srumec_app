import 'package:flutter/material.dart';
import 'package:srumec_app/models/event.dart';
import 'package:srumec_app/events/screens/event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({
    super.key,
    required this.events,
    required this.onShowOnMap,
  });

  final List<Event> events;
  final void Function(Event) onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const bottomBar = kBottomNavigationBarHeight;
    const extraForFab = 24.0;

    return SafeArea(
      top: false,
      bottom: true,
      child: ListView.separated(
        padding: EdgeInsets.only(
          top: 8,
          bottom: 8 + bottomSafe + bottomBar + extraForFab,
        ),
        itemCount: events.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          final e = events[i];

          return ListTile(
            leading: const Icon(Icons.event_note),
            title: Text(e.title),
            subtitle: Text(e.description),
            // ⬇️ TAP NA ŘÁDEK => DETAIL
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailScreen(
                    event: e,
                    onShowOnMap: (evt) {
                      // po návratu na MainScreen přepni na mapu a ukaž popup
                      //Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        onShowOnMap(evt);
                      });
                    },
                  ),
                ),
              );
            },
            // ⬇️ JEN IKONA MAPY => PŘEPNOUT NA MAPU + POPUP
            trailing: IconButton(
              tooltip: 'Ukázat na mapě',
              icon: const Icon(Icons.map_outlined),
              onPressed: () => onShowOnMap(e),
            ),
          );
        },
      ),
    );
  }
}
