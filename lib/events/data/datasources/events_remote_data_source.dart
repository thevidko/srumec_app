import 'package:dio/dio.dart';
import 'package:srumec_app/models/event.dart';
import '../../../../core/network/api_endpoints.dart';

class EventsRemoteDataSource {
  final Dio dio;

  EventsRemoteDataSource(this.dio);

  // Metoda nyní přijímá parametry
  Future<List<Event>> getNearbyEvents({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    // 1. URL adresa
    final url = '${ApiEndpoints.eventsBaseUrl}${Events.getAll}';

    // 2. Příprava JSON těla (Body)
    final body = {
      "latitude": latitude,
      "longitude": longitude,
      "radius_m": radius,
    };

    try {
      // 3. Změna na POST a odeslání dat
      final response = await dio.post(url, data: body);

      // Předpokládám, že backend vrací seznam v klíči 'data' nebo přímo seznam
      // Pokud backend vrací přímo List:
      final List<dynamic> data = response.data;

      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      // Pro ladění vypíšeme chybu
      print("Chyba API: $e");
      rethrow;
    }
  }
}
