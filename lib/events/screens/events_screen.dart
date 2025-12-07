import 'package:flutter/material.dart';
import 'package:srumec_app/events/models/event.dart';
import 'package:srumec_app/events/screens/event_detail_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({
    super.key,
    required this.events,
    required this.onShowOnMap,
  });

  final List<Event> events;
  final void Function(Event) onShowOnMap;

  static const Color vibrantPurple = Color(0xFF6200EA);
  static const Color cardBackground = Colors.white;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const bottomBar = kBottomNavigationBarHeight;
    const extraForFab = 80.0; // Větší prostor kvůli FABu

    //Seřazení podle datumu
    final sortedEvents = List<Event>.from(events);
    sortedEvents.sort((a, b) => a.happenTime.compareTo(b.happenTime));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(
        children: [
          // 2. FILTRAČNÍ LIŠTA
          _buildFilterBar(context, sortedEvents.length),

          // 3. SEZNAM
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(
                top: 8, // Menší padding nahoře, protože tam je lišta
                left: 16,
                right: 16,
                bottom: bottomSafe + bottomBar + extraForFab,
              ),
              itemCount: sortedEvents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = sortedEvents[i];
                return _buildEventCard(context, e);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: const Color(0xFFF5F5F7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informace o počtu
          Text(
            "$count akcí v okolí",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          // Tlačítko Filtru
          SizedBox(
            height: 36,
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Filtrace - Coming Soon")),
                );
                // TODO: Otevřít BottomSheet s filtry (datum, kategorie...)
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              icon: const Icon(Icons.tune_rounded, size: 16), // Ikonka filtrů
              label: const Text(
                "Filtrovat",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, Event e) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(
                  event: e,
                  onShowOnMap: (evt) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      onShowOnMap(evt);
                    });
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // 1. LEVÁ ČÁST - DATUM (Box)
                _buildDateBox(e.happenTime),

                const SizedBox(width: 16),

                // 2. STŘED - INFO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Čas konání
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: vibrantPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(e.happenTime),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: vibrantPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Titulek
                      Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      // Popis (zkrácený)
                      const SizedBox(height: 4),
                      Text(
                        e.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // 3. PRAVÁ ČÁST - TLAČÍTKO MAPY
                Container(height: 40, width: 1, color: Colors.grey[200]),
                IconButton(
                  tooltip: 'Ukázat na mapě',
                  icon: const Icon(Icons.map_outlined),
                  color: Colors.grey[400],
                  selectedIcon: const Icon(Icons.map),
                  style: IconButton.styleFrom(
                    foregroundColor: vibrantPurple,
                    hoverColor: vibrantPurple.withOpacity(0.05),
                  ),
                  onPressed: () => onShowOnMap(e),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stylový boxík pro datum
  Widget _buildDateBox(DateTime date) {
    return Container(
      width: 55,
      height: 60,
      decoration: BoxDecoration(
        color: vibrantPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: vibrantPurple.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: vibrantPurple,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getMonthName(date.month),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: vibrantPurple.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  String _getMonthName(int month) {
    const months = [
      "LED",
      "ÚNO",
      "BŘE",
      "DUB",
      "KVĚ",
      "ČVN",
      "ČVC",
      "SRP",
      "ZÁŘ",
      "ŘÍJ",
      "LIS",
      "PRO",
    ];
    return months[month - 1];
  }
}
