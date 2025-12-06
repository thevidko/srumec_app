import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Důležitý import
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:srumec_app/events/screens/create_event_screen.dart';
import 'package:srumec_app/events/models/event.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<Event> _myEvents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Zavoláme načtení až po vykreslení prvního framu,
    // abychom mohli bezpečně použít context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ZMĚNA: Používáme context.read<EventsRepository>(),
      // který už má v sobě správně nastavený Dio s Tokenem díky main.dart
      final events = await context.read<EventsRepository>().getMyEvents();

      if (mounted) {
        setState(() {
          _myEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Nepodařilo se načíst události.";
          _isLoading = false;
        });
        print("Chyba při načítání: $e");
      }
    }
  }

  Future<void> _handleCreateEvent() async {
    // 1. Otevřeme obrazovku pro vytvoření a čekáme na návrat (await)
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateEventScreen()));

    // 2. Po návratu (kdy uživatel zavřel obrazovku vytvoření) obnovíme data
    // Předpokládáme, že pokud se vrátil, mohl něco vytvořit.
    // Pro lepší optimalizaci by CreateEventScreen mohl vracet true/false.
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. OBLAST TLAČÍTKA (Nahoře - vždy viditelné)
          _buildTopActionSection(),

          // 2. SEZNAM (Zbytek místa)
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // Nová sekce pro horní tlačítko
  Widget _buildTopActionSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        // Volitelné: jemný stín pod tlačítkem, aby se oddělilo od seznamu při scrollování
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50, // Dostatečně velké pro pohodlné kliknutí
        child: FilledButton.icon(
          onPressed: _handleCreateEvent,
          icon: const Icon(Icons.add),
          label: const Text('Vytvořit novou událost'),
          style: FilledButton.styleFrom(
            elevation: 0, // Plochý vzhled, modernější
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            TextButton(
              onPressed: _loadEvents,
              child: const Text("Zkusit znovu"),
            ),
          ],
        ),
      );
    }

    if (_myEvents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Zatím jsi nevytvořil žádné akce.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _myEvents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = _myEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HLAVIČKA: Titulek + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(event.status),
              ],
            ),

            const SizedBox(height: 8),

            // POPIS
            Text(
              event.description,
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Divider(height: 24),

            // SPODNÍ ŘÁDEK: Datum a čas
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(event.happenTime),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Pomocná metoda pro barevný štítek statusu
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    // Logika barev podle statusu
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange[900]!;
        text = 'Čeká na schválení';
        break;
      case 'approved':
      case 'active':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green[800]!;
        text = 'Schváleno';
        break;
      case 'rejected':
      case 'cancelled':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red[800]!;
        text = 'Zamítnuto';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[800]!;
        text = status; // Fallback
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Jednoduché formátování data (nebo použijte balíček intl)
  String _formatDate(DateTime date) {
    // Převedeme na lokální čas, protože API vrací 'Z' (UTC)
    final local = date.toLocal();
    // Formát: 12.12.2025 12:01
    return "${local.day}.${local.month}.${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }
}
