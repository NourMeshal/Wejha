import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/catalog.dart';
import '../models/trip.dart';
import '../state/app_state.dart';
import '../theme.dart';

/// Map of one day's stops. Tapping a pin selects the matching card.
/// Tiles: OpenStreetMap is fine for development only. Before launch switch to a
/// paid tile provider (Mapbox, MapTiler or Google) per the OSM tile usage policy.
class TripMap extends StatelessWidget {
  final int dayIndex;
  final double height;
  const TripMap({super.key, required this.dayIndex, this.height = 260});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final day = s.trip!.days[dayIndex];
    final hotel = hotels[s.trip!.prefs.hotel] ?? hotels['city']!;
    final stops = day.items
        .where((i) => i.status != BookingStatus.cancelled && i.kind != ItemKind.arrive && i.kind != ItemKind.hotelBreak)
        .toList();
    final hotelPt = LatLng(hotel.lat, hotel.lng);
    final pts = [hotelPt, ...stops.map((i) => LatLng(i.lat, i.lng))];
    final fit = pts.length >= 2
        ? CameraFit.bounds(bounds: LatLngBounds.fromPoints(pts), padding: const EdgeInsets.all(44), maxZoom: 14)
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          key: ValueKey('map-$dayIndex-${stops.map((e) => e.uid).join()}'),
          options: MapOptions(
            initialCenter: hotelPt,
            initialZoom: 11.5,
            initialCameraFit: fit,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.visitkuwait.app',
            ),
            if (pts.length >= 2)
              PolylineLayer(polylines: [
                Polyline(points: pts, strokeWidth: 3, color: VK.sea.withValues(alpha: .7), pattern: StrokePattern.dashed(segments: const [8, 6])),
              ]),
            MarkerLayer(markers: [
              Marker(
                point: hotelPt,
                width: 30,
                height: 30,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: VK.ink, shape: BoxShape.circle),
                  child: Icon(Icons.hotel, color: Colors.white, size: 16),
                ),
              ),
              for (var i = 0; i < stops.length; i++)
                Marker(
                  point: LatLng(stops[i].lat, stops[i].lng),
                  width: 34,
                  height: 34,
                  child: GestureDetector(
                    onTap: () => s.selectItem(stops[i].uid),
                    child: _Pin(n: i + 1, event: stops[i].kind == ItemKind.event, selected: s.selItem == stops[i].uid),
                  ),
                ),
            ]),
            const SimpleAttributionWidget(source: Text('OpenStreetMap contributors')),
          ],
        ),
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  final int n;
  final bool event, selected;
  const _Pin({required this.n, required this.event, required this.selected});
  @override
  Widget build(BuildContext context) {
    final col = event ? VK.saffron : VK.sea;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? col : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: selected ? Colors.white : col, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      alignment: Alignment.center,
      child: Text('$n', style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : VK.ink)),
    );
  }
}
