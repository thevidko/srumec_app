import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Mock data pro markery na mapě
  final List<Map<String, dynamic>> _mockPoints = [
    {
      'lat': 50.2089,
      'lng': 15.8322,
      'title': 'Bílá věž',
      'subtitle': 'Dominanta Hradce Králové',
    },
    {
      'lat': 50.1873,
      'lng': 15.8235,
      'title': 'Park 360',
      'subtitle': 'Místo konání festivalů',
    },
    {
      'lat': 50.2185,
      'lng': 15.8524,
      'title': 'Spontánní grilovačka',
      'subtitle': 'Dnes v 18:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Doporučuji obalit vše do Scaffold pro lepší strukturu
      body: SlidingUpPanel(
        // Vlastnosti panelu
        minHeight: 80.0, // Výška panelu, když je schovaný
        maxHeight: 400.0, // Maximální výška, kam se dá vytáhnout
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),

        // PANEL: Obsah, který se bude vysouvat (seznam událostí)
        panel: _buildEventListPanel(),

        // BODY: Obsah, který je za panelem (naše mapa)
        body: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(50.2092, 15.8328),
            initialZoom: 13.5,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.srumec_app',
            ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
      ),
    );
  }

  // Metoda, která vrací widget se seznamem událostí
  Widget _buildEventListPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Madlo" pro uchopení panelu
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        // Nadpis
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Akce v okolí",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Seznam událostí
        Expanded(
          child: ListView.builder(
            itemCount: _mockPoints.length,
            itemBuilder: (context, index) {
              final event = _mockPoints[index];
              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(event['title']),
                subtitle: Text(event['subtitle']),
                onTap: () {
                  // Zde můžete implementovat např. posun mapy na daný bod
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Metoda pro vytvoření markerů na mapě
  List<Marker> _buildMarkers() {
    return _mockPoints.map((pointData) {
      return Marker(
        point: LatLng(pointData['lat'], pointData['lng']),
        width: 80,
        height: 80,
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      );
    }).toList();
  }
}
