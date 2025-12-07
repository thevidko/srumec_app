import 'package:flutter/material.dart';
import 'package:srumec_app/core/services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _userId;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userId => _userId;
  String? get token => _token;

  // Metoda pro kontrolu přítomnosti údajů při startu
  Future<void> checkLoginStatus() async {
    final token = await _storageService.readToken();
    final uid = await _storageService.readUserId();

    if (token != null) {
      _isAuthenticated = true;
      _userId = uid;
      _token = token;
    } else {
      _isAuthenticated = false;
      _userId = null;
      _token = null;
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
    _token = token;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    await _storageService.deleteAll();

    _isAuthenticated = false;
    _userId = null;
    _token = null;
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
