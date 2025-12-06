import '../events/models/event.dart';

class MapViewController {
  void Function(Event e)? _showOnMap;

  /// MapScreen si sem “zaregistruje” implementaci
  void attach(void Function(Event e) impl) {
    _showOnMap = impl;
  }

  /// Zavolej z libovolného místa (EventsScreen/MainScreen) pro vycentrování a popup
  void showEvent(Event e) {
    _showOnMap?.call(e);
  }
}
