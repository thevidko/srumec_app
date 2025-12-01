import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // pro debugPrint
import 'package:srumec_app/core/services/storage_service.dart';
import 'package:srumec_app/models/event.dart';
import '../../../../core/network/api_endpoints.dart';

class EventsRemoteDataSource {
  final Dio dio;
  final StorageService _storageService = StorageService(); // Instance storage

  EventsRemoteDataSource(this.dio);

  Future<List<Event>> getNearbyEvents({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final url = '${ApiEndpoints.eventsBaseUrl}${Events.getAll}';

    // 1. Načtení tokenu z bezpečného úložiště
    final token = await _storageService.readToken();

    if (token == null) {
      // Pokud nemáme token, uživatel není přihlášen.
      // Zde můžete vyhodit výjimku, která přesměruje na LoginScreen.
      debugPrint('Chyba: Žádný token. Uživatel není přihlášen.');
      throw Exception('User not authenticated');
    }

    // 2. Příprava hlaviček s tokenem
    final options = Options(
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // <--- Tady se vloží token
      },
    );

    final body = {
      "latitude": latitude,
      "longitude": longitude,
      "radius_m": radius,
    };

    try {
      debugPrint('Volám API: $url s tokenem: ${token.substring(0, 10)}...');

      final response = await dio.post(
        url,
        data: body,
        options: options, // <--- Nezapomenout přidat options
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint("Dio Error: ${e.response?.statusCode}");
      // Pokud je chyba 401, možná vypršel token -> odhlásit uživatele?
      rethrow;
    }
  }
}
