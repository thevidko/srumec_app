import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:srumec_app/core/network/api_endpoints.dart';

class AuthService {
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${AuthEndpoints.login}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final userId = data['user']['id'];

        if (token != null && userId != null) {
          return {'token': token, 'userId': userId.toString()};
        }
        return null;
      } else {
        debugPrint("Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      debugPrint("AuthService Error: $e");
      return null;
    }
  }
}
