import 'package:flutter/material.dart';
import 'package:srumec_app/screens/chat_screen.dart';
import 'package:srumec_app/screens/events_screen.dart';
import 'package:srumec_app/screens/map/map_screen.dart';
import 'package:srumec_app/controller/map_view_controller.dart';
import 'package:srumec_app/screens/my_events_screen.dart';
import 'package:srumec_app/screens/profile_screen.dart';
import 'package:srumec_app/models/event.dart';
import 'package:srumec_app/data/mock_points.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1; // -1 = mapa
  final MapViewController _mapController = MapViewController();

  // obrazovky bez mapy
  late final List<Widget> _widgetOptions = <Widget>[
    EventsScreen(
      events: mockPoints,
      onShowOnMap: _handleShowOnMap, // ⬅️ přepne na mapu + ukáže popup
    ),
    const MyEventsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

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
                [
                  'Akce v okolí',
                  'Moje akce',
                  'Chat',
                  'Profil',
                ][_selectedIndex],
              ),
            ),
      body: isMap
          ? SafeArea(top: true, bottom: false, child: MapScreen(controller: _mapController))
          : _widgetOptions[_selectedIndex],
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
            _buildNavIcon(icon: Icons.chat_bubble_outline, index: 2, label: 'Chat'),
            _buildNavIcon(icon: Icons.account_circle, index: 3, label: 'Profil'),
          ],
        ),
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
