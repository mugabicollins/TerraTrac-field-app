import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/utilities/app_text_style.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/widgets/custom_button.dart';
import 'package:terrapipe/widgets/custom_text_field.dart';
import '../../asset_registery/asset_registery_controller.dart';

class PolygonBottomSheet extends StatelessWidget {
  PolygonBottomSheet({super.key});
  final AssetRegistryController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // spacing: 10,
          children: [
            const Center(
              child: Text("Field Actions", style: AppTextStyles.labelLarge),
            ),
            SizedBox(height: Get.height*0.03,),
            const Text(
              "Resolution level (optional):",
              style: AppTextStyles.labelMedium,
            ),
            SizedBox(height: Get.height*0.01,),
            CustomTextFormField(
              controller: homeController.resolutionLevelController,
              hintText: "level",
              fillColor: Colors.white,
            ),
            SizedBox(height: Get.height*0.02,),
            const Text(
              "threshold (optional):",
              style: AppTextStyles.labelMedium,
            ),
            SizedBox(height: Get.height*0.01,),
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
            SizedBox(height: Get.height*0.02,),
            const Text(
              "Domain (optional):",
              style: AppTextStyles.labelMedium,
            ),
            SizedBox(height: Get.height*0.01,),
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
              onChanged: (value) {
                log('changing value to: $value');
              },
            ),
            SizedBox(height: Get.height*0.02,),
            const Text(
              "Boundary Type:",
              style: AppTextStyles.labelMedium,
            ),
            SizedBox(height: Get.height*0.01,),
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
                log('changing value to: $value');
              },
            ),
            SizedBox(height: Get.height*0.02,),
            const Text(
              "S2_index (optional):",
              style: AppTextStyles.labelMedium,
            ),
            SizedBox(height: Get.height*0.01,),
            CustomTextFormField(
              controller: homeController.s2IndexController,
              hintText: "S2_index",
              fillColor: Colors.white,
            ),
            SizedBox(height: Get.height*0.05,),
            Row(
              // spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomButton(
                  label: 'Cancel',
                  width: Get.width/2.5,
                  height: 45,
                  onTap: () {
                    Get.back();
                  },
                  color: AppColor.white,
                  borderColor: AppColor.primaryColor,
                  textStyle:  const TextStyle(
                    color: AppColor.primaryColor,
                    fontWeight: FontWeight.bold
                  ),
                  textColor: AppColor.primaryColor,
                ),
                CustomButton(
                  label: 'Register Field',
                  height: 45,
                  width: Get.width/2.5,
                  borderColor: AppColor.primaryColor,
                  onTap: () async {
                    Get.back();
                    await homeController.savePolygonTeraTrac();
                    homeController.clearShapes();
                  },
                  textStyle:   TextStyle(
                    color: AppColor.white,
                    fontWeight: FontWeight.w700
                  ),
                  color: AppColor.primaryColor,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
