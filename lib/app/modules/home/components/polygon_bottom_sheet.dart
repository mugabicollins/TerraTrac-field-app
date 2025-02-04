import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/app/modules/home/controllers/home_controller.dart';
import 'package:terrapipe/utils/App_strings.dart';
import 'package:terrapipe/utils/app_text/app_text.dart';
import 'package:terrapipe/utils/app_text_style.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/widgets/app_buttons/custom_button.dart';
import 'package:terrapipe/widgets/textfields/custom_text_field.dart';

class PolygonBottomSheet extends StatelessWidget {
  PolygonBottomSheet({super.key});

  final HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:  const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          topLeft: Radius.circular(32)
        )
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          // spacing: 10,
          children: [
            Center(
              child: AppText(
                title: AppStrings.fetchingAction,
                size: 20,
                fontWeight: FontWeight.w600,
              ),
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
              onChanged: (value) {
                log('changing value to: $value');
              },
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
                log('changing value to: $value');
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
                  label: AppStrings.cancel,
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
                  label: AppStrings.registeredField,
                  height: 45,
                  width: Get.width / 2.5,
                  borderColor: AppColor.primaryColor,
                  onTap: () async {
                    Get.back();
                    await homeController.savePolygonTeraTrac();
                    homeController.clearShapes();
                  },
                  textStyle: TextStyle(
                      color: AppColor.white, fontWeight: FontWeight.w700),
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
