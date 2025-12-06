import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srumec_app/chat/screens/chat_list_screen.dart';
import 'package:srumec_app/controller/map_view_controller.dart';
import 'package:srumec_app/core/providers/locator/location_provider.dart';
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:srumec_app/events/screens/events_screen.dart';
import 'package:srumec_app/events/screens/my_events_screen.dart';
import 'package:srumec_app/events/services/events_service.dart';
import 'package:srumec_app/events/models/event.dart';
import 'package:srumec_app/screens/map/map_screen.dart';
import 'package:srumec_app/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1; // -1 = mapa
  final MapViewController _mapController = MapViewController();

  // Poznámka: EventsService se zdá nepoužitý, pokud používáš repository provider,
  // ale nechávám ho, aby se nerozbil build.
  final EventsService _eventsService = EventsService();

  List<Event> _events = [];
  bool _isLoadingEvents = false;
  String? _eventsError;

  // BARVY
  static const Color vibrantPurple = Color(0xFF6200EA);
  // Opravená neonová barva (aby byla odlišná od vibrantPurple)
  static const Color neonAccent = Color(0xFF6200EA);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndEvents();
    });
  }

  // FETCH LOKACE A EVENTŮ
  Future<void> _initLocationAndEvents() async {
    final locProvider = Provider.of<LocationProvider>(context, listen: false);
    await locProvider.determinePosition();

    if (locProvider.currentPosition != null) {
      _loadEvents(
        lat: locProvider.currentPosition!.latitude,
        lng: locProvider.currentPosition!.longitude,
      );
    } else {
      _loadEvents(lat: 50.087, lng: 14.42);
    }
  }

  Future<void> _loadEvents({required double lat, required double lng}) async {
    setState(() {
      _isLoadingEvents = true;
      _eventsError = null;
    });

    try {
      final events = await context.read<EventsRepository>().getNearbyEvents(
        lat: lat,
        lng: lng,
        radius: 5000,
      );
      debugPrint('Staženo akcí: ${events.length}');
      if (!mounted) return;
      setState(() {
        _events = events;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _eventsError = 'Nepodařilo se načíst akce.';
      });
    } finally {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  void _handleShowOnMap(Event e) {
    setState(() => _selectedIndex = -1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.showEvent(e);
    });
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();

    // 1. LOADING SCREEN
    if (locProvider.isLoading && locProvider.currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: vibrantPurple),
              SizedBox(height: 20),
              Text(
                "Zjišťuji vaši polohu...",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 2. ERROR SCREEN
    if (locProvider.errorMessage != null &&
        locProvider.currentPosition == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 60, color: Colors.red),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  locProvider.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: () => locProvider.determinePosition(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: vibrantPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Zkusit znovu"),
              ),
            ],
          ),
        ),
      );
    }

    final isMap = _selectedIndex == -1;

    return Scaffold(
      // Pokud jsme na mapě, AppBar skryjeme (nahradíme ho plovoucím v body).
      // Pokud jsme jinde, zobrazíme klasický fialový AppBar.
      appBar: isMap
          ? null
          : AppBar(
              backgroundColor: vibrantPurple,
              foregroundColor: Colors.white,
              centerTitle: true,
              title: Text(
                ['Akce v okolí', 'Moje akce', 'Chat', 'Profil'][_selectedIndex],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                if (_selectedIndex == 0)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Načíst akce',
                    onPressed: _isLoadingEvents ? null : _initLocationAndEvents,
                  ),
              ],
            ),

      // TĚLO APLIKACE
      body: isMap
          ? _buildMapWithFloatingHeader(
              locProvider,
            ) // Speciální layout pro mapu
          : _buildSectionBody(), // Klasický layout pro ostatní taby

      extendBody: true,

      // FLOATING ACTION BUTTON (Středové tlačítko)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(-1),
        backgroundColor: neonAccent,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.map_outlined, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // SPODNÍ NAVIGACE
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        shadowColor: Colors.black26,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavIcon(icon: Icons.list_alt, index: 0, label: 'Akce'),
              _buildNavIcon(icon: Icons.person, index: 1, label: 'Moje akce'),
              const SizedBox(width: 48),
              _buildNavIcon(
                icon: Icons.chat_bubble_outline,
                index: 2,
                label: 'Chat',
              ),
              _buildNavIcon(
                icon: Icons.account_circle,
                index: 3,
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NOVÝ WIDGET: Mapa s plovoucí hlavičkou ---
  Widget _buildMapWithFloatingHeader(LocationProvider locProvider) {
    return Stack(
      children: [
        // 1. Vrstva: MAPA (přes celou obrazovku, i pod status barem)
        MapScreen(
          controller: _mapController,
          events: _events,
          userLocation: locProvider.currentPosition,
          isLoading: locProvider.isLoading,
        ),

        // 2. Vrstva: PLOVOUCÍ HLAVIČKA (Search Bar Style)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            // Aby to nezasahovalo do hodin/baterie
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 56, // Standardní výška
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30), // Hodně zaoblené
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    // TODO: Otevřít vyhledávání nebo filtr
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vyhledávání bude brzy...")),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Ikonka lupy (fialová)
                        const Icon(Icons.search, color: vibrantPurple),
                        const SizedBox(width: 12),

                        // Textový placeholder
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Co se děje v okolí?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                "Klikni pro vyhledávání...",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Oddělovač
                        Container(
                          width: 1,
                          height: 24,
                          color: Colors.grey[300],
                        ),

                        // Tlačítko Filtry
                        IconButton(
                          icon: Icon(Icons.tune, color: Colors.grey[700]),
                          tooltip: "Filtry",
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Filtry budou brzy..."),
                              ),
                            );
                          },
                        ),

                        // Tlačítko Refresh (pokud je potřeba)
                        if (_isLoadingEvents)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: vibrantPurple,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: vibrantPurple,
                            ),
                            tooltip: "Aktualizovat",
                            onPressed: _initLocationAndEvents,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildEventsTab();
      case 1:
        return const MyEventsScreen();
      case 2:
        return const ChatListScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEventsTab() {
    if (_isLoadingEvents && _events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: vibrantPurple),
      );
    }
    if (_eventsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_eventsError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: vibrantPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: _initLocationAndEvents,
              child: const Text('Zkusit znovu'),
            ),
          ],
        ),
      );
    }
    if (_events.isEmpty) {
      return const Center(child: Text('Žádné akce k zobrazení.'));
    }
    return RefreshIndicator(
      color: vibrantPurple,
      onRefresh: _initLocationAndEvents,
      child: EventsScreen(events: _events, onShowOnMap: _handleShowOnMap),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? vibrantPurple : Colors.grey[400],
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}
