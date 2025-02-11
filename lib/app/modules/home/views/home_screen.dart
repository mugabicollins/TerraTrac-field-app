import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terrapipe/app/modules/home/components/polygon_bottom_sheet.dart';
import 'package:terrapipe/app/modules/home/components/search_bottom_sheet.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/widgets/loader/bounce_loader.dart';
import 'package:terrapipe/widgets/textfields/custom_text_field.dart';
import '../../../../widgets/customMap/custom_map_view.dart';
import '../controllers/home_controller.dart';
import 'walk_traking/walk_tracking_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());

  // String mapPath = "";

  Future<String> getPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    return cacheDirectory.path;
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
        inAsyncCall: controller.searchLoading.isTrue ||
            controller.isPolygonLoading.isTrue,
        opacity: 0.9,
        color: AppColor.white,
        progressIndicator: BounceAbleLoader(
          title: controller.isPolygonLoading.isTrue
              ? "Registering Field"
              : controller.isFieldSaveLoading.value
                  ? "Saving Field"
                  : "Fetching Details",
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
                          Obx(() => CustomFlutterMap(
                                mapController: controller.mapController,
                                polygons: [
                                  ...controller.drawnPolygons,
                                  if (controller.isDrawPolygon.value &&
                                      controller.shapePoints.isNotEmpty)
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
                                ],
                                // List of polygons
                                markers: controller.shapePoints,
                                mapOptions: MapOptions(
                                    center: controller.cameraPosition.value ??
                                        const LatLng(51.5, -0.09),
                                    onPositionChanged: (MapPosition position,
                                        bool hasGesture) {
                                      setState(
                                          () {}); // Force a rebuild to reflect polygon changes
                                    },
                                    initialZoom: 12.0,
                                    onTap: (_, LatLng point) {
                                      FocusScope.of(context).unfocus();
                                      controller.addPointToShape(point);
                                      setState(() {});
                                    }),
                                // List of markers (LatLng points)
                                markerColor: Colors.red,
                                mapPath: controller.mapPath.value,
                                // Custom marker color
                                onMapTap: (LatLng point) {
                                  controller.addPointToShape(
                                      point); // Add point when tapping the map
                                },
                              )),

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
                                        await controller.searchFieldByGeoId(
                                            controller.searchController.text
                                                .trim());
                                      },
                                      onChanged: (val) async {},
                                      suffixIconWidget: IconButton(
                                          onPressed: () async {
                                            if (controller.searchEnable.value) {
                                              controller.searchController
                                                  .clear();
                                              controller.drawnPolygons.clear();
                                              controller.searchEnable.value =
                                                  false;
                                              loadLocation();
                                              setState(() {});
                                            } else {
                                              FocusScope.of(context).unfocus();
                                              await controller
                                                  .searchFieldByGeoId(controller
                                                      .searchController.text
                                                      .trim());
                                            }
                                          },
                                          icon: Icon(
                                              controller.searchEnable.isFalse
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

                          if (controller.saveButtonEABLE.value)
                            Positioned(
                              left: Get.width * 0.2,
                              right: Get.width * 0.2,
                              bottom: Get.height * 0.24,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  print(
                                      "tAP BUTTON ${controller.searchResult['JSON Response']['GEO Id']}");
                                  await controller.saveFieldByGeoIdTerraPipe(
                                      controller.searchResult['JSON Response']
                                          ['GEO Id']);
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: AppColor.white,
                                ),
                                label: Text("Save Field",
                                    style: TextStyle(color: AppColor.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.primaryColor),
                              ),
                            ),

                          /// Options overlay
                          if (controller.isDrawPolygon.value)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: Get.height * 0.25,
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

                          /// side menu button is here
                          Positioned(
                            bottom: Get.height * 0.25,
                            right: 10,
                            child: controller.enableSideMenu.value
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(
                                            Icons.linear_scale_rounded,
                                            color: Colors.white),
                                        label: const Text("Walk&Track",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                        onPressed: () {
                                          controller.enableSideMenu.value =
                                              false;
                                          controller.update();
                                          Get.to(() => WalkTrackingPage());
                                        },
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.01,
                                      ),
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.polyline,
                                            color: AppColor.white),
                                        label: Text("Polygon",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.blue,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                        onPressed: () {
                                          controller.enableSideMenu.value =
                                              false;
                                          controller.update();
                                          controller.startDrawing();
                                          controller.isDrawingRectangle.value =
                                              false;
                                          controller.shapePoints.clear();
                                          controller.animationController
                                              .reverse();
                                        },
                                      ),
                                      SizedBox(
                                        height: Get.height * 0.01,
                                      ),
                                      ElevatedButton.icon(
                                        icon: Icon(Icons.delete_outline,
                                            color: AppColor.white),
                                        label: Text("Delete",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColor.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColor.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                        ),
                                        onPressed: () {
                                          controller.enableSideMenu.value =
                                              false;
                                          controller.update();
                                          controller.clearShapes();
                                          controller.animationController
                                              .reverse();
                                        },
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
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
