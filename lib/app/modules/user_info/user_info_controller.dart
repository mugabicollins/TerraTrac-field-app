import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/routes/app_routes.dart';
import 'package:terrapipe/utils/helper_functions.dart';

class UserInfoController extends GetxController {
  final emailController = TextEditingController();
  final firstName = TextEditingController();
  final lastname = TextEditingController();
  final phoneNumber = TextEditingController();
  final loading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    phoneNumber.dispose();
    super.onClose();
  }

  saveInfo() async {
    loading.value=true;
    update();
    await HelperFunctions.saveInPreference("userEmail", emailController.text.trim());
    await HelperFunctions.saveInPreference("phoneNumber", phoneNumber.text.trim());
    loading.value=false;
    update();
    Get.offNamed(AppRoutes.bottomBar);
  }
}
