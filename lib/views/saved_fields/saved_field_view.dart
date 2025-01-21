import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/views/saved_fields/saved_field_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:terrapipe/widgets/bounce_loader.dart';

import '../../widgets/custom_button.dart';

class SavedFieldView extends StatefulWidget {
  const SavedFieldView({super.key});

  @override
  State<SavedFieldView> createState() => _SavedFieldViewState();
}

class _SavedFieldViewState extends State<SavedFieldView> {
  SavedFieldController savedFieldController = Get.put(SavedFieldController());

  loadData() async {
    if (savedFieldController.fieldList.isEmpty) {
      savedFieldController.isFetchFieldLoading.value = true;
      savedFieldController.update();
      await savedFieldController.fetchGeoId();
    } else {
      await savedFieldController.fetchGeoId();
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ModalProgressHUD(
          inAsyncCall: savedFieldController.loading.isTrue,
          opacity: 1,
          color: Colors.white,
          progressIndicator: BounceAbleLoader(
            title: "Fetching Fields",
            textColor: AppColor.black,
            loadingColor: AppColor.black,
          ),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: savedFieldController.isFetchFieldLoading.isTrue
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  )
                : savedFieldController.fieldList.isNotEmpty
                    ? SizedBox(
                        height: Get.height * 0.9,
                        child: ListView.builder(
                          itemCount: savedFieldController.fieldList.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: Get.height * 0.2),
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.all(12.0),
                              elevation: 2.0,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// FlutterMap view
                                    Container(
                                      height: 150.0,
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: FlutterMap(
                                          options: savedFieldController
                                              .getMapOptions(index),
                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                                              subdomains: ['a', 'b', 'c'],
                                              errorTileCallback:
                                                  (tile, error, stackTrace) {
                                                print(
                                                    "Tile loading failed for ${tile.coordinates}: $error");
                                              },
                                            ),

                                            /// polygone
                                            PolygonLayer(
                                              polygons:
                                                  savedFieldController.polygons,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15.0),
                                    // Geo Id name
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Field Name',
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          savedFieldController
                                              .fieldList[index].last,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3.0),

                                    /// geo id vale
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Geo-Id',
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            InkWell(
                                                onTap: () {
                                                  Clipboard.setData(ClipboardData(
                                                      text: savedFieldController
                                                          .fieldList[index]
                                                          .first));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: const Text(
                                                          'Copied to clipboard!'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                                child: Icon(Icons.copy)),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0),
                                        Text(
                                          savedFieldController
                                              .fieldList[index].first,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10.0),

                                    /// Fetch field Button is here
                                    Row(
                                      children: [
                                        /// fetch Fields
                                        CustomButton(
                                          label: "Fetch Field",
                                          onTap: () {
                                            savedFieldController
                                                .fetchFieldByGeoId(
                                                    savedFieldController
                                                        .fieldList[index].first
                                                        .trim());
                                          },
                                          color: AppColor.primaryColor,
                                          textColor: Colors.white,
                                          height: 40.0,
                                          width: 100.0,
                                          borderRadius: 8.0,
                                        ),
                                        SizedBox(
                                          width: Get.width * 0.03,
                                        ),

                                        /// Delete Fields
                                        CustomButton(
                                          label: "Delete",
                                          onTap: () {},
                                          color: AppColor.red,
                                          textColor: Colors.white,
                                          height: 40.0,
                                          width: 100.0,
                                          borderRadius: 8.0,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5.0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "No Fields Found",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          )
                        ],
                      ),
          ),
        ));
  }
}
