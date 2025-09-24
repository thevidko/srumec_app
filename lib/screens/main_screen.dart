import 'package:flutter/material.dart';
import 'package:srumec_app/screens/events_screen.dart';
import 'package:srumec_app/screens/map_screen.dart';
import 'package:srumec_app/screens/my_events_screen.dart';
import 'package:srumec_app/screens/profile_screen.dart'; // Import nového screenu
import 'package:srumec_app/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = -1; // -1 bude znamenat, že je vybraná mapa (FAB)

  // Seznam obrazovek pro BottomAppBar, mapa zde už není
  static const List<Widget> _widgetOptions = <Widget>[
    EventsScreen(),
    MyEventsScreen(),
    SettingsScreen(),
    ProfileScreen(), // Přidání nového screenu
  ];

  // Metoda pro změnu obrazovky
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == -1
              ? 'Mapa'
              : [
                  'Akce v okolí',
                  'Moje akce',
                  'Nastavení',
                  'Profil',
                ][_selectedIndex],
        ),
      ),

      // Tělo se dynamicky mění podle toho, co je vybráno
      body: _selectedIndex == -1
          ? const MapScreen()
          : _widgetOptions[_selectedIndex],

      // Plovoucí tlačítko (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(-1), // Při kliknutí se zobrazí mapa
        backgroundColor: _selectedIndex == -1
            ? Colors.amber[700]
            : Colors.blueAccent,
        child: const Icon(Icons.map_outlined, color: Colors.white),
        elevation: 2.0,
      ),
      // Umístění FAB doprostřed a "přikotvení" k BottomAppBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Spodní lišta
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Tvar s "výřezem"
        notchMargin: 8.0, // Mezera mezi FAB a lištou
        child: Row(
          // Rozmístění ikon v liště
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Tlačítka vlevo
            _buildNavIcon(icon: Icons.list_alt, index: 0, label: 'Akce'),
            _buildNavIcon(icon: Icons.person, index: 1, label: 'Moje akce'),
            // Mezera uprostřed pro FAB
            const SizedBox(width: 40),
            // Tlačítka vpravo
            _buildNavIcon(icon: Icons.settings, index: 2, label: 'Nastavení'),
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

  // Pomocná metoda pro vytvoření ikon v liště, aby se neopakoval kód
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
