import '../../events/models/event.dart';

class MapViewController {
  void Function(Event e)? _showOnMap;

  void attach(void Function(Event e) impl) {
    _showOnMap = impl;
  }

  void showEvent(Event e) {
    _showOnMap?.call(e);
  }
}
