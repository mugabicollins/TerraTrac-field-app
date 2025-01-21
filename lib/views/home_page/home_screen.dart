import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/widgets/bounce_loader.dart';
import 'package:terrapipe/widgets/custom_button.dart';
import 'package:terrapipe/widgets/custom_text_field.dart';
import 'components/search_bottom_sheet.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());

  // bool isPointInPolygon(LatLng point, List<LatLng> polygonPoints) {
  //   int n = polygonPoints.length;
  //   bool isInside = false;
  //   for (int i = 0, j = n - 1; i < n; j = i++) {
  //     if ((polygonPoints[i].latitude > point.latitude) !=
  //             (polygonPoints[j].latitude > point.latitude) &&
  //         (point.longitude <
  //             (polygonPoints[j].longitude - polygonPoints[i].longitude) *
  //                     (point.latitude - polygonPoints[i].latitude) /
  //                     (polygonPoints[j].latitude - polygonPoints[i].latitude) +
  //                 polygonPoints[i].longitude)) {
  //       isInside = !isInside;
  //     }
  //   }
  //   return isInside;
  // }

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
        inAsyncCall: controller.searchLoading.isTrue,
        opacity: 0.9,
        color: AppColor.white,
        progressIndicator: BounceAbleLoader(
          title: "Fetching Details",
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
                           FlutterMap(
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
                                  ),
                                ),
                              ],
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
                                        await controller.getFieldByGeoId(controller
                                            .searchController.text
                                            .trim());
                                      },
                                      onChanged: (val) async {
                                      },
                                      suffixIconWidget: IconButton(
                                          onPressed: () {
                                            if (controller.searchEnable.value) {
                                              controller.searchController.clear();
                                              controller.drawnPolygons.clear();
                                              controller.searchEnable.value=false;
                                              loadLocation();
                                              setState(() {});
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
