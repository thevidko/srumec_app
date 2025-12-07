import 'package:flutter/material.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';
import 'package:srumec_app/chat/data/repositories/chat_repository.dart';
import 'package:srumec_app/chat/screens/chat_detail_screen.dart';
import 'package:srumec_app/comments/widgets/comments_section.dart';
import 'package:srumec_app/core/utils/app_utils.dart';
import 'package:srumec_app/events/models/event.dart';
import 'package:srumec_app/users/widgets/user_name_label.dart';
import 'package:provider/provider.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
    required this.onShowOnMap,
  });

  final Event event;
  final void Function(Event) onShowOnMap;

  static const Color vibrantPurple = Color(0xFF6200EA);
  static const Color neonAccent = Color(0xFFD500F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        height: 1.6,
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
                    CommentsSection(eventId: event.id),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // 5. SPODNÍ TLAČÍTKO
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
                AppUtils.formatDateTime(event.happenTime),
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
            fontWeight: FontWeight.w900,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        // Místo
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
    final myUserId = context.read<AuthProvider>().userId;
    final isMyEvent = myUserId == event.organizerRef;
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
                "JD", // TODO Iniciály
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Jméno a role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserNameLabel(
                  userId: event.organizerRef,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
          if (!isMyEvent)
            IconButton(
              onPressed: () => _handleMessagePress(context),
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

  Future<void> _handleMessagePress(BuildContext context) async {
    final myUserId = context.read<AuthProvider>().userId;
    try {
      if (myUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chyba: Nejste přihlášen (chybí ID).')),
        );
        return;
      }
      final chatRepo = context.read<ChatRepository>();

      // initiateChat vrací objekt ChatRoom
      final chatRoom = await chatRepo.initiateChat(
        myUserId,
        event.organizerRef,
      );

      if (context.mounted) {
        // 2. Přesměrujeme na detail chatu
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              roomId: chatRoom.id,
              otherUserId: event.organizerRef,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při otevírání chatu: $e')),
        );
      }
    }
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
}
