import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:srumec_app/config/app_config.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    final url = Uri.parse('${AppConfig.authBaseUrl}/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        // Zde můžete logovat chybu, např. print(response.body);
        return null;
      }
    } catch (e) {
      // Zde můžete logovat chybu připojení, např. print(e.toString());
      return null;
    }
  }
}
