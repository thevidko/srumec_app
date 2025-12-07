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
    final url = '${ApiEndpoints.eventsBaseUrl}${EventsEndpoints.getAll}';

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
      debugPrint("Chyba při stahování eventů: $e");
      rethrow;
    }
  }

  //CREATE EVENT
  Future<void> createEvent(Map<String, dynamic> body) async {
    final url = '${ApiEndpoints.eventsBaseUrl}${EventsEndpoints.create}';
    try {
      final response = await dio.post(url, data: body);

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
      debugPrint("Chyba vytvoření eventu (Status: ${e.response?.statusCode})");
      debugPrint("Odpověď serveru: ${e.response?.data}");
      rethrow;
    }
  }

  // GET MY EVENTS
  Future<List<Event>> getMyEvents() async {
    final url = '${ApiEndpoints.eventsBaseUrl}${EventsEndpoints.getMy}';
    try {
      debugPrint("Odesílám request na: $url");
      final response = await dio.post(url, data: {});
      final List<dynamic> data = response.data;
      return data.map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Chyba při stahování mých eventů: $e");
      rethrow;
    }
  }
}
