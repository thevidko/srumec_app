import 'package:flutter/material.dart';
import 'package:srumec_app/screens/events_screen.dart';
import 'package:srumec_app/screens/map_screen.dart';
import 'package:srumec_app/screens/my_events_screen.dart';
import 'package:srumec_app/screens/settings_screen.dart';

// Nezapomeňte upravit cestu k souborům, pokud máte jinou strukturu
// 'package:srumec_app/...' -> 'package:nazev_vaseho_projektu/...'

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index aktuálně vybrané záložky
  int _selectedIndex = 0;

  // Seznam widgetů (obrazovek), které se budou zobrazovat
  static const List<Widget> _widgetOptions = <Widget>[
    MapScreen(),
    EventsScreen(),
    MyEventsScreen(),
    SettingsScreen(),
  ];

  // Seznam názvů pro AppBar
  static const List<String> _appBarTitles = <String>[
    'Mapa',
    'Akce v okolí',
    'Moje akce',
    'Nastavení',
  ];

  // Metoda, která se zavolá při klepnutí na záložku
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Horní lišta (AppBar) s dynamickým názvem
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]),
        backgroundColor: Colors.blueAccent, // Můžete si zvolit vlastní barvu
      ),

      // Tělo aplikace - zobrazí widget z našeho seznamu podle vybraného indexu
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      // Spodní navigační lišta
      bottomNavigationBar: BottomNavigationBar(
        // Seznam tlačítek (záložek)
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Akce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Moje akce',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Nastavení',
          ),
        ],
        currentIndex: _selectedIndex, // Která záložka je aktivní
        onTap: _onItemTapped, // Co se stane po klepnutí
        // Důležité: Nastavení barev pro neaktivní a aktivní záložky
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.blueAccent,
      ),
    );
  }
}
