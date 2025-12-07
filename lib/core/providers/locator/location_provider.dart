import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters pro UI
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Hlavní metoda pro načtení polohy
  Future<void> determinePosition() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Je zapnutá služba polohy (GPS)?
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Služby polohy jsou vypnuty. Zapněte prosím GPS.');
      }

      // 2. Kontrola povolení
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Povolení k poloze bylo zamítnuto.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Povolení jsou trvale zamítnuta, nemůžeme žádat znovu.
        throw Exception(
          'Povolení k poloze jsou trvale zamítnuta. Povolte je v nastavení.',
        );
      }

      // 3. Vše je OK, získáme polohu
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Řekneme UI, že máme hotovo (nebo chybu)
    }
  }
}
