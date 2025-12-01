import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:srumec_app/core/network/api_endpoints.dart';

class AuthService {
  Future<String?> login(String email, String password) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}${Auth.login}');
    print(url);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        print(response.body);
        return null;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
