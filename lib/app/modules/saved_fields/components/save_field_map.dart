import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/widgets/loader/bounce_loader.dart';
import 'package:terrapipe/widgets/app_buttons/custom_button.dart';
import 'package:terrapipe/widgets/app_buttons/custom_general_button.dart';
import 'package:terrapipe/widgets/textfields/custom_text_field.dart';
import '../../../../widgets/customMap/custom_map_view.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/saved_field_controller.dart';

class SaveFieldMap extends StatefulWidget {
  const SaveFieldMap({super.key});

  @override
  State<SaveFieldMap> createState() => _SaveFieldMapState();
}

class _SaveFieldMapState extends State<SaveFieldMap> {
  final List<Polygon> polygons = [];
  final MapController mapController = MapController();
  TextEditingController renameFieldController = TextEditingController();
  SavedFieldController savedFieldController = Get.put(SavedFieldController());
  final HomeController controller = Get.put(HomeController());
  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments ?? {};
    final List<LatLng> polygonPoints = arguments['polygonPoints'] ?? [];
    if (polygonPoints.isNotEmpty) {
      // Add yellow polygon
      polygons.add(
        Polygon(
          points: [...polygonPoints, polygonPoints[0]], // Close the polygon
          borderColor: Colors.yellow,
          borderStrokeWidth: 2.0,
          color: Colors.yellow.withOpacity(0.3),
        ),
      );
    }
  }

  // Function to calculate the center of the polygon
  LatLng getPolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lonSum = 0;

    for (var point in points) {
      latSum += point.latitude;
      lonSum += point.longitude;
    }

    double latCenter = latSum / points.length;
    double lonCenter = lonSum / points.length;

    return LatLng(latCenter, lonCenter);
  }

  @override
  Widget build(BuildContext context) {
    final List<LatLng> polygonPoints = polygons.isNotEmpty ? polygons[0].points : [];
    final LatLng center = getPolygonCenter(polygonPoints);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: AppColor.black,
              size: 22,
            )),
        centerTitle: true,
        title:  const Text(
          'Field Map',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: AppColor.white,
      ),
      body: Obx(()=>ModalProgressHUD(
        inAsyncCall: savedFieldController.gettingDetail.isTrue,
        opacity: 0.7,
        color: Colors.white,
        progressIndicator: BounceAbleLoader(
          title: "Fetching Details",
          textColor: AppColor.black,
          loadingColor: AppColor.black,
        ),
        child: Stack(
          children: [

            CustomFlutterMap(
              mapController: mapController,
              mapOptions: MapOptions(
                initialCenter: polygons.isNotEmpty
                    ? polygons[0].points[0] // Center on the first point
                    : const LatLng(51.5, -0.09),
                initialZoom: 15,
              ),
              polygons: polygons,
              mapPath: controller.mapPath.value,
              // Custom marker color
              markers: [],
              onMapTap: (LatLng point) {// Add point when tapping the map
              },
            ),

            Positioned(
              left: Get.width*0.01,
              right: Get.width*0.01,
              bottom: Get.height*0.03,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GeneralTextButton(
                    buttonWidth: MediaQuery.of(context).size.width * 0.4,
                    buttonText: 'Rename Field',
                    onTap: () {
                      Get.defaultDialog(
                        contentPadding: EdgeInsets.all(15),
                        title: 'Rename Geo-ID',
                         content: SizedBox(
                           width: 300,
                           child: Column(

                             children: [
                               CustomTextFormField(controller: renameFieldController, hintText: 'Rename this Geo-ID'),
                               const SizedBox(height: 15,),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   CustomButton(
                                     label: 'Cancel',
                                     color: Colors.white,
                                     width: Get.width/3.0,
                                     borderColor: AppColor.primaryColor,
                                     textStyle: const TextStyle(
                                       fontWeight: FontWeight.bold,
                                       fontSize: 16
                                     ),
                                     onTap: () {
                                       Get.back();
                                     },
                                   ),
                                   CustomButton(
                                     color: AppColor.green,
                                     label: 'Rename',
                                     width: Get.width/3.0,
                                     onTap: () async {
                                       Get.back();
                                     },
                                   )
                                 ],
                               )
                             ],
                           ),
                         ),

                          confirmTextColor: Colors.white,
                           buttonColor: AppColor.red,
                          titlePadding: EdgeInsets.all(15),
                      );
                    },
                    buttonColor: AppColor.primaryColor,
                    textColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  GeneralTextButton(
                    buttonWidth: MediaQuery.of(context).size.width * 0.4,
                    buttonText: 'Access Data',
                    onTap: () {
                      // Handle Access Data action
                      savedFieldController.handleAccessData();
                      print('Access Data tapped');
                    },
                    buttonColor: AppColor.primaryColor,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }


}
