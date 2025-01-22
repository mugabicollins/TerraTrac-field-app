import 'dart:async';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/utilts/helper_functions.dart';
import 'package:terrapipe/views/home_page/home_controller.dart';
import 'package:terrapipe/widgets/bounce_loader.dart';
import '../../../utilities/app_text_style.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../home_page/components/polygon_bottom_sheet.dart';

class WalkTrackingPage extends StatefulWidget {
  const WalkTrackingPage({super.key});

  @override
  State<WalkTrackingPage> createState() => _WalkTrackingPageState();
}

class _WalkTrackingPageState extends State<WalkTrackingPage> {
  List<Marker> markers = [];
  LatLng? currentPosition;
  bool isTracking = false;
  bool isAddPointVisible = false;
  MapController mapController = MapController();
  final HomeController homeController = Get.put(HomeController());

  // final HomeController assetRegistryController = Get.put(HomeController());
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
        homeController.shapePoints.add(currentPosition!);
        markers.add(createMarker(currentPosition!));
      });
    }
  }

  /// Undo the last point
  void undoPoint() {
    if (homeController.shapePoints.isNotEmpty && markers.isNotEmpty) {
      setState(() {
        homeController.shapePoints.removeLast();
        markers.removeLast();
      });
    }
  }

  /// Save the points and draw the polygon
  void savePolygon() {
    setState(() {
      if (homeController.shapePoints.length >= 3) {
        homeController.shapePoints.value =
            List.from(homeController.shapePoints);
        print("here is the polypoint ${homeController.shapePoints}");
        Get.bottomSheet(
            backgroundColor: AppColor.white,
            isScrollControlled: true,
            Container(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  // spacing: 10,
                  children: [
                    const Center(
                      child: Text("Field Actions",
                          style: AppTextStyles.labelLarge),
                    ),
                    SizedBox(
                      height: Get.height * 0.03,
                    ),
                    const Text(
                      "Resolution level (optional):",
                      style: AppTextStyles.labelMedium,
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    CustomTextFormField(
                      controller: homeController.resolutionLevelController,
                      hintText: "level",
                      fillColor: Colors.white,
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    const Text(
                      "threshold (optional):",
                      style: AppTextStyles.labelMedium,
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    CustomTextFormField(
                      controller: homeController.thresholdController,
                      hintText: "threshold",
                      fillColor: Colors.white,
                      suffixIconWidget: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        // spacing: 0,
                        children: [
                          GestureDetector(
                            onTap: homeController.incrementValue,
                            child: const Icon(
                              Icons.arrow_drop_up,
                              size: 20,
                            ),
                          ),
                          GestureDetector(
                            onTap: homeController.decrementValue,
                            child: const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    const Text(
                      "Domain (optional):",
                      style: AppTextStyles.labelMedium,
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    CustomDropdown<String>(
                      hintText: 'Select Domain',
                      items: homeController.domainList,
                      initialItem: homeController.domainList[0],
                      decoration: CustomDropdownDecoration(
                          closedBorder: Border.all(
                            color: Colors.black,
                          ),
                          expandedBorder: Border.all(
                            color: Colors.black38,
                          )),
                      disabledDecoration: CustomDropdownDisabledDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {},
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    const Text(
                      "Boundary Type:",
                      style: AppTextStyles.labelMedium,
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    CustomDropdown<String>(
                      hintText: 'Select Boundary Type',
                      items: homeController.boundaryTypeList,
                      initialItem: homeController.boundaryTypeList[0],
                      decoration: CustomDropdownDecoration(
                          closedBorder: Border.all(
                            color: Colors.black,
                          ),
                          expandedBorder: Border.all(
                            color: Colors.black38,
                          )),
                      disabledDecoration: CustomDropdownDisabledDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        // log('changing value to: $value');
                      },
                    ),
                    SizedBox(
                      height: Get.height * 0.02,
                    ),
                    const Text(
                      "S2_index (optional):",
                      style: AppTextStyles.labelMedium,
                    ),
                    SizedBox(
                      height: Get.height * 0.01,
                    ),
                    CustomTextFormField(
                      controller: homeController.s2IndexController,
                      hintText: "S2_index",
                      fillColor: Colors.white,
                    ),
                    SizedBox(
                      height: Get.height * 0.05,
                    ),
                    Row(
                      // spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CustomButton(
                          label: 'Cancel',
                          width: Get.width / 2.5,
                          height: 45,
                          onTap: () {
                            Get.back();
                          },
                          color: AppColor.white,
                          borderColor: AppColor.primaryColor,
                          textStyle: const TextStyle(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.bold),
                          textColor: AppColor.primaryColor,
                        ),
                        CustomButton(
                          label: 'Register Field',
                          height: 45,
                          width: Get.width / 2.5,
                          borderColor: AppColor.primaryColor,
                          onTap: () async {
                            Get.back();
                            await homeController.savePolygonTeraTrac();
                          },
                          textStyle: TextStyle(
                              color: AppColor.white,
                              fontWeight: FontWeight.w700),
                          color: AppColor.primaryColor,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )); // Draw the line connecting points
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
      homeController.shapePoints.clear();
      // polylinePoints.clear();
      markers.clear();
    });

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
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
      isAddPointVisible = false;
      positionStream?.cancel();
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    homeController.shapePoints.clear();
    markers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: const Text(
          "Walk Tracking",
          style: TextStyle(
              color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: AppColor.white,
      ),
      body: ModalProgressHUD(
        inAsyncCall: homeController.isPolygonLoading.isTrue,
        color: Colors.white,
        opacity: 0.95,
        progressIndicator: BounceAbleLoader(
          loadingColor: Colors.black,
          textColor: Colors.black,
          title: "Saving Details",
        ),
        child: Stack(
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
                Obx(
                  () => PolygonLayer(
                    polygons: [
                      if (homeController.shapePoints.isNotEmpty)
                        Polygon(
                          points: [
                            ...homeController.shapePoints,
                            homeController.shapePoints[0]
                          ],
                          borderColor: homeController.selectedColor,
                          borderStrokeWidth: 2.0,
                          isDotted: false,
                          color: homeController.selectedColor.withOpacity(0.3),
                          isFilled: false,
                        ),
                    ],
                  ),
                ),
                MarkerLayer(markers: markers),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              top: Get.height * 0.03,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  /// Undo Button
                  if (isAddPointVisible)
                    ElevatedButton.icon(
                      onPressed: undoPoint,
                      icon:  Icon(
                        Icons.undo,
                        size: 18,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.red),
                      label: const Text(
                        "Undo",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),

                  /// Add Point Button (Visible only when tracking is started)
                  if (isAddPointVisible)
                    ElevatedButton.icon(
                      onPressed: addPoint,
                      icon: Icon(
                        Icons.location_on,
                        color: AppColor.white,
                      ),
                      label: Text("Mark Point",
                          style: TextStyle(color: AppColor.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.green),
                    ),
                  // Save Button (to save the points as polygon)
                  if (isAddPointVisible)
                    ElevatedButton.icon(
                      onPressed: () {
                        homeController.finishShape(context);
                        homeController.shapePoints.length >= 3
                            ? Get.bottomSheet(
                                backgroundColor: AppColor.white,
                                isScrollControlled: true,
                                PolygonBottomSheet(),
                              )
                            : const SizedBox();
                      },
                      icon: Icon(
                        Icons.save,
                        color: AppColor.white,
                      ),
                      label:
                          Text("Save", style: TextStyle(color: AppColor.white)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.green),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  /// Start/Stop Button
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

                  /// Button to navigate to current location
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
      ),
    );
  }
}
