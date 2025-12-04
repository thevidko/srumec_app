import 'package:flutter/widgets.dart';
import 'package:srumec_app/events/data/datasources/events_remote_data_source.dart';
import 'package:srumec_app/models/event.dart';

class EventsRepository {
  final EventsRemoteDataSource remoteDataSource;

  EventsRepository(this.remoteDataSource);

  Future<List<Event>> getNearbyEvents({
    required double lat,
    required double lng,
    int radius = 5000, // Defaultní hodnota
  }) async {
    try {
      return await remoteDataSource.getNearbyEvents(
        latitude: lat,
        longitude: lng,
        radius: radius,
      );
    } catch (e) {
      print("Chyba v repo: $e");
      return [];
    }
  }

  //CREATE EVENT
  Future<bool> createEvent({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    required DateTime happenTime,
    required String userId,
  }) async {
    try {
      final body = {
        "organizer_ref": userId,
        "title": title,
        "description": description,
        "latitude": latitude,
        "longitude": longitude,
        // ISO 8601 string
        "happen_time": happenTime.toUtc().toIso8601String(),
      };

      await remoteDataSource.createEvent(body);
      return true;
    } catch (e) {
      debugPrint("Chyba v repo při create eventu: $e");
      return false;
    }
  }
}
