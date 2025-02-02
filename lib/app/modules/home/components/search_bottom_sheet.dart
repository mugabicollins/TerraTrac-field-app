import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/widgets/textfields/custom_text_field.dart';
class SearchBottomSheet extends StatefulWidget {
  const SearchBottomSheet({super.key});

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  TextEditingController searchByGeoId=TextEditingController();
  TextEditingController GeoId1=TextEditingController();
  TextEditingController GeoId2=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width,
      child: Padding(
        padding: const  EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: Get.height*0.02,),
            const Center(
              child: Text("Search By",
                style:TextStyle(
                color: Colors.black,
                fontSize: 18,
                  fontWeight: FontWeight.w600
              ),),
            ),
            SizedBox(height: Get.height*0.02,),
            /// search by geo ids
            SizedBox(
              height: 55,
              child: CustomTextFormField(
                controller: searchByGeoId,
                hintText: "Search by Geo ID's",
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: Get.height*0.02,),
            /// get percentage
            const Text("Get Percentage of two Geo ID's",
              style:TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),),
            SizedBox(height: Get.height*0.01,),
            /// Geo ID 1
            SizedBox(
              height: 55,
              child: CustomTextFormField(
                controller: GeoId1,
                hintText: "Geo ID 1",
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: Get.height*0.01,),
            SizedBox(
              height: 55,
              child: CustomTextFormField(
                controller: GeoId2,
                hintText: "Geo ID 2",
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: Get.height*0.02,),
            Center(
              child: Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black
                  )
                ),
                child: Center(child: Text("% Percentage",style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600
                ),)),
              ),
            ),
            SizedBox(height: Get.height*0.06,),
          ],
        ),
      ),
    );
  }
}
