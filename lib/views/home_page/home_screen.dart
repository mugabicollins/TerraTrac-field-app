import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/views/home_page/walk_traking/walk_tracking_view.dart';
import 'package:terrapipe/widgets/bounce_loader.dart';
import 'package:terrapipe/widgets/custom_text_field.dart';
import 'components/polygon_bottom_sheet.dart';
import 'components/search_bottom_sheet.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());


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
        inAsyncCall: controller.searchLoading.isTrue ||  controller.isPolygonLoading.isTrue,
        opacity: 0.9,
        color: AppColor.white,
        progressIndicator: BounceAbleLoader(
          title: controller.isPolygonLoading.isTrue?"Registering Field":controller.isFieldSaveLoading.value?"Saving Field":"Fetching Details",
          textColor: AppColor.black,
          loadingColor: AppColor.black,
        ),
        child: Scaffold(
          extendBody: false,
          extendBodyBehindAppBar: false,
          resizeToAvoidBottomInset: false,
          body: controller.locationFetched.isTrue
              ? SafeArea(
                  bottom: true,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
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

                                    bool isInsidePolygon = false;

                                    if (isInsidePolygon) {

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
                          /// search field
                          Positioned(
                            top: Get.height * 0.015,
                            left: Get.width * 0.025,
                            right: Get.width * 0.025,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 55,
                                    child: CustomTextFormField(
                                      controller: controller.searchController,
                                      hintText: "Search by Geo IDs",
                                      fillColor: AppColor.white,
                                      cursorColor: AppColor.black45,
                                      onSubmitted: (val) async {
                                        await controller.searchFieldByGeoId(controller
                                            .searchController.text
                                            .trim());
                                      },
                                      onChanged: (val) async {
                                      },
                                      suffixIconWidget: IconButton(
                                          onPressed: () async {
                                            if (controller.searchEnable.value) {
                                              controller.searchController.clear();
                                              controller.drawnPolygons.clear();
                                              controller.searchEnable.value=false;
                                              loadLocation();
                                              setState(() {});
                                            }else{
                                              FocusScope.of(context).unfocus();
                                              await controller.searchFieldByGeoId(controller
                                                  .searchController.text
                                                  .trim());
                                            }
                                          },
                                          icon: Icon(controller.searchEnable.isFalse
                                              ? Icons.search
                                              : Icons.cancel_outlined)),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: Get.width * 0.02,
                                ),
                                InkWell(
                                  onTap: () {
                                    Get.bottomSheet(
                                      backgroundColor: AppColor.white,
                                      const SearchBottomSheet(),
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: AppColor.white,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: const Center(
                                      child: Icon(
                                        Icons.menu,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          if(controller.saveButtonEABLE.value)
                            Positioned(
                              left: Get.width*0.2,
                              right: Get.width*0.2,
                              bottom: Get.height*0.24,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  print("tAP BUTTON ${controller.searchResult['JSON Response']['GEO Id']}");
                                  await controller.saveFieldByGeoIdTerraPipe(controller.searchResult['JSON Response']['GEO Id']);
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: AppColor.white,
                                ),
                                label: Text("Save Field",
                                    style:
                                    TextStyle(color: AppColor.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor),
                              ),
                            ),
                          if (controller.isMarkPostion.value)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: Get.height*0.25,
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
                              bottom: Get.height*0.25,
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
                              bottom: Get.height*0.23,
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
                              bottom: Get.height*0.25,
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
                          /// side menu button is here
                          Positioned(
                            bottom: Get.height*0.25,
                            right: 10,
                            child:controller.enableSideMenu.value?Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.linear_scale_rounded, color: Colors.white),
                                  label: const Text("Walk&Track", style: TextStyle(fontSize: 14, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
                                    Get.to(() =>  WalkTrackingPage());
                                  },
                                ),
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.map, color: AppColor.white),
                                  label: Text("Mark Position", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () async {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
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
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.linear_scale_rounded, color: AppColor.white),
                                  label: Text("Line", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
                                    controller.isDrawingLine.value = true;
                                    controller.animationController.reverse();
                                  },
                                ),
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.polyline, color: AppColor.white),
                                  label: Text("Polygon", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
                                    controller.startDrawing();
                                    controller.isDrawingRectangle.value = false;
                                    controller.isDrawingCircle.value = false;
                                    controller.rectangleStart = null;
                                    controller.rectangleEnd = null;
                                    controller.shapePoints.clear();
                                    controller.circleCenter = null;
                                    controller.animationController.reverse();
                                  },
                                ),
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.circle_outlined, color: AppColor.white),
                                  label: Text("Circle", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.green,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      controller.enableSideMenu.value=false;
                                      controller.update();
                                      controller.isDrawPolygon.value = false;
                                      controller.isDrawingRectangle.value = false;
                                      controller.isDrawingCircle.value = true;
                                      controller.rectangleStart = null;
                                      controller.rectangleEnd = null;
                                      controller.shapePoints.clear();
                                      controller.circleCenter = null;
                                    });
                                    controller.animationController.reverse();
                                  },
                                ),
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.rectangle_outlined, color: AppColor.white),
                                  label: Text("Rectangle", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.orange,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
                                    controller.isDrawingRectangle.value = true;
                                    controller.rectangleStart = null;
                                    controller.rectangleEnd = null;
                                    controller.isDrawPolygon.value = false;
                                    controller.isDrawingCircle.value = false;
                                    controller.shapePoints.clear();
                                    controller.circleCenter = null;
                                    controller.animationController.reverse();
                                  },
                                ),
                                SizedBox(height: Get.height*0.01,),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.delete_outline, color: AppColor.white),
                                  label: Text("Delete", style: TextStyle(fontSize: 14, color: AppColor.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.red,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                  ),
                                  onPressed: () {
                                    controller.enableSideMenu.value=false;
                                    controller.update();
                                    controller.clearShapes();
                                    controller.animationController.reverse();
                                  },
                                ),
                              ],
                            ):const SizedBox(),
                          )
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
