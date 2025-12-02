import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:srumec_app/controller/map_view_controller.dart';
import 'package:srumec_app/models/event.dart';

import 'widgets/event_popup_bubble.dart';
import 'widgets/map_markers.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.controller,
    required this.events,
    this.userLocation,
    this.isLoading = false,
  });
  final MapViewController controller;
  final List<Event> events;
  final Position? userLocation;
  final bool isLoading;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();
  late List<Marker> _markers;

  Event? _selected;
  bool _isLocked = false; // ⬅️ když je popup otevřený a mapa je “zamčená”

  @override
  void initState() {
    super.initState();
    widget.controller.attach(_lockOn); // ⬅️ registrace callbacku z controlleru
    _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events ||
        oldWidget.userLocation != widget.userLocation) {
      _buildMarkers();
    }
  }

  void _buildMarkers() {
    debugPrint("Překresluji markery. Počet akcí: ${widget.events.length}");
    List<Marker> markers = buildEventMarkers(widget.events, (e) => _lockOn(e));
    // Pro debug vypište souřadnice první akce
    if (widget.userLocation != null) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(
            widget.userLocation!.latitude,
            widget.userLocation!.longitude,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.7),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 5, color: Colors.black26),
              ],
            ),
            child: const Icon(Icons.my_location, color: Colors.white, size: 20),
          ),
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  Future<void> animateMapMove(
    LatLng dest,
    double destZoom, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) async {
    final start = _mapController.camera.center;
    final startZoom = _mapController.camera.zoom;

    final controller = AnimationController(vsync: this, duration: duration);
    final anim = CurvedAnimation(parent: controller, curve: curve);

    void listener() {
      final t = anim.value;
      final lat = start.latitude + (dest.latitude - start.latitude) * t;
      final lng = start.longitude + (dest.longitude - start.longitude) * t;
      final zoom = startZoom + (destZoom - startZoom) * t;
      _mapController.move(LatLng(lat, lng), zoom);
    }

    anim.addListener(listener);
    await controller.forward();
    anim.removeListener(listener);
    controller.dispose();
  }

  // Metoda pro centrování na uživatele
  void _centerOnUser() {
    if (widget.userLocation != null) {
      _mapController.move(
        LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude),
        14.0,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Poloha není k dispozici')));
    }
  }

  Future<void> _lockOn(Event e) async {
    setState(() {
      _selected = e;
      _isLocked = true;
    });

    final dest = LatLng(e.lat, e.lng);
    // nastav si cílový zoom – třeba 15.0 (nebo nech stávající)
    final targetZoom = (_mapController.camera.zoom < 14.5)
        ? 15.0
        : _mapController.camera.zoom;

    await animateMapMove(dest, targetZoom);

    // otevřít popup u daného markeru
    final marker = _findMarkerForEvent(e);
    if (marker != null) {
      _popupController.showPopupsOnlyFor([marker]);
    }
  }

  void _unlock() {
    _popupController.hideAllPopups();
    setState(() {
      _selected = null;
      _isLocked = false;
    });
  }

  void _goToDetail(Event e) {
    // Navigator.pushNamed(context, '/eventDetail', arguments: e);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Detail: ${e.title}')));
  }

  Marker? _findMarkerForEvent(Event e) {
    try {
      return _markers.firstWhere(
        (m) => m.point.latitude == e.lat && m.point.longitude == e.lng,
      );
    } catch (_) {
      return null;
    }
  }

  Event? _findEventForMarker(Marker m) {
    try {
      return widget.events.firstWhere(
        (e) => e.lat == m.point.latitude && e.lng == m.point.longitude,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // flutter_map 6.x
    final flagsWhenLocked = InteractiveFlag.none;
    final flagsWhenFree = InteractiveFlag.all & ~InteractiveFlag.rotate;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.userLocation != null
                ? LatLng(
                    widget.userLocation!.latitude,
                    widget.userLocation!.longitude,
                  )
                : const LatLng(50.0755, 14.4378),
            initialZoom: 13.5,
            interactionOptions: InteractionOptions(
              flags: _isLocked ? flagsWhenLocked : flagsWhenFree,
            ),
            onTap: (_, __) {
              if (_isLocked) _unlock();
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.example.srumec_app',
            ),
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: _markers,
                popupController: _popupController,
                popupDisplayOptions: PopupDisplayOptions(
                  snap: PopupSnap.markerTop,
                  builder: (context, marker) {
                    final e = _findEventForMarker(marker);
                    if (e == null) return const SizedBox.shrink();
                    return EventPopupBubble(
                      title: e.title,
                      subtitle: e.description,
                      onDetail: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Detail: ${e.title}')),
                          ),
                      onClose: _unlock,
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // Pokud některá verze nepředá tap při flags none:
        if (_isLocked)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _unlock,
              child: const SizedBox.shrink(),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 100, // Aby to nebylo pod hlavním FABem v MainScreen
          child: FloatingActionButton.small(
            heroTag:
                "btn_my_location", // Unikátní tag, aby se nehádal s tím v MainScreen
            backgroundColor: Colors.white,
            onPressed: _centerOnUser,
            child: Icon(
              Icons.my_location,
              color: widget.userLocation != null ? Colors.blue : Colors.grey,
            ),
          ),
        ),
        if (widget.isLoading)
          Positioned(
            top: 20, // Odsazení odshora
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), // Průhledné pozadí
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Zpřesňuji polohu...",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
