// core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/auth/providers/auth_provider.dart';

class DioClient {
  final Dio dio;
  final AuthProvider authProvider;

  DioClient(this.authProvider) : dio = Dio() {
    // Základní konfigurace
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    // PŘIDÁNÍ INTERCEPTORU
    dio.interceptors.add(
      InterceptorsWrapper(
        // A) PŘED ODESLÁNÍM REQUESTU: Přidat token
        onRequest: (options, handler) async {
          final token = await authProvider.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint("Odesílám Header: ${options.headers['Authorization']}");
          } else {
            debugPrint("Odesílám request BEZ tokenu!");
          }
          return handler.next(options);
        },

        // B) PŘI ODPOVĚDI (Chyba): Hlídat 401
        onError: (DioException e, handler) async {
          debugPrint("Dio Error Status: ${e.response?.statusCode}");

          if (e.response?.statusCode == 401) {
            debugPrint("Session vypršela (401). Odhlašuji uživatele...");

            //PŘEPNUTÍ NA LOGIN SCREEN
            await authProvider.logout();
          }

          return handler.next(e);
        },
      ),
    );
  }
}
