import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:terrapipe/app/modules/home/controllers/home_controller.dart';

import 'package:terrapipe/app/modules/saved_fields/controllers/saved_field_controller.dart';
import 'package:terrapipe/utils/App_strings.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/widgets/loader/bounce_loader.dart';
import 'package:terrapipe/widgets/app_buttons/custom_button.dart';
import '../../../../utils/app_text/app_text.dart';
import '../../../../widgets/customMap/custom_map_view.dart';
import '../components/save_field_map.dart';

class SavedFieldView extends StatefulWidget {
  const SavedFieldView({super.key});

  @override
  State<SavedFieldView> createState() => _SavedFieldViewState();
}

class _SavedFieldViewState extends State<SavedFieldView> {
  final SavedFieldController savedFieldController = Get.put(SavedFieldController());
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    savedFieldController.isFetchFieldLoading.value =
        savedFieldController.fieldList.isEmpty;
    savedFieldController.update();
    await savedFieldController.fetchGeoId();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ModalProgressHUD(
        inAsyncCall: savedFieldController.loading.isTrue,
        opacity: 1,
        color: Colors.white,
        progressIndicator: BounceAbleLoader(
          title: AppStrings.fetchingFields,
          textColor: AppColor.black,
          loadingColor: AppColor.black,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: savedFieldController.isFetchFieldLoading.isTrue
              ? const Center(
                  child:
                      CircularProgressIndicator(color: AppColor.primaryColor),
                )
              // : savedFieldController.connectionStatus.value
              // ? _buildFieldListView()
              : _buildLocalPolygonListView(),
        ),
      ),
    );
  }

  Widget _buildFieldListView() {
    return savedFieldController.fieldList.isNotEmpty
        ? ListView.builder(
            padding: EdgeInsets.only(bottom: Get.height * 0.2),
            itemCount: savedFieldController.fieldList.length,
            itemBuilder: (context, index) {
              return _buildFieldCard(index);
            },
          )
        : Center(
            child: AppText(
              title: AppStrings.noFieldsFound,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.bold,
              size: 20,
            ),
          );
  }

  Widget _buildLocalPolygonListView() {
    return SizedBox(
      height: Get.height * 0.9,
      child: savedFieldController.locallyPolygonList.isNotEmpty
          ? ListView.builder(
              itemCount: savedFieldController.locallyPolygonList.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(bottom: Get.height * 0.2),
              itemBuilder: (context, index) {
                // var polygonModel = savedFieldController.locallyPolygonList[index];
                print("hshshs$index");
                return Card(
                  margin: const EdgeInsets.all(12.0),
                  elevation: 2.0,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FlutterMap View
                        Container(
                          height: 150.0,
                          width: Get.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FlutterMap(
                              options: MapOptions(
                                center: savedFieldController
                                    .localPolygons[index].points.first,
                                zoom: 15.0,
                                interactionOptions: InteractionOptions(
                                    flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                  subdomains: ['a', 'b', 'c'],
                                  errorTileCallback: (tile, error, stackTrace) {
                                    print(
                                        "Tile loading failed for ${tile.coordinates}: $error");
                                  },
                                  tileProvider: CachedTileProvider(
                                    maxStale: const Duration(days: 30),
                                    store: HiveCacheStore(
                                      savedFieldController
                                          .homeController.mapPath.value,
                                      hiveBoxName: 'HiveCacheStore',
                                    ),
                                  ),
                                ),
                                PolygonLayer(
                                  polygons: [
                                    savedFieldController.localPolygons[index]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15.0),

                        // Field Name
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title: AppStrings.fieldName,
                              size: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            AppText(
                              title: "Not Saved",
                              maxLines: 1,
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0),

                        // Geo ID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title: AppStrings.geoId,
                              size: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            const SizedBox(height: 5.0),
                            AppText(
                              title: "Not Saved",
                              maxLines: 1,
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        _buildActionButtons(index),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: AppText(
                title: AppStrings.noFieldsFound,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                size: 20,
              ),
            ),
    );
  }

  Widget _buildFieldCard(int index) {
    return Card(
      margin: const EdgeInsets.all(12.0),
      elevation: 2.0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapView(index),
            const SizedBox(height: 15.0),
            _buildFieldName(index),
            const SizedBox(height: 3.0),
            _buildGeoId(index),
            const SizedBox(height: 10.0),
            _buildActionButtons(index),
            const SizedBox(height: 5.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMapView(int index) {
    return Container(
      height: 150.0,
      width: Get.width,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomFlutterMap(
          mapController: MapController(),
          mapOptions: savedFieldController.getMapOptions(index),
          polygons: savedFieldController.polygons,
          mapPath: controller.mapPath.value,
          // Custom marker color
          markers: [],
          onMapTap: (LatLng point) {// Add point when tapping the map
          },
        ),

        // FlutterMap(
        //   options: savedFieldController.getMapOptions(index),
        //   children: [
        //     TileLayer(
        //       urlTemplate:
        //           'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
        //       subdomains: ['a', 'b', 'c'],
        //     ),
        //     PolygonLayer(polygons: savedFieldController.polygons),
        //   ],
        // ),
      ),
    );
  }

  Widget _buildFieldName(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
            title: AppStrings.fieldName,
            size: 16.0,
            fontWeight: FontWeight.bold),
        Text(
          savedFieldController.fieldList[index].last,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Widget _buildGeoId(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
                title: AppStrings.geoId,
                size: 16.0,
                fontWeight: FontWeight.bold),
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(
                    text: savedFieldController.fieldList[index].first));
                _showSnackBar(AppStrings.copiedToClipBoard);
              },
              child: const Icon(Icons.copy),
            ),
          ],
        ),
        const SizedBox(height: 5.0),
        Text(
          savedFieldController.fieldList[index].first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14.0),
        ),
      ],
    );
  }

  Widget _buildActionButtons(int index) {
    print("here is index ${index}");
    return Row(
      children: [
        CustomButton(
          label: AppStrings.fetchFields,
          onTap: () {
            if (savedFieldController.connectionStatus.value) {
              // savedFieldController.fetchFieldByGeoId(savedFieldController.fieldList[index].first.trim());
              List<LatLng> points = savedFieldController
                  .extractLatLngFromPolygon(savedFieldController
                      .locallyPolygonList[index].polygonData);
              Get.to(() => const SaveFieldMap(), arguments: {
                'geoId': "UnKnown",
                'polygonPoints': points,
              });
            } else {
              List<LatLng> points = savedFieldController
                  .extractLatLngFromPolygon(savedFieldController
                      .locallyPolygonList[index].polygonData);
              Get.to(() => const SaveFieldMap(), arguments: {
                'geoId': "UnKnown",
                'polygonPoints': points,
              });
            }
          },
          color: AppColor.primaryColor,
          textColor: Colors.white,
          height: 40.0,
          width: 100.0,
          borderRadius: 8.0,
        ),
        SizedBox(width: Get.width * 0.03),
        CustomButton(
          label: AppStrings.delete,
          onTap: () {},
          color: AppColor.red,
          textColor: Colors.white,
          height: 40.0,
          width: 100.0,
          borderRadius: 8.0,
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(title: message, size: 14, fontWeight: FontWeight.w500),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
