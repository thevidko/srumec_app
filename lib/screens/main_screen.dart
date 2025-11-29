import 'package:dio/dio.dart';
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

  Future<void> _testApi() async {
    final dio = Dio();

    const url = 'http://10.0.2.2:4000/v1/events/get-nearby';

    final body = {"latitude": 50.087, "longitude": 14.42, "radius_m": 5000};

    try {
      final response = await dio.post(url, data: body);

      if (!mounted) return;

      // Výpis úspěchu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Úspěch! Načteno akcí: ${(response.data as List).length}',
          ),
          backgroundColor: Colors.green,
        ),
      );

      print("ODPOVĚĎ SERVERU: ${response.data}");
    } on DioException catch (e) {
      if (!mounted) return;

      String errorMsg = e.message ?? 'Neznámá chyba';
      if (e.response != null) {
        errorMsg +=
            " (Server: ${e.response?.statusCode} - ${e.response?.data})";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chyba: $errorMsg'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      print("CHYBA: $e");
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
              // --- 3. PŘIDAT TLAČÍTKO DO APPBARU ---
              actions: [
                IconButton(
                  icon: const Icon(Icons.wifi_tethering), // Ikonka vysílače
                  tooltip: 'Test API',
                  onPressed: _testApi, // Volání naší metody
                ),
              ],
              // -------------------------------------
            ),
      body: isMap
          ? SafeArea(
              top: true,
              bottom: false,
              child: MapScreen(controller: _mapController),
            )
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
