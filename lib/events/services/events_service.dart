import 'package:dio/dio.dart';
import 'package:srumec_app/events/data/datasources/events_remote_data_source.dart';
import 'package:srumec_app/events/data/repositories/event_repository.dart';
import 'package:srumec_app/models/event.dart';

class EventsService {
  EventsService({Dio? dio})
      : _repository = EventsRepository(
          EventsRemoteDataSource(dio ?? Dio()),
        );

  final EventsRepository _repository;

  Future<List<Event>> fetchNearby({
    required double lat,
    required double lng,
    int radius = 5000,
  }) {
    return _repository.getNearbyEvents(
      lat: lat,
      lng: lng,
      radius: radius,
    );
  }
}
