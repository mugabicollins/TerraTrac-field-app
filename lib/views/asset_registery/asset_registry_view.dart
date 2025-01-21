import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:terrapipe/views/asset_registery/walk_traking/walk_tracking_view.dart';
import 'package:terrapipe/widgets/bounce_loader.dart';
import 'package:terrapipe/widgets/custom_button.dart';
import '../home_page/components/polygon_bottom_sheet.dart';
import 'asset_registery_controller.dart';

class AssetRegistryView extends StatefulWidget {
  const AssetRegistryView({super.key});

  @override
  State<AssetRegistryView> createState() => _AssetRegistryViewState();
}

class _AssetRegistryViewState extends State<AssetRegistryView> with SingleTickerProviderStateMixin {
  final AssetRegistryController controller = Get.put(AssetRegistryController());
  bool isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {

    int n = polygonPoints.length;
    bool isInside = false;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      if ((polygonPoints[i].latitude > point.latitude) !=
              (polygonPoints[j].latitude > point.latitude) &&
          (point.longitude <
              (polygonPoints[j].longitude - polygonPoints[i].longitude) *
                      (point.latitude - polygonPoints[i].latitude) /
                      (polygonPoints[j].latitude - polygonPoints[i].latitude) +
                  polygonPoints[i].longitude)) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  @override
  void initState() {
    super.initState();
    loadLocation();
    controller.animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    final curvedAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: controller.animationController,
    );
    controller.animation =
        Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  Future<void> loadLocation() async {
    await controller.getLocation();
  }


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: controller.isPolygonLoading.value,
        opacity: 0.9,
        color: AppColor.white,
        progressIndicator: BounceAbleLoader(
          title: "Adding the Polygon",
          loadingColor: AppColor.black,
          textColor: AppColor.black,
        ),
        child: Scaffold(
          extendBody: false,
          extendBodyBehindAppBar: false,
          resizeToAvoidBottomInset: false,
          floatingActionButton: controller.isDrawPolygon.value ||
                  controller.isDrawingRectangle.value ||
                  controller.isDrawingCircle.value ||
                  controller.isMarkPostion.value
              ? const SizedBox()
              : FloatingActionBubble(
                  // Assign a unique hero tag
                  items: [
                    Bubble(
                      title: "Walk&Track",
                      iconColor: Colors.white,
                      bubbleColor: Colors.blue,
                      icon: Icons.linear_scale_rounded,
                      titleStyle:
                          const TextStyle(fontSize: 14, color: Colors.white),
                      onPress: () {
                        Get.to(() =>
                            const WalkTrackingPage()); // Close the menu after selecting the bubble
                      },
                    ),
                    Bubble(
                      title: "Mark Position",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.blue,
                      icon: Icons.map,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () async {
                        controller.isMarkPostion.value = true;
                        controller.isDrawingRectangle.value = false;
                        controller.isDrawingCircle.value = false;
                        controller.rectangleStart = null;
                        controller.rectangleEnd = null;
                        controller.shapePoints.clear();
                        controller.circleCenter = null;
                        controller.animationController.reverse();
                      },
                    ),
                    Bubble(
                      title: "Line",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.blue,
                      icon: Icons.linear_scale_rounded,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () {
                        controller.isDrawingLine.value = true;
                        controller.animationController
                            .reverse(); // Close the menu after selecting the bubble
                      },
                    ),
                    Bubble(
                      title: "Polygon",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.blue,
                      icon: Icons.polyline,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () {
                        controller.startDrawing();
                        controller.isDrawingRectangle.value = false;
                        controller.isDrawingCircle.value = false;
                        controller.rectangleStart = null;
                        controller.rectangleEnd = null;
                        controller.shapePoints.clear();
                        controller.circleCenter = null;
                        controller.animationController
                            .reverse(); // Close the menu after selecting the bubble
                      },
                    ),
                    Bubble(
                      title: "Circle",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.green,
                      icon: Icons.circle_outlined,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () {
                        setState(() {
                          controller.isDrawPolygon.value = false;
                          controller.isDrawingRectangle.value = false;
                          controller.isDrawingCircle.value = true;
                          controller.rectangleStart = null;
                          controller.rectangleEnd = null;
                          controller.shapePoints.clear();
                          controller.circleCenter = null;
                        });
                        controller.animationController
                            .reverse(); // Close the menu after selecting the bubble
                      },
                    ),
                    Bubble(
                      title: "Rectangle",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.orange,
                      icon: Icons.rectangle_outlined,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () {
                        controller.isDrawingRectangle.value =
                            true; // Start drawing rectangle
                        controller.rectangleStart = null;
                        controller.rectangleEnd = null;
                        controller.isDrawPolygon.value = false;
                        controller.isDrawingCircle.value = false;
                        controller.shapePoints.clear();
                        controller.circleCenter = null;
                        controller.isDrawPolygon.value = false;
                        controller.shapePoints.clear();
                        controller.animationController.reverse();
                      },
                    ),
                    /// delete
                    Bubble(
                      title: "Delete",
                      iconColor: AppColor.white,
                      bubbleColor: AppColor.red,
                      icon: Icons.delete_outline,
                      titleStyle:
                          TextStyle(fontSize: 14, color: AppColor.white),
                      onPress: () {
                        controller.clearShapes();
                        controller.animationController.reverse();
                      },
                    ),
                  ],
                  animation: controller.animation,
                  onPress: () {
                    if (controller.animationController.isCompleted) {
                      controller.animationController.reverse();
                    } else {
                      controller.animationController.forward();
                    }
                  },
                  iconData: Icons.add,
                  iconColor: AppColor.blue,
                  backGroundColor: AppColor.white,
                ),
          body: controller.locationFetched.isTrue
              ? SafeArea(
                  bottom: true,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Obx(
                            () => FlutterMap(
                              mapController: controller.mapController,
                              options: MapOptions(
                                  center: controller.cameraPosition.value ??
                                      const LatLng(51.5, -0.09),
                                  onPositionChanged:
                                      (MapPosition position, bool hasGesture) {
                                    setState(
                                        () {}); // Force a rebuild to reflect polygon changes
                                  },
                                  initialZoom: 17.0,
                                  onTap: (_, LatLng point) {
                                    FocusScope.of(context).unfocus();

                                    // Check if the tap is inside any of the polygons
                                    bool isInsidePolygon = false;

                                    for (var polygon in controller.drawnPolygons) {
                                      if (isPointInPolygon(point, polygon.points)) {
                                        isInsidePolygon = true;
                                        break;
                                      }
                                    }

                                    if (isInsidePolygon) {
                                      // Handle tap inside polygon

                                    } else {
                                      // Handle tap outside polygons
                                      if (controller.isDrawingCircle.value) {
                                        setState(() {
                                          controller.circleCenter = point;
                                        });
                                      } else if (controller.isDrawingRectangle.value)
                                      {
                                        setState(() {
                                          if (controller.rectangleStart ==
                                              null) {
                                            controller.rectangleStart = point;
                                          } else {
                                            // Second point clicked
                                            controller.rectangleEnd = point;
                                            controller
                                                    .isDrawingRectangle.value =
                                                false; // Stop drawing after two points
                                          }
                                        });
                                      } else if (controller.isDrawingLine.value) {
                                        controller.linePoints.add(point);
                                        controller.shapePoints.add(point);
                                      } else if (controller.isMarkPostion.value) {
                                        controller.markPostionLatLng(point);
                                      } else {
                                        controller.addPointToShape(point);
                                      }
                                      print("Tap outside polygon");
                                    }
                                  }),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                  subdomains: ['a', 'b', 'c'],
                                  errorTileCallback: (tile, error, stackTrace) {
                                    print(
                                        "Tile loading failed for ${tile.coordinates}: $error");
                                  },
                                ),

                                /// polygon
                                Obx(
                                  () => PolygonLayer(
                                    polygons: [
                                      ...controller.drawnPolygons,
                                      if (controller.isDrawPolygon.value && controller.shapePoints.isNotEmpty)
                                        Polygon(
                                          points: [
                                            ...controller.shapePoints,
                                            controller.shapePoints[0]
                                          ],
                                          borderColor: controller.selectedColor,
                                          borderStrokeWidth: 2.0,
                                          isDotted: true,
                                          color: controller.selectedColor
                                              .withOpacity(0.3),
                                          isFilled: true,
                                        ),
                                      if (controller.rectangleStart != null && controller.rectangleEnd != null)
                                        Polygon(
                                          points:
                                              controller.getRectangleCorners(),
                                          borderColor: AppColor.blue,
                                          borderStrokeWidth: 2.0,
                                          color: AppColor.blue.withOpacity(0.3),
                                          isFilled: true,
                                        ),
                                    ],
                                  ),
                                ),

                                ///circle
                                CircleLayer(
                                  circles: [
                                    if (controller.isDrawingCircle.value &&
                                        controller.circleCenter != null)
                                      CircleMarker(
                                        point: controller.circleCenter!,
                                        color: AppColor.blue.withOpacity(0.5),
                                        radius: controller.radius.value,
                                      ),
                                  ],
                                ),

                                /// marker
                                MarkerLayer(
                                  markers: controller.isMarkPostion.value
                                      ? controller.markPosition
                                          .map((point) => Marker(
                                                point: point,
                                                width: 20,
                                                height: 20,
                                                child: const Icon(Icons.circle,
                                                    color: AppColor.red,
                                                    size: 12),
                                              ))
                                          .toList()
                                      : controller.isDrawingCircle.value
                                          ? [
                                              if (controller
                                                      .isDrawingCircle.value &&
                                                  controller.circleCenter !=
                                                      null)
                                                Marker(
                                                  point:
                                                      controller.circleCenter!,
                                                  width: 30,
                                                  height: 30,
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    color: AppColor.red,
                                                    size: 30,
                                                  ),
                                                ),
                                            ]
                                          : controller.shapePoints
                                              .map((point) => Marker(
                                                    point: point,
                                                    width: 20,
                                                    height: 20,
                                                    child: const Icon(
                                                        Icons.circle,
                                                        color: AppColor.red,
                                                        size: 12),
                                                  ))
                                              .toList(),
                                ),

                                /// line
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: controller.linePoints,
                                      color: AppColor.green,
                                      strokeWidth: 3.0,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (controller.isMarkPostion.value)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: Get.height*0.03,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                // spacing: 5,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (controller.markPosition.isNotEmpty) {
                                          controller.markPosition.removeLast();
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.undo,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "Undo Last Point",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.clearShapes();
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: AppColor.white,
                                    ),
                                    label: Text(
                                      "Cancel",
                                      style: TextStyle(color: AppColor.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.red),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.finishShape(context);
                                    },
                                    icon: Icon(
                                      Icons.save,
                                      color: AppColor.white,
                                    ),
                                    label: Text("Save",
                                        style:
                                            TextStyle(color: AppColor.white)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.green),
                                  ),
                                ],
                              ),
                            ),
                          /// Options overlay
                          if (controller.isDrawPolygon.value)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: Get.height*0.03,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                // spacing: 5,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (controller.shapePoints.isNotEmpty) {
                                          controller.shapePoints.removeLast();
                                        }
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.undo,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "Undo Last Point",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.clearShapes();
                                    },
                                    icon: Icon(
                                      Icons.cancel,
                                      color: AppColor.white,
                                    ),
                                    label: Text(
                                      "Cancel",
                                      style: TextStyle(color: AppColor.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.red),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      controller.finishShape(context);
                                      controller.shapePoints.length >= 3
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
                                    label: Text("Save",
                                        style:
                                            TextStyle(color: AppColor.white)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColor.green),
                                  ),
                                ],
                              ),
                            ),
                          if (controller.isDrawingCircle.value)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: Get.height*0.0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Slider(
                                      value: controller.radius.value,
                                      min: 10.0,
                                      max: 500.0,
                                      activeColor: AppColor.primaryColor,
                                      onChanged: (val) {
                                        controller.onRadiusChanged(val);
                                      },
                                    ),
                                    Text(
                                      'Radius: ${controller.radius.toStringAsFixed(0)} m',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            controller.clearShapes();
                                          },
                                          icon: Icon(
                                            Icons.cancel,
                                            color: AppColor.white,
                                          ),
                                          label: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: AppColor.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColor.red),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            controller.finishShape(context);
                                          },
                                          icon: Icon(
                                            Icons.save,
                                            color: AppColor.white,
                                          ),
                                          label: Text("Save",
                                              style: TextStyle(
                                                  color: AppColor.white)),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColor.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Slider to adjust the rectangle size
                          if (controller.isDrawingRectangle.value &&
                              controller.rectangleStart != null)
                            Positioned(
                              left: 20,
                              right: 20,
                              top: Get.height*0.03,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Slider(
                                      value: controller.rectangleSize.value,
                                      min: 10.0,
                                      activeColor: AppColor.primaryColor,
                                      max: 500.0,
                                      // Adjust the range as necessary
                                      onChanged: (value) {
                                        setState(() {
                                          controller.rectangleSize.value =
                                              value;
                                          controller
                                              .updateRectangleSize(); // Update the rectangle based on the new size
                                        });
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            controller.clearShapes();
                                          },
                                          icon: Icon(
                                            Icons.cancel,
                                            color: AppColor.white,
                                          ),
                                          label: Text(
                                            "Cancel",
                                            style: TextStyle(
                                                color: AppColor.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColor.red),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            controller.finishShape(context);
                                          },
                                          icon: Icon(
                                            Icons.save,
                                            color: AppColor.white,
                                          ),
                                          label: Text("Save",
                                              style: TextStyle(
                                                  color: AppColor.white)),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColor.green),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
              : Center(
                  child: BounceAbleLoader(
                    title: "Fetching Location",
                    textColor: Colors.black,
                    loadingColor: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
