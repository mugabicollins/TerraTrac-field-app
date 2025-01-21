import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/utilts/helper_functions.dart';

class WalkTrackingPage extends StatefulWidget {
  const WalkTrackingPage({super.key});

  @override
  State<WalkTrackingPage> createState() => _WalkTrackingPageState();
}

class _WalkTrackingPageState extends State<WalkTrackingPage> {
  List<LatLng> polylinePoints = [];
  List<LatLng> polygonPoints = [];
  List<Marker> markers = [];
  LatLng? currentPosition;
  bool isTracking = false;
  bool isAddPointVisible = false; 
  MapController mapController = MapController();
  double? area;
  final Geodesy geodesy = Geodesy();
  void navigateToCurrentLocation() {
    if (currentPosition != null) {
      mapController.move(currentPosition!, 22.0);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentPosition();
  }

  /// Calculate the area of the polygon when tracking is stopped
  int assignGeoId(List<LatLng> points) {
    if (points.length < 3) {
      throw ArgumentError(
          "At least 3 points are required to form a valid polygon.");
    }

    String pointsString =
        points.map((p) => "${p.latitude},${p.longitude}").join(';');
    int geoId = pointsString.hashCode.abs();


    return geoId;
  }

  /// Get the current position of the user
  Future<void> _getCurrentPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        mapController.move(currentPosition!,
            18.0); // Center the map on the user's current position
      });
    } catch (e) {
      print("Error getting current position: $e");
    }
  }

  Marker createMarker(LatLng point) {
    return Marker(
      point: point,
      width: 10,
      height: 10,
      child: const Icon(
        Icons.circle,
        color: Colors.green,
        size: 10,
      ),
    );
  }

  /// Add a point when the user clicks "Add Point"
  void addPoint() {
    if (currentPosition != null) {
      setState(() {
        polylinePoints.add(currentPosition!);

        markers.add(createMarker(currentPosition!));
        polygonPoints.add(currentPosition!);
      });
    }
  }

  /// Undo the last point
  void undoPoint() {
    if (polylinePoints.isNotEmpty &&
        markers.isNotEmpty &&
        polygonPoints.isNotEmpty) {
      setState(() {
        polylinePoints.removeLast();
        markers.removeLast();
        polygonPoints.removeLast();
      });
    }
  }

  /// Save the points and draw the polygon
  void savePolygon() {
    setState(() {
      if (polygonPoints.length >= 3) {
        polylinePoints =
            List.from(polygonPoints); // Draw the line connecting points
      } else {
        // Show a message if not enough points for a polygon
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("At least 3 points are required to form a polygon")),
        );
      }
    });
  }

  /// Start the tracking
  StreamSubscription<Position>? positionStream;
  final double minDistanceThreshold = 5.0; // Minimum distance in meters

  void startTracking() async {
    setState(() {
      isTracking = true;
      isAddPointVisible = true;
      polygonPoints.clear();
      polylinePoints.clear();
      markers.clear();
    });

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);

      // Check the distance between the last point and the new position

      setState(() {
        currentPosition = newPosition;
      });
    });

    // Add the first point immediately
    if (currentPosition != null) {
      addPoint();
    }
  }

  /// Stop the tracking
  void stopTracking() {
    setState(() {
      isTracking = false;
      isAddPointVisible =
          false; // Hide the "Add Point" button when tracking stops
      savePolygon(); // Save the polygon when finished
      positionStream?.cancel(); // Stop the position stream

      // Calculate the area of the polygon and generate geoId
      int geoId = assignGeoId(polygonPoints);

      // Show a dialog displaying the geoId
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Generated GeoID"),
            content: Text("The GeoID for the polygon is: $geoId"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      // Optionally show the area in a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("GeoID: $geoId has been generated."),
        ),
      );
    });
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Cancel the stream to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Walk Tracking",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.primaryColor,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: currentPosition ?? const LatLng(0, 0),
              zoom: 20.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                subdomains: ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color: Colors.blue,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
              PolygonLayer(
                polygons: [
                  Polygon(
                    points: polygonPoints,
                    color: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                    isDotted: true,
                    isFilled: true,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                // Start/Stop Button
                FloatingActionButton(
                  onPressed: () {
                    if (isTracking) {
                      stopTracking();
                      showSnackBar(
                          title: "Stops",
                          message: "Tracking Stops",
                          color: Colors.redAccent);
                    } else {
                      startTracking();
                      showSnackBar(
                          title: "Start",
                          message: "Tracking Started",
                          color: Colors.green);
                    }
                  },
                  child: Icon(isTracking ? Icons.stop : Icons.play_arrow),
                ),
                const SizedBox(height: 10),
                // Add Point Button (Visible only when tracking is started)
                if (isAddPointVisible)
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: addPoint,
                        backgroundColor: Colors.blue,
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                // Undo Button
                if (isAddPointVisible)
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: undoPoint,
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.undo,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                // Save Button (to save the points as polygon)
                if (isAddPointVisible)
                  Column(
                    children: [
                      FloatingActionButton(
                        onPressed: savePolygon,
                        backgroundColor: Colors.green,
                        child: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                // Button to navigate to current location
                FloatingActionButton(
                  onPressed: navigateToCurrentLocation,
                  backgroundColor: Colors.green,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
