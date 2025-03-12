import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as d;
import 'package:terrapipe/app/data/repositories/shared_preference.dart';
import 'package:terrapipe/utils/helper_functions.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../data/repositories/terratrac_db.dart';

class HomeController extends GetxController {
  TextEditingController resolutionLevelController = TextEditingController();
  TextEditingController thresholdController = TextEditingController();
  TextEditingController s2IndexController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  RxList<LatLng> shapePoints = <LatLng>[].obs;
  RxList<Polygon> drawnPolygons = <Polygon>[].obs;
  RxList<LatLng> linePoints = <LatLng>[].obs;
  final TerraTracDataBaseHelper dbHelper = TerraTracDataBaseHelper();
  RxList<String> boundaryTypeList = <String>[
    'Manual',
    'Automated',
    'All',
  ].obs;
  RxList<String> domainList = <String>[].obs;
  Color selectedColor = Colors.blue;
  int geoIdCounter = 1;
  RxBool enableSideMenu = false.obs;
  late AnimationController animationController;
  late Animation<double> animation;
  var cameraPosition = Rxn<LatLng>(const LatLng(51.5, -0.09));
  final MapController mapController=MapController();
  LatLng? tapLocation;
  RxBool isDrawPolygon = false.obs;
  RxBool searchLoading = false.obs;
  RxBool isDrawingRectangle = false.obs;
  RxBool isPolygonLoading = false.obs;
  RxBool isloading = false.obs;
  RxBool locationFetched = false.obs;
  RxBool isFieldSaveLoading = false.obs;

  var dio = d.Dio();

  RxString tempGeoId = ''.obs;
  RxString mapPath = "".obs;

  @override
  void onInit() {
    super.onInit();
    PaintingBinding.instance.imageCache.maximumSize = 20000; // Adjust number as needed
    // mapController = MapController();
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
    // try {
      // Set initial loading state
      locationFetched.value = false;
      mapPath.value=await getPath();
      // Request location permission
      PermissionStatus permission = await Permission.location.request();

      if (permission.isGranted) {
        // Get the current location of the user
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        LatLng userLocation = LatLng(position.latitude, position.longitude);
        cameraPosition.value = userLocation;
        locationFetched.value = true;
        update();
        await Future.delayed(const Duration(seconds: 3));
        if (mapController != null) {
          // Zoom out to show a 100 km radius (~ Zoom level 8)
          mapController.move(userLocation, 12.0);
          // Wait for 3 seconds before zooming back in
          await Future.delayed(const Duration(seconds: 2));
          mapController.move(userLocation, 17.0);
          // Cache the map tiles
          // await cacheMapTiles(cameraPosition.value!, 100000);
          // bool isCached = await isMapCached(cameraPosition.value!, 10000);
          // if (isCached) {
          //   print("Map is fully cached!");
          // } else {
          //   print("Map is not fully cached. Consider downloading tiles.");
          // }
        } else {
          debugPrint("MapController is null");
        }

        // Set loading state to false only after all operations are complete
        locationFetched.value = true;

      }
      else {
        debugPrint('Location permission denied');
        await _requestLocationPermission();
        // Set loading state to false if permission denied
        locationFetched.value = true;
      }
    // }
    // catch (e) {
    //   debugPrint('Error occurred: $e');
    //   // Set loading state to false in case of error
    //   locationFetched.value = true;
    // }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // Re-request permission if necessary
      PermissionStatus permission = await Permission.location.request();

      if (permission.isGranted) {
        // Call getLocation again if the user grants permission
        await getLocation();
      } else {
        // You can show a message or a dialog asking the user to enable location manually
        debugPrint('Location permission still denied');
        // Ensure loading state is false even if permission denied
        locationFetched.value = true;
      }
    } catch (e) {
      debugPrint('Error in requesting permission: $e');
      // Ensure loading state is false in case of error
      locationFetched.value = true;
    }
  }

  Future<String> getPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    return cacheDirectory.path;
  }

  // Future<bool> isMapCached(LatLng center, double radiusInMeters) async {
  //   int minZoom = 8;
  //   int maxZoom = 16;
  //
  //   // Ensure latitudes are within valid Mercator range
  //   center = LatLng(
  //     center.latitude.clamp(-85.05112878, 85.05112878),
  //     center.longitude.clamp(-180, 180),
  //   );
  //
  //   Directory cacheDir = await getApplicationDocumentsDirectory();
  //   mapPath.value = '${cacheDir.path}/map_tiles';
  //
  //   // ✅ Ensure directory exists
  //   Directory tileDir = Directory(mapPath.value);
  //   if (!tileDir.existsSync()) {
  //     debugPrint("❌ Cache directory does not exist: ${mapPath.value}");
  //     await tileDir.create(recursive: true);
  //     debugPrint("✅ Cache directory created: ${mapPath.value}");
  //     return false; // Cache was empty before, so return false
  //   } else {
  //     debugPrint("✅ Cache directory found: ${mapPath.value}");
  //   }
  //
  //   for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
  //     Point<int>? minPoint = _latLngToTileCoordinates(center, zoom);
  //     Point<int>? maxPoint = _latLngToTileCoordinates(center, zoom);
  //
  //     if (minPoint == null || maxPoint == null) {
  //       debugPrint("⚠️ Skipping zoom $zoom due to invalid tile coordinates");
  //       continue;
  //     }
  //
  //     int minX = max(0, min(minPoint.x, maxPoint.x));
  //     int maxX = min((1 << zoom) - 1, max(minPoint.x, maxPoint.x));
  //     int minY = max(0, min(minPoint.y, maxPoint.y));
  //     int maxY = min((1 << zoom) - 1, max(minPoint.y, maxPoint.y));
  //
  //     for (int x = minX; x <= maxX; x++) {
  //       for (int y = minY; y <= maxY; y++) {
  //         String filePath = '${mapPath.value}/$zoom/$x/$y.png';
  //         File file = File(filePath);
  //
  //         if (!await file.exists()) {
  //           debugPrint("❌ Tile missing: $filePath");
  //           await downloadTileIfMissing(zoom, x, y);
  //           return false;
  //         } else {
  //           debugPrint("✅ Tile exists: $filePath");
  //         }
  //       }
  //     }
  //   }
  //
  //   debugPrint("🎉 All required tiles are cached.");
  //   return true;
  // }

  /// 🛠 Convert LatLng to tile coordinates
  Point<int>? _latLngToTileCoordinates(LatLng latLng, int zoom) {
    double latRad = latLng.latitude * (pi / 180);
    int n = 1 << zoom;
    int x = ((latLng.longitude + 180) / 360 * n).floor();
    int y = ((1 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2 * n).floor();
    return Point(x, y);
  }

  /// 🔽 **Download missing tile if not found**
  Future<void> downloadTileIfMissing(int zoom, int x, int y) async {
    String filePath = '${mapPath.value}/$zoom/$x/$y.png';
    File file = File(filePath);

    if (!await file.exists()) {
      debugPrint("⬇️ Downloading tile: $filePath");

      // Ensure directory exists
      Directory dir = file.parent;
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        debugPrint("📂 Created directory: ${dir.path}");
      }

      try {
        final response = await http.get(Uri.parse(
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$zoom/$y/$x'));

        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          debugPrint("✅ Tile saved: $filePath");
        } else {
          debugPrint("❌ Failed to download tile: HTTP ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("⚠️ Error downloading tile: $e");
      }
    } else {
      debugPrint("✅ Tile already exists: $filePath");
    }
  }


  /// OLD FUNCTION

  // Future<void> cacheMapTiles(LatLng center, double radiusInMeters) async {
  //   try {
  //
  //     // Define zoom levels for 100km radius
  //     int minZoom = 8;  // For overview
  //     int maxZoom = 15; // Detailed enough for most use cases
  //
  //     final geodesy = Geodesy();
  //     List<LatLng> boundingBox = geodesy.calculateBoundingBox(center, radiusInMeters);
  //
  //     // Calculate tile coordinates for the bounding box
  //     for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
  //       try {
  //         // Convert LatLng to tile coordinates with bounds checking
  //         var minPoint = _latLngToTileCoordinates(boundingBox[0], zoom);
  //         var maxPoint = _latLngToTileCoordinates(boundingBox[1], zoom);
  //
  //         if (minPoint == null || maxPoint == null) continue;
  //
  //         // Ensure correct order of coordinates and apply bounds
  //         int minX = max(0, min(minPoint.x, maxPoint.x));
  //         int maxX = min((1 << zoom) - 1, max(minPoint.x, maxPoint.x));
  //         int minY = max(0, min(minPoint.y, maxPoint.y));
  //         int maxY = min((1 << zoom) - 1, max(minPoint.y, maxPoint.y));
  //
  //         // Limit the number of tiles per zoom level to prevent excessive caching
  //         int maxTilesPerZoom = 100;
  //         if ((maxX - minX + 1) * (maxY - minY + 1) > maxTilesPerZoom) {
  //           debugPrint("Too many tiles at zoom level $zoom, skipping...");
  //           continue;
  //         }
  //
  //         // Cache tiles within the bounding box
  //         for (int x = minX; x <= maxX; x++) {
  //           for (int y = minY; y <= maxY; y++) {
  //             try {
  //               // Construct the URL manually
  //               final url = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$zoom/$y/$x';
  //
  //               print("Here url:::>>>>>>>>$url");
  //               // Use NetworkImage to cache the tile
  //               final NetworkImage image = NetworkImage(url);
  //
  //               // Precache the image
  //               await precacheImage(image, Get.context!);
  //
  //               debugPrint("Cached Tile: Zoom: $zoom, X: $x, Y: $y");
  //             } catch (e) {
  //               debugPrint("Error caching individual tile: $e");
  //               continue;
  //             }
  //           }
  //         }
  //       } catch (e) {
  //         debugPrint("Error processing zoom level $zoom: $e");
  //         continue;
  //       }
  //     }
  //
  //     debugPrint("Map caching completed successfully");
  //   } catch (e) {
  //     debugPrint("Error in cacheMapTiles: $e");
  //   }
  // }

  // Point<int>? _latLngToTileCoordinates(LatLng point, int zoom) {
  //   try {
  //     double lat = point.latitude.clamp(-85.05112878, 85.05112878);
  //     double lon = point.longitude.clamp(-180, 180);
  //
  //     int x = ((lon + 180.0) / 360.0 * pow(2.0, zoom)).floor();
  //
  //     double latRad = lat * pi / 180.0;
  //     int y = ((1.0 - log(tan(latRad) + 1 / cos(latRad)) / pi) / 2.0 * pow(2.0, zoom)).floor();
  //
  //     // Check for valid tile coordinates
  //     if (x.isFinite && y.isFinite &&
  //         x >= 0 && x < (1 << zoom) &&
  //         y >= 0 && y < (1 << zoom)) {
  //       return Point(x, y);
  //     }
  //     return null;
  //   } catch (e) {
  //     debugPrint("Error converting coordinates: $e");
  //     return null;
  //   }
  // }

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
    drawnPolygons.clear();
    isDrawingRectangle.value = false;
    shapePoints.clear();
    isDrawPolygon.value = false;
    linePoints.clear();
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
      } else {}
    } catch (e) {
      print('Exception Occurred: $e');
    }
  }

  List<LatLng> parseWKTToLatLng(String wkt) {
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
        searchResult.value = data;
        if (searchResult.containsKey("registered")) {
          if (!searchResult['registered']) {
            saveButtonEABLE.value = true;
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
        saveButtonEABLE.value = false;
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
    String? apiKey = await SharedPreference.instance.getSecretKeyLocalDb('api_key');
    String? clientSecret = await SharedPreference.instance.getSecretKeyLocalDb('client_secret');

    final headers = {
      'API-KEYS-AUTHENTICATION': '1',
      // 'API-KEY': apiKey ?? '',
      // 'CLIENT-SECRET': clientSecret ?? '',
      'AUTOMATED-FIELD': '0',
    };
    String wkt = convertPolygonToWKT(drawnPolygons);
    print("here is the Wkt:::: ${wkt}");
    String? s2Index = s2IndexController.text.isNotEmpty ? s2IndexController.text : null;
    String? threshold = thresholdController.text.isNotEmpty ? thresholdController.text : null;
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
      print("here is the Response Data:::>>> ${response.body}");
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
      }
      else {
        print("here is the Response Data:::>>> ${response.body}");
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


  savePolygonToDb() async {
    isPolygonLoading.value = true;
    String wkt = convertPolygonToWKT(drawnPolygons);
    String deviceID = await getDeviceId();
    String email=await HelperFunctions.getFromPreference("userEmail")??"";
    String number=await HelperFunctions.getFromPreference("phoneNumber")??"";
    dbHelper.insertPolygonData(polygons:wkt,phone: number,email: email, deviceID:deviceID, );
    showSnackBar(title: "Success",message: "Field save successfully",color: AppColor.green);
    isPolygonLoading.value = false;
  }


  /// get device id
  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android device ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!; // iOS device ID
    } else {
      return "Unknown Device";
    }
  }

  /// convert polygon to wkt
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
