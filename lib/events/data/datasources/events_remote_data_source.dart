import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/events/models/event.dart';
import '../../../../core/network/api_endpoints.dart';

class EventsRemoteDataSource {
  final Dio dio;
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

  //CREATE EVENT
  Future<void> createEvent(Map<String, dynamic> body) async {
    final url = '${ApiEndpoints.eventsBaseUrl}${Events.create}';

    debugPrint("📤 Odesílám JSON body: $body");

    try {
      // Body už je připravené, stačí ho poslat
      final response = await dio.post(url, data: body);

      // Pokud server vrátí 200/201, považujeme to za úspěch
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      debugPrint(
        "❌ Chyba vytvoření eventu (Status: ${e.response?.statusCode})",
      );
      debugPrint("📩 Odpověď serveru: ${e.response?.data}");
      rethrow; // Pošleme chybu zpět do Repozitáře, kde ji chytáte do try-catch
    }
  }

  // GET MY EVENTS
  Future<List<Event>> getMyEvents() async {
    final url = '${ApiEndpoints.eventsBaseUrl}${Events.getMy}';
    try {
      debugPrint("🚀 Odesílám request na: $url");
      debugPrint("🔑 Headers: ${dio.options.headers}");
      final response = await dio.post(url, data: {});
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Chyba při stahování mých eventů: $e");
      rethrow;
    }
  }
}
