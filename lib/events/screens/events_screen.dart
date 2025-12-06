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

  // Naše barvy (aby nemusely být importovány odevšad)
  static const Color vibrantPurple = Color(0xFF6200EA);
  static const Color cardBackground = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Výpočet paddingu pro spodní část, aby seznam nezalezl pod FAB a BottomBar
    final bottomSafe = MediaQuery.of(context).padding.bottom;
    const bottomBar = kBottomNavigationBarHeight;
    const extraForFab = 80.0; // Větší prostor kvůli FABu

    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F5F7,
      ), // Jemně šedé pozadí pod seznamem
      body: ListView.separated(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: bottomSafe + bottomBar + extraForFab,
        ),
        itemCount: events.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12), // Mezera místo čáry
        itemBuilder: (context, i) {
          final e = events[i];
          return _buildEventCard(context, e);
        },
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
          // ⬇️ KLIKNUTÍ NA CELOU KARTU -> DETAIL
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
                // Oddělené vizuálně čarou
                Container(height: 40, width: 1, color: Colors.grey[200]),
                IconButton(
                  tooltip: 'Ukázat na mapě',
                  icon: const Icon(Icons.map_outlined),
                  color: Colors.grey[400], // Defaultně šedá
                  selectedIcon: const Icon(Icons.map),
                  // Při stisknutí nebo hoveru by to mohlo zfialovět,
                  // ale Material 3 IconButton to řeší stylem.
                  // Zde uděláme custom styl, pokud chceme:
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

  // Stylový boxík pro datum (Den / Měsíc)
  Widget _buildDateBox(DateTime date) {
    return Container(
      width: 55,
      height: 60,
      decoration: BoxDecoration(
        color: vibrantPurple.withOpacity(0.08), // Velmi světlé fialové pozadí
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
              fontWeight: FontWeight.w800, // Extra tučné
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

  // Pomocné metody pro formátování (pokud nemáte balíček intl)
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
