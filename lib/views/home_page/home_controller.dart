import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as m;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as d;
import 'package:terrapipe/local_db_helper/shared_preference.dart';
import 'package:terrapipe/utilts/helper_functions.dart';

class HomeController extends GetxController {
  TextEditingController resolutionLevelController = TextEditingController();
  TextEditingController thresholdController = TextEditingController();
  TextEditingController s2IndexController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  RxList<LatLng> shapePoints = <LatLng>[].obs;
  RxList<LatLng> markPosition = <LatLng>[].obs;
  RxList<Polygon> drawnPolygons = <Polygon>[].obs;
  RxList<LatLng> linePoints = <LatLng>[].obs;
  RxList<CircleMarker> circleMarkers = <CircleMarker>[].obs;
  RxList<String> boundaryTypeList = <String>[
    'Manual',
    'Automated',
    'All',
  ].obs;
  RxList<String> domainList = <String>[].obs;
  Color selectedColor = Colors.blue;
  int geoIdCounter = 1;
  LatLng? circleCenter;
  LatLng? rectangleStart;
  LatLng? rectangleEnd;
  RxBool isDrawingLine = false.obs;
  RxBool enableSideMenu = false.obs;
  late AnimationController animationController;
  late Animation<double> animation;
  var cameraPosition = Rxn<LatLng>(const LatLng(51.5, -0.09));
  late final MapController mapController; // FlutterMap's MapController
  LatLng? tapLocation;
  RxDouble radius = 100.0.obs;
  RxDouble rectangleSize = 100.0.obs;
  RxBool isDrawingCircle = false.obs;
  RxBool isDrawPolygon = false.obs;
  RxBool isMarkPostion = false.obs;
  RxBool searchLoading = false.obs;
  RxBool isDrawingRectangle = false.obs;
  RxBool isPolygonLoading = false.obs;
  RxBool isloading = false.obs;
  RxBool locationFetched = false.obs;
  RxBool isFieldSaveLoading = false.obs;

  var dio = d.Dio();

  RxString tempGeoId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    getAllDomain();
  }

  @override
  void onClose() {
    resolutionLevelController.dispose();
    thresholdController.dispose();
    s2IndexController.dispose();
    searchController.dispose();
    super.onClose();
  }

  void clearFields() {
    resolutionLevelController.clear();
    thresholdController.clear();
    s2IndexController.clear();
    searchController.clear();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Checkif location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (kDebugMode) {
        print("Location services are disabled.");
      }
      return;
    }

    // Check for permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        if (kDebugMode) {
          print("Location permissions are denied.");
        }
        return;
      }
    }

    // Fetch the user's current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    cameraPosition.value = LatLng(position.latitude, position.longitude);
  }

  Future<void> getLocation() async {
    PermissionStatus permission = await Permission.location.request();

    if (permission.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      cameraPosition.value = LatLng(position.latitude, position.longitude);
      locationFetched.value = true;
    } else {
      if (kDebugMode) {
        print('Location permission denied');
      }
    }
  }

  void addPointToShape(LatLng point) {
    if (!isDrawPolygon.value) return;
    shapePoints.add(point);
  }

  void finishShape(context) async {
    if (shapePoints.length < 3) {
      showError("A shape must have at least 3 points.", context);
      return;
    }

    List<LatLng> finalShapePoints = List.from(shapePoints)..add(shapePoints[0]);

    drawnPolygons.add(
      Polygon(
        points: finalShapePoints,
        borderColor: selectedColor,
        borderStrokeWidth: 2.0,
        color: selectedColor.withOpacity(0.3),
        isFilled: true,
      ),
    );
  }

  void clearShapes() {
    shapePoints.clear();
    markPosition.clear();
    drawnPolygons.clear();
    isDrawingRectangle.value = false;
    isDrawingCircle.value = false;
    isMarkPostion.value = false;
    rectangleStart = null;
    rectangleEnd = null;
    shapePoints.clear();
    circleCenter = null;
    circleCenter = null;
    isDrawPolygon.value = false;
    linePoints.clear();
    isDrawingLine.value = false;
    update();
  }

  void startDrawing() {
    isDrawPolygon.value = true;
    shapePoints.clear();
  }

  void showError(String message, context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<LatLng> getRectangleCorners() {
    if (rectangleStart != null && rectangleEnd != null) {
      double lat1 = rectangleStart!.latitude;
      double lon1 = rectangleStart!.longitude;
      double lat2 = rectangleEnd!.latitude;
      double lon2 = rectangleEnd!.longitude;

      return [
        rectangleStart!, // Top-left corner
        LatLng(lat1, lon2), // Top-right corner
        rectangleEnd!, // Bottom-right corner
        LatLng(lat2, lon1), // Bottom-left corner
      ];
    }
    return [];
  }

  void updateRectangleSize() {
    if (rectangleStart != null) {
      double lat = rectangleStart!.latitude;
      double lon = rectangleStart!.longitude;
      double newLat = lat + (rectangleSize / 111320);
      double newLon = lon + (rectangleSize / (111320 * m.cos(lat * pi / 180)));
      rectangleEnd = LatLng(newLat, newLon);
    }
  }

  Future<void> getAllDomain() async {
    const baseUrl = 'https://api-ar.agstack.org';
    final url = Uri.parse('$baseUrl/domains');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {

        var data = jsonDecode(response.body);

        if (data['Domains'] is List) {
          domainList.addAll(List<String>.from(data['Domains']));
        } else {
          print('Error: "Domains" is not a list');
        }
      } else {

      }
    } catch (e) {
      print('Exception Occurred: $e');
    }
  }

  List<LatLng> parseWKTToLatLng(String wkt) {
    // Basic WKT parser for polygons
    // WKT format for a polygon might look like: "POLYGON((lon1 lat1, lon2 lat2, ..., lonN latN))"

    final regExp = RegExp(r"POLYGON\(\((.*?)\)\)");
    final match = regExp.firstMatch(wkt);

    if (match != null) {
      final coordinates = match.group(1)?.split(',') ?? [];
      return coordinates.map((coord) {
        final latLng = coord.trim().split(' ');
        final latitude = double.tryParse(latLng[1]) ?? 0.0;
        final longitude = double.tryParse(latLng[0]) ?? 0.0;
        return LatLng(latitude, longitude);
      }).toList();
    }

    return [];
  }

  void animatedMapMove(LatLngBounds bounds,
      {double zoom = 17.0,
      Duration duration = const Duration(milliseconds: 1000)}) {
    final center = LatLng(
      (bounds.southWest.latitude + bounds.northEast.latitude) / 2,
      (bounds.southWest.longitude + bounds.northEast.longitude) / 2,
    );
    mapController.move(center, zoom);
  }

  void onRadiusChanged(double value) {
    radius.value = value;
    if (tapLocation != null) {
      circleMarkers.value = [
        CircleMarker(
          point: tapLocation!,
          color: Colors.blue.withOpacity(0.5),
          radius: radius.value,
        ),
      ];
    }
    update();
  }

  // Other properties and methods...
  void addPolygon(List<LatLng> points, {Color borderColor = Colors.yellow}) {
    // Add the polygon to the list
    final polygon = Polygon(
      points: points,
      borderColor: borderColor,
      borderStrokeWidth: 2.0,
      color: Colors.transparent,
      isFilled: true,
    );
    drawnPolygons.add(polygon);
    // Move the map to fit the polygon bounds
    if (points.isNotEmpty) {
      final latitudes = points.map((point) => point.latitude);
      final longitudes = points.map((point) => point.longitude);
      final southWest = LatLng(latitudes.reduce((a, b) => a < b ? a : b),
          longitudes.reduce((a, b) => a < b ? a : b));
      final northEast = LatLng(latitudes.reduce((a, b) => a > b ? a : b),
          longitudes.reduce((a, b) => a > b ? a : b));
      final bounds = LatLngBounds(southWest, northEast);
      animatedMapMove(bounds, duration: const Duration(milliseconds: 1500));
    }
  }

  void clearPolygons() {
    drawnPolygons.clear();
  }

  void incrementValue() {
    int currentValue = int.tryParse(thresholdController.text) ?? 0;
    thresholdController.text = (currentValue + 1).toString();
  }

  void decrementValue() {
    int currentValue = int.tryParse(thresholdController.text) ?? 0;
    thresholdController.text = (currentValue - 1).toString();
  }

  void markPostionLatLng(LatLng point) {
    if (!isMarkPostion.value) return;
    markPosition.add(point);
  }

  RxBool searchEnable = false.obs;
  RxBool saveButtonEABLE = false.obs;
  var searchResult = {}.obs;

  Future<void> searchFieldByGeoId(String geoId) async {
    if (geoId.isEmpty) {
      print("Error: GeoID is empty");
      return;
    }
    drawnPolygons.clear();
    searchEnable.value = true;
    searchLoading.value = true;
    update();

    String? pipelineToken = await SharedPreference.instance.getPiplineToken();
    if (pipelineToken == null || pipelineToken.isEmpty) {
      searchLoading.value = false;
      update();
      return;
    }

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $pipelineToken',
    };
    const baseUrl = 'https://be.terrapipe.io/fetch-field';
    final cleanedGeoId = geoId.trim();
    final url = '$baseUrl/$cleanedGeoId';

    try {
      var response = await dio.request(
        url,
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );


      if (response.statusCode == 200) {
        // Ensure response.data is handled as a Map
        final Map<String, dynamic> data = response.data;
        searchResult.value=data;
        if(searchResult.containsKey("registered")){
          if(!searchResult['registered']){
            saveButtonEABLE.value=true;
          }
        }

        // Access the required fields
        final geoJson = data['JSON Response']['Geo JSON'];
        final coordinates = geoJson?['geometry']?['coordinates'];
        if (coordinates != null) {
          // Parse coordinates into LatLng list
          List<LatLng> polygonPoints = parseCoordinatesToLatLng(coordinates);
          addPolygon(polygonPoints);
        } else {
          showSnackBar(
            title: "Search",
            message: "No result found against given id",
          );
        }
      } else {
        // print("Error: ${response.statusMessage}");
        searchLoading.value = false;
        update();
      }
    } catch (e) {
      // print('Exception Occurred: $e');
      showSnackBar(
        title: "Search",
        message: "No result found against given id",
      );
      searchLoading.value = false;
      update();
    } finally {
      searchLoading.value = false;
      update();
    }
  }

  /// Helper function to parse coordinates into LatLng list
  List<LatLng> parseCoordinatesToLatLng(dynamic coordinates) {
    if (coordinates is List && coordinates.isNotEmpty) {
      return coordinates.first
          .map<LatLng>((coord) => LatLng(coord[1], coord[0]))
          .toList();
    }
    return [];
  }

  Future<dynamic> saveFieldByGeoIdTerraPipe(String geoId) async {
    isFieldSaveLoading.value = true;
    update();
    String? piplineToken = await SharedPreference.instance.getPiplineToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $piplineToken'
    };

    var data = json.encode({
      "geo_id": geoId,
    });

    try {
      var response = await dio.request(
        'https://be.terrapipe.io/geo-id',
        options: d.Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        Get.back();
        showSnackBar(
          color: Colors.green,
          title: "Success",
          message: "Field has been saved successfully",
        );
        saveButtonEABLE.value=false;
        Clipboard.setData(ClipboardData(text: geoId));
        isFieldSaveLoading.value = false;
        return response.data;
      } else {
        // Show error snackbar
        isFieldSaveLoading.value = false;
        showSnackBar(
          color: Colors.red,
          title: "Error",
          message: response.statusMessage ?? "An unknown error occurred.",
        );
        return {'error': response.statusMessage};
      }
    } catch (e) {
      isFieldSaveLoading.value = false;
      // Show exception snackbar
      showSnackBar(
        color: Colors.red,
        title: "Exception",
        message: e.toString(),
      );
      return {'error': e.toString()};
    }
  }

  Future savePolygonTeraTrac() async {
    isPolygonLoading.value = true;
    const baseUrl = 'https://api-ar.agstack.org';
    final url = Uri.parse('$baseUrl/register-field-boundary');
    String? apiKey =
        await SharedPreference.instance.getSecretKeyLocalDb('api_key');
    String? clientSecret =
        await SharedPreference.instance.getSecretKeyLocalDb('client_secret');

    final headers = {
      'API-KEYS-AUTHENTICATION': '1',
      'API-KEY': apiKey ?? '',
      'CLIENT-SECRET': clientSecret ?? '',
      'AUTOMATED-FIELD': '0',
    };
    String wkt = convertPolygonToWKT(drawnPolygons);
    String? s2Index =
        s2IndexController.text.isNotEmpty ? s2IndexController.text : null;
    String? threshold =
        thresholdController.text.isNotEmpty ? thresholdController.text : null;

    final body = {
      'wkt': wkt,
      if (s2Index != null) 's2_index': s2Index,
      if (threshold != null) 'threshold': int.tryParse(threshold) ?? threshold,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        isPolygonLoading.value = false;
        // Extract Geo Id from the response
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final geoId = responseData['Geo Id'] ?? 'Unknown Geo Id';
        tempGeoId.value = geoId;
        await saveFieldByGeoIdTerraPipe(geoId);
        // Show success dialog with Geo Id and copy button
        Get.dialog(
          AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Success',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You have successfully added the polygon!',
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  'Geo Id: $geoId',
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: geoId));
                  Get.back();
                  showSnackBar(
                    color: Colors.green,
                    title: "Copied",
                    message: "Geo Id has been copied to clipboard!",
                  );
                },
                child: const Text(
                  'Copy',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      } else {
        var result = jsonDecode(response.body);
        showSnackBar(
          color: Colors.red,
          title: "Exception",
          message: result['message'],
        );
        isPolygonLoading.value = false;
      }
    } catch (e) {
      isPolygonLoading.value = false;
      update();
    }
  }

  String convertPolygonToWKT(RxList<Polygon> polygons) {
    if (polygons.isEmpty || polygons.first.points.isEmpty) {
      print("Error: Polygon points are empty");
      return 'POLYGON()';
    }

    final coordinates = polygons.map((polygon) {
      final polygonCoordinates = polygon.points
          .map((point) => '${point.longitude} ${point.latitude}')
          .join(', ');

      return '($polygonCoordinates)';
    }).join(', ');

    return 'POLYGON($coordinates)';
  }
}
