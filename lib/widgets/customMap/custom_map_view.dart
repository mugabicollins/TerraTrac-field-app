import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';

class CustomFlutterMap extends StatelessWidget {
  final MapController mapController;
  final MapOptions? mapOptions;
  final List<Polygon> polygons;
  final List<LatLng> markers;
  final Color markerColor;
  String? mapPath;
  final void Function(LatLng)? onMapTap;

   CustomFlutterMap({
    Key? key,
    required this.mapController,
    required this.polygons,
    required this.markers,
    this.mapOptions,
    this.mapPath,
    this.markerColor = Colors.red, // Default marker color
    this.onMapTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print("here is the map path ${mapPath}");
    return FlutterMap(
      mapController: mapController,
      options: mapOptions ??
          MapOptions(
            initialCenter: polygons.isNotEmpty
                ? polygons[0].points[0]
                : const LatLng(51.5, -0.09),
            initialZoom: 12.0,
            onTap: (_, LatLng point) {
              if (onMapTap != null) {
                onMapTap!(point); // Handle tap
              }
            },
          ),
      children: [
        // Map Tiles
        TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          subdomains: ['a', 'b', 'c'],
          tileProvider: CachedTileProvider(
            maxStale: const Duration(days: 30),
            store: HiveCacheStore(mapPath, hiveBoxName: 'HiveCacheStore'),
          ),
        ),

        // Polygons Layer
        PolygonLayer(
          polygons: polygons,

        ),

        // Markers Layer
        MarkerLayer(
          markers: markers
              .map((point) => Marker(
                    point: point,
                    width: 20,
                    height: 20,
                    child:
                        Icon(Icons.location_on, color: markerColor, size: 20),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
