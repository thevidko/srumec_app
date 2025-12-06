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
import 'package:srumec_app/screens/chat_screen.dart';
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
  final EventsService _eventsService = EventsService();
  List<Event> _events = [];
  bool _isLoadingEvents = false;
  String? _eventsError;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initLocationAndEvents();
    });
  }

  // FETCH LOKACE
  Future<void> _initLocationAndEvents() async {
    final locProvider = Provider.of<LocationProvider>(context, listen: false);

    // 1. Získat polohu
    await locProvider.determinePosition();

    // 2. Pokud máme polohu, načteme akce podle ní. Pokud ne, použijeme default (Praha)
    if (locProvider.currentPosition != null) {
      _loadEvents(
        lat: locProvider.currentPosition!.latitude,
        lng: locProvider.currentPosition!.longitude,
      );
    } else {
      // Fallback pokud uživatel zamítl polohu
      _loadEvents(lat: 50.087, lng: 14.42);
    }
  }

  // API FETCH EVENTŮ
  Future<void> _loadEvents({required double lat, required double lng}) async {
    // Pokud nebyly zadány souřadnice, zkusíme je vytáhnout z providera

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
    setState(() => _selectedIndex = -1); // přepnout na mapu
    // počkej až se přerenderuje body -> potom pošli příkaz mapě
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.showEvent(e);
    });
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocationProvider>();

    // 1. SCÉNÁŘ: První spuštění - nemáme polohu a načítáme
    if (locProvider.isLoading && locProvider.currentPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text(
                "Zjišťuji vaši polohu...",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 2. SCÉNÁŘ: Máme chybu a nemáme polohu (např. uživatel zakázal GPS)
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
                onPressed: () =>
                    locProvider.determinePosition(), // Zkusit znovu
                child: const Text("Zkusit znovu"),
              ),
            ],
          ),
        ),
      );
    }

    final isMap = _selectedIndex == -1;
    return Scaffold(
      appBar: isMap
          ? null
          : AppBar(
              title: Text(
                ['Akce v okolí', 'Moje akce', 'Chat', 'Profil'][_selectedIndex],
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
      body: isMap
          ? SafeArea(
              top: true,
              bottom: false,
              child: MapScreen(
                controller: _mapController,
                events: _events,
                userLocation: locProvider.currentPosition,
                isLoading: locProvider.isLoading,
              ),
            )
          : _buildSectionBody(),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(-1),
        backgroundColor: isMap ? Colors.amber[700] : Colors.blueAccent,
        child: const Icon(Icons.map_outlined, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavIcon(icon: Icons.list_alt, index: 0, label: 'Akce'),
            _buildNavIcon(icon: Icons.person, index: 1, label: 'Moje akce'),
            const SizedBox(width: 40),
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_eventsError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_eventsError!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
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
      onRefresh: _initLocationAndEvents,
      child: EventsScreen(events: _events, onShowOnMap: _handleShowOnMap),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required int index,
    required String label,
  }) {
    return IconButton(
      icon: Icon(
        icon,
        color: _selectedIndex == index ? Colors.blueAccent : Colors.grey,
        size: 28,
      ),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}
