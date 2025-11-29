import 'package:srumec_app/models/event.dart';
import '../datasources/events_remote_data_source.dart';

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
}
