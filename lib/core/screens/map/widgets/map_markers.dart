import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../events/models/event.dart';

typedef EventTap = void Function(Event event);

List<Marker> buildEventMarkers(List<Event> points, EventTap onTap) {
  return points.map((e) {
    return Marker(
      point: LatLng(e.lat, e.lng),
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => onTap(e),
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40.0),
      ),
    );
  }).toList();
}
