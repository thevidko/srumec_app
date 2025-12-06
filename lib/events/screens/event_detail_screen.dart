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

  // Naše barvy
  static const Color vibrantPurple = Color(0xFF6200EA);
  static const Color neonAccent = Color(0xFFD500F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar uděláme průhlednější, aby vynikl obsah, nebo sytý pro konzistenci
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          "Detail události",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implementovat sdílení
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SCROLLOVATELNÝ OBSAH
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HLAVIČKA: Datum a Titulek
                    _buildHeader(),

                    const SizedBox(height: 24),

                    // 2. SEKCE UŽIVATELE (ORGANIZÁTOR)
                    _buildOrganizerSection(context),

                    const SizedBox(height: 24),

                    // 3. POPIS
                    const Text(
                      "O akci",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.6, // Lepší řádkování pro čitelnost
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // 4. KOMENTÁŘE
                    const Text(
                      "Diskuze",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Zde předpokládáme, že CommentsSection není roztažený přes celou obrazovku
                    // Pokud obsahuje ListView, měl by mít shrinkWrap: true a physics: NeverScrollableScrollPhysics
                    CommentsSection(eventId: event.id),

                    // Prostor dole, aby obsah nebyl schovaný za tlačítkem
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 5. SPODNÍ TLAČÍTKO (Sticky Bottom Bar)
            _buildBottomAction(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Datum a Čas Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: vibrantPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today, size: 16, color: vibrantPurple),
              const SizedBox(width: 8),
              Text(
                _formatDateTime(event.happenTime),
                style: const TextStyle(
                  color: vibrantPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Hlavní titulek
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900, // Extra tučné
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        // Místo (jen text, kliknutí na mapu je dole)
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              "GPS: ${event.lat.toStringAsFixed(4)}, ${event.lng.toStringAsFixed(4)}",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar Placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
              ],
            ),
            child: const Center(
              child: Text(
                "TN", // Iniciály (Tomáš Novotný)
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Jméno a role
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tomáš Novotný", // Placeholder jméno
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Organizátor",
                  style: TextStyle(
                    color: vibrantPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Tlačítko Zpráva
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Otevírám chat s uživatelem...')),
              );
              // TODO: Navigace do chatu s tímto uživatelem
            },
            style: IconButton.styleFrom(
              backgroundColor: vibrantPurple.withOpacity(0.1),
              foregroundColor: vibrantPurple,
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            tooltip: "Napsat zprávu",
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              icon: const Icon(Icons.map),
              label: const Text(
                'UKÁZAT NA MAPĚ',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              onPressed: () {
                Navigator.pop(context); // Návrat na seznam/mapu
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onShowOnMap(event);
                });
              },
              style: FilledButton.styleFrom(
                backgroundColor: vibrantPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final local = date.toLocal();
    // Příklad: Pátek, 12. prosince • 14:00
    // Pro jednoduchost bez intl balíčku:
    return "${local.day}.${local.month}.${local.year} • ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}
