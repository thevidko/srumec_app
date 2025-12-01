import 'package:flutter/material.dart';
import 'package:srumec_app/controller/map_view_controller.dart';
import 'package:srumec_app/events/screens/events_screen.dart';
import 'package:srumec_app/events/screens/my_events_screen.dart';
import 'package:srumec_app/events/services/events_service.dart';
import 'package:srumec_app/models/event.dart';
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
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoadingEvents = true;
      _eventsError = null;
    });

    try {
      final events = await _eventsService.fetchNearby(
        lat: 50.087,
        lng: 14.42,
        radius: 5000,
      );

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
      if (!mounted) return;
      setState(() {
        _isLoadingEvents = false;
      });
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
                    onPressed: _isLoadingEvents ? null : _loadEvents,
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
        return const ChatScreen();
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
            Text(
              _eventsError!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadEvents,
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
      onRefresh: _loadEvents,
      child: EventsScreen(
        events: _events,
        onShowOnMap: _handleShowOnMap,
      ),
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
