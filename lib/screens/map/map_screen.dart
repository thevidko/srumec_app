import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:srumec_app/controller/map_view_controller.dart';

import '../../data/mock_points.dart';
import '../../models/event.dart';
import 'widgets/map_markers.dart';
import 'widgets/event_popup_bubble.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.controller});
  final MapViewController controller;
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  late final List<Marker> _markers =
      buildEventMarkers(mockPoints, (e) => _lockOn(e)); // při tapu na marker rovnou lock

  Event? _selected;
  bool _isLocked = false; // ⬅️ když je popup otevřený a mapa je “zamčená”

  @override
  void initState() {
    super.initState();
    widget.controller.attach(_lockOn); // ⬅️ registrace callbacku z controlleru
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller.attach(_lockOn);
    }
  }


  Future<void> animateMapMove(LatLng dest, double destZoom,
      {Duration duration = const Duration(milliseconds: 500),
       Curve curve = Curves.easeInOut}) async {
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Detail: ${e.title}')));
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
      return mockPoints.firstWhere(
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
            initialCenter: const LatLng(50.2092, 15.8328),
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
                  'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
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
                      onDetail: () => ScaffoldMessenger.of(context).showSnackBar(
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
      ],
    );
  }
}

