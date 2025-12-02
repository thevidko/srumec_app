// events_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/models/event.dart';
import '../../../../core/network/api_endpoints.dart';

class EventsRemoteDataSource {
  final Dio dio;
  // StorageService už tu nepotřebujeme! Řeší to Dio Interceptor.

  EventsRemoteDataSource(this.dio);

  Future<List<Event>> getNearbyEvents({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    final url = '${ApiEndpoints.eventsBaseUrl}${Events.getAll}';

    final body = {
      "latitude": latitude,
      "longitude": longitude,
      "radius_m": radius,
    };

    // Už žádné ruční přidávání Options s hlavičkami!
    // Interceptor to tam "strčí" sám.

    try {
      final response = await dio.post(url, data: body);
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // Zde už řešíme jen chyby sítě nebo parsování.
      // 401 vyřešil Interceptor (a shodil aplikaci do loginu),
      // takže sem se to sice dostane, ale UI se stejně přepne.
      debugPrint("Chyba při stahování eventů: $e");
      rethrow;
    }
  }
}
