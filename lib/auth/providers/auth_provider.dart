import 'package:flutter/material.dart';
import 'package:srumec_app/core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  // DŮLEŽITÉ: Defaultně false
  bool _isAuthenticated = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> checkLoginStatus() async {
    final token = await _storageService.readToken();
    // Jednoduchá logika: Máme token? -> Jsme přihlášeni.
    _isAuthenticated = token != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String token) async {
    await _storageService.saveToken(token);
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    debugPrint("🚪 AuthProvider: Provádím logout...");

    // 1. Smazat token z mobilu
    await _storageService.deleteToken();

    // 2. DŮLEŽITÉ: Změnit stav v paměti aplikace
    _isAuthenticated = false;

    // 3. Říct aplikaci "Překresli se!"
    notifyListeners();

    debugPrint(
      "🚪 AuthProvider: Logout hotov. isAuthenticated = $_isAuthenticated",
    );
  }

  Future<String?> getToken() async {
    return await _storageService.readToken();
  }
}
