import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:terrapipe/local_db_helper/shared_preference.dart';
import 'package:terrapipe/utilts/helper_functions.dart';
import 'package:terrapipe/views/saved_fields/components/save_field_map.dart';
import 'package:terrapipe/widgets/dialogs/session_out_dialog.dart';

import '../../widgets/dialogs/score_dialog.dart';

class SavedFieldController extends GetxController {
  late final MapController mapController;
  RxList<Polygon> drawnPolygons = <Polygon>[].obs;

  // List<MapController> ListMapController = [];
  final Dio dio = Dio();
  var fieldList = <List<String>>[].obs;
  List<LatLngBounds> boundsList = [];
  RxBool isFetchFieldLoading = false.obs;
  var polygons = <Polygon>[].obs;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
  }

  List<MapController> mapControllers =
      []; // Declare the list of map controllers

  void initializeBoundsList(int length) {
    while (boundsList.length < length) {
      boundsList.add(LatLngBounds(
          LatLng(0, 0), LatLng(0, 0))); // Initialize with a default value
    }
  }

  /// Initialize the domain list
  Future<void> fetchGeoId() async {
    const url = 'https://be.terrapipe.io/geo-id';
    String? piplineToken = await SharedPreference.instance.getPiplineToken();
    var headers = {
      'Authorization': 'Bearer $piplineToken',
    };
    var dio = Dio();
    try {
      var response = await dio.get(
        url,
        options: Options(
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        var jsonData = response.data;
        if (response.data['message'] != "Expired Token") {
          if (jsonData['geo_ids'] is List) {
            fieldList.value = (jsonData['geo_ids'] as List)
                .map((e) => List<String>.from(e))
                .toList();
            initializeBoundsList(fieldList.length);

            for (int index = 0; index < fieldList.length; index++) {
              await fetchFieldShapeByGeoId(fieldList[index].first, index);
            }
            isFetchFieldLoading.value = false;
            update();
          } else {
            isFetchFieldLoading.value = false;
            update();
          }
        } else {
          Get.dialog(SessionExpireDialog(), barrierDismissible: false);
        }
      } else {
        isFetchFieldLoading.value = false;
        update();
      }
    } catch (e) {
      isFetchFieldLoading.value = false;
      update();
      print('Exception Occurred: $e');
    }
  }

  Future<void> fetchFieldShapeByGeoId(String geoId, int index) async {
    final url = 'https://be.terrapipe.io/fetch-field/$geoId';
    String? piplineToken = await SharedPreference.instance.getPiplineToken();
    var headers = {
      'Authorization': 'Bearer $piplineToken',
    };
    var dio = Dio();

    try {
      var response = await dio.get(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var jsonData = response.data;
        var geoJson = jsonData['JSON Response']?['Geo JSON'];
        if (geoJson != null && geoJson['geometry'] != null) {
          final geometry = geoJson['geometry'];
          if (geometry['type'] == 'Polygon') {
            final coordinates = geometry['coordinates'];
            List<LatLng> points = parseCoordinatesToLatLng(coordinates);
            if (points.isNotEmpty) {
              // Add the polygon to the map
              polygons.add(Polygon(
                points: points,
                borderColor: Colors.blue,
                borderStrokeWidth: 2.0,
                color: Colors.blue.withOpacity(0.3),
              ));

              // Calculate bounds
              LatLngBounds bounds = await calculateBounds(points);
              boundsList[index] = bounds;
            }
          }
        }
      } else {
        print('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      print('Exception Occurred: $e');
    } finally {
      loading.value = false;
      update();
    }
  }

  RxBool loading = false.obs;
  var fieldData = {}.obs;

  Future<void> fetchFieldByGeoId(String geoId) async {
    loading.value = true;
    update();
    final url = 'https://be.terrapipe.io/fetch-field/$geoId';
    String? piplineToken = await SharedPreference.instance.getPiplineToken();
    var headers = {
      'Authorization': 'Bearer $piplineToken',
    };
    var dio = Dio();

    try {
      var response = await dio.get(
        url,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var jsonData = response.data;
        // log('Response Data: $jsonData');
        fieldData.value = jsonData;
        log('fieldData.value ${fieldData}');
        var geoJson = jsonData['JSON Response']?['Geo JSON'];
        if (geoJson != null && geoJson['geometry'] != null) {
          final geometry = geoJson['geometry'];
          if (geometry['type'] == 'Polygon') {
            final coordinates = geometry['coordinates'];
            List<LatLng> points = parseCoordinatesToLatLng(coordinates);
            if (points.isNotEmpty) {
              showSnackBar(
                color: Colors.green,
                title: "Success",
                message: "Field Map Opened successfully",
              );
              Get.to(() => const SaveFieldMap(), arguments: {
                'geoId': geoId,
                'polygonPoints': points,
              });
              loading.value = false;
              update();
            } else {
              loading.value = false;
              update();
              print('Error: No valid points found in the Geo JSON');
            }
          } else {
            loading.value = false;
            update();
            print('Error: Expected Polygon type, but got ${geometry['type']}');
          }
        } else {
          loading.value = false;
          update();
          print('Error: Geo JSON or geometry is missing');
        }
      } else {
        loading.value = false;
        update();
      }
    } catch (e) {
      loading.value = false;
      update();
      print('Exception Occurred: $e');
    } finally {
      update();
    }
  }

  List<LatLng> parseCoordinatesToLatLng(dynamic coordinates) {
    List<LatLng> points = [];
    // Assuming the coordinates are in the format [[[lng, lat], [lng, lat], ...]]
    if (coordinates is List && coordinates.isNotEmpty) {
      final polygonCoordinates = coordinates[0];
      for (var point in polygonCoordinates) {
        if (point is List && point.length == 2) {
          final lng = point[0];
          final lat = point[1];
          points.add(LatLng(lat, lng));
        }
      }
    }
    return points;
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

  /// Calculate LatLngBounds from a list of LatLng points
  LatLngBounds calculateBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

    for (var point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      LatLng(south, west), // southwest corner
      LatLng(north, east), // northeast corner
    );
  }

  MapOptions getMapOptions(int index) {
    // Check if boundsList has the correct index
    if (boundsList.isNotEmpty && boundsList.length > index) {
      LatLngBounds bounds = boundsList[index];

      // Calculate center and zoom based on the bounds
      LatLng center = bounds.center;
      double zoom =
          16.0; // Default zoom level, you can adjust this based on your needs

      // Optionally, you can calculate the zoom level dynamically based on the bounds
      // For example, use an algorithm to fit the map to the bounds

      return MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        interactiveFlags:
            InteractiveFlag.none, // or adjust based on your requirement
      );
    } else {
      // Default MapOptions in case boundsList doesn't have the required index
      return const MapOptions(
        initialCenter: LatLng(51.5, -0.09), // Example coordinates
        initialZoom: 14.0,
        interactiveFlags: InteractiveFlag.none,
      );
    }
  }

// Dio instance for making API calls

  /// Fetch the Wisp TMF Deforestation Score
  Future<double?> fetchWispTmfDeforestationScore(Map<String, dynamic> geojson) async {
    String? piplineToken = await SharedPreference.instance.getPiplineToken();
    var headers = {
      'Authorization': 'Bearer $piplineToken',
    };
    try {
      var data = json.encode({
        "geojson":geojson['Geo JSON']
      });
      var dio = Dio();
      var response = await dio.request(
        'https://be.terrapipe.io/fetch-whisp-tmf-deforestation-score',
        options: Options(
          method: 'POST',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return data['data']['tmf_deforestation_score'] is double ? data['data']['tmf_deforestation_score'] : double.tryParse(data['data']['tmf_deforestation_score'].toString());
        } else {
          print("Error: Invalid response structure. 'score' not found.");
          return 0;
        }
      } else {
        print("Error: ${response.statusMessage}");
        return 0;
      }
    } catch (e) {
      print("Exception: $e");
      return 0;
    }
  }

  /// Fetch the Terra pipe TMF Deforestation Score
  Future<double?> fetchTerraPipeTmfDeforestationScore(String geoid) async {
    try {
      String? pipelineToken = await SharedPreference.instance.getPiplineToken();
      if (pipelineToken == null || pipelineToken.isEmpty) {
        return 0.0;
      }

      // Define headers
      var headers = {
        'Authorization': 'Bearer $pipelineToken',
      };
      var dio = Dio();
      var response = await dio.request(
        'https://be.terrapipe.io/fetch-tmf-deforestation-score?geoid=${geoid}',
        options: Options(
          method: 'GET',
          headers: headers,
        ),
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['data'] != null) {
          return data['data']['tmf_deforestation_score'] is double ? data['data']['tmf_deforestation_score'] : double.tryParse(data['data']['tmf_deforestation_score'].toString());
        } else {
          print("Error: Invalid response structure. 'score' not found.");
          return 0.0;
        }
      } else {
        print("Error: ${response.statusMessage} (${response.statusCode})");
        return 0.0;
      }
    } catch (e) {
      // Catch and log exceptions
      print("Exception fetchTerraPipeTmfDeforestationScore: $e");
      return 0.0;
    }
  }

  RxBool gettingDetail=false.obs;
  RxString terraPipeTMFScore="0.0".obs;
  RxString wispTMFScore="0.0".obs;
  /// Main function to handle API calls and navigate to the new page
  Future<void> handleAccessData() async {
    gettingDetail.value=true;
    update();
    final terraPipeScore = await fetchTerraPipeTmfDeforestationScore(fieldData['JSON Response']['GEO Id']);
    final wispScore = await fetchWispTmfDeforestationScore(fieldData['JSON Response']);
    gettingDetail.value=false;
    update();
    if (wispScore != null || terraPipeScore != null) {
      terraPipeTMFScore.value="${terraPipeScore}";
      wispTMFScore.value="${wispScore}";
      update();
      Get.dialog(ScoreDialog());

    } else {
      print("Failed to fetch scores.");
    }
  }
}
