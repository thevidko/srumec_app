import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedLocation;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    // Defaultně Praha nebo předaná poloha
    _selectedLocation =
        widget.initialLocation ?? const LatLng(50.0755, 14.4378);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vyberte místo"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Vrátíme vybranou polohu zpět
              Navigator.of(context).pop(_selectedLocation);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              // Důležité: Při posunu mapy aktualizujeme střed
              onPositionChanged: (camera, hasGesture) {
                _selectedLocation =
                    camera.center ?? const LatLng(50.0755, 14.4378);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.srumec_app',
              ),
            ],
          ),

          // Fixní špendlík uprostřed obrazovky
          const Center(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 40,
              ), // Nadzvednutí, aby špička byla ve středu
              child: Icon(Icons.location_on, size: 50, color: Colors.red),
            ),
          ),

          // Button pro potvrzení dole (volitelné, duplikuje AppBar)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_selectedLocation),
              child: const Text("Potvrdit toto místo"),
            ),
          ),
        ],
      ),
    );
  }
}
