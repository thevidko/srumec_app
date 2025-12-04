import 'package:flutter/material.dart';
import 'package:srumec_app/core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;

  // Metoda pro kontrolu přítomnosti údajů
  Future<void> checkLoginStatus() async {
    final token = await _storageService.readToken();
    final uid = await _storageService.readUserId();

    if (token != null) {
      _isAuthenticated = true;
      _userId = uid;
    } else {
      _isAuthenticated = false;
      _userId = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<void> login(String token, String userId) async {
    await _storageService.saveToken(token);
    await _storageService.saveUserId(userId);

    _isAuthenticated = true;
    _userId = userId;
    notifyListeners();
  }

  // Logout -> smazání všech credetials z paměti
  Future<void> logout() async {
    await _storageService.deleteAll();

    _isAuthenticated = false;
    _userId = null;
    notifyListeners();
  }

  // Gettery
  Future<String?> getToken() async {
    return await _storageService.readToken();
  }

  Future<String?> getUUID() async {
    return await _storageService.readUserId();
  }
}
