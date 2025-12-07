import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:srumec_app/core/controller/map_view_controller.dart';
import 'package:srumec_app/events/screens/event_detail_screen.dart';
import 'package:srumec_app/events/models/event.dart';
import 'widgets/event_popup_bubble.dart';

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
  bool _isLocked = false;

  static const Color vibrantPurple = Color(0xFF6200EA);
  static const Color neonAccent = Color(0xFFD500F9);

  @override
  void initState() {
    super.initState();
    widget.controller.attach(_lockOn);
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
    // 1. Markery pro AKCE
    List<Marker> markers = widget.events.map((event) {
      return Marker(
        width: 45,
        height: 45,
        point: LatLng(event.lat, event.lng),
        // Alignment: Default je střed. U špendlíku chceme, aby "špička"
        // ukazovala na místo. Proto posuneme těžiště trochu nahoru.
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _lockOn(event),
          child: _buildCustomPin(vibrantPurple),
        ),
      );
    }).toList();

    // 2. Marker pro UŽIVATELE
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
              color: neonAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: neonAccent.withOpacity(0.5),
                  spreadRadius: 2,
                ),
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

  Widget _buildCustomPin(Color color) {
    return Icon(
      Icons.location_on,
      color: color,
      size: 45,
      shadows: const [
        Shadow(offset: Offset(0, 2), blurRadius: 6.0, color: Colors.black38),
      ],
    );
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

  void _centerOnUser() {
    if (widget.userLocation != null) {
      _mapController.move(
        LatLng(widget.userLocation!.latitude, widget.userLocation!.longitude),
        15.0,
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
    final targetZoom = (_mapController.camera.zoom < 14.5)
        ? 15.0
        : _mapController.camera.zoom;

    await animateMapMove(dest, targetZoom);

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
            initialZoom: 15,
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
                      onDetail: () {
                        _unlock();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EventDetailScreen(
                              event: e,
                              onShowOnMap: _lockOn,
                            ),
                          ),
                        );
                      },
                      onClose: _unlock,
                    );
                  },
                ),
              ),
            ),
          ],
        ),

        // Tlačítko pro návrat na polohu uživatele
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton.small(
            heroTag: "btn_my_location",
            backgroundColor: Colors.white,
            elevation: 4,
            onPressed: _centerOnUser,
            child: Icon(
              Icons.my_location,
              color: widget.userLocation != null ? vibrantPurple : Colors.grey,
            ),
          ),
        ),

        // Loading indikátor nahoře
        if (widget.isLoading)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: vibrantPurple,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Zpřesňuji polohu...",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
