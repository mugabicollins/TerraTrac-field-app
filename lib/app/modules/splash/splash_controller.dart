import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:terrapipe/app/modules/auth/login_view/login_controller.dart';
import 'package:terrapipe/app/modules/auth/sign_up_view/sign_up_controller.dart';
import 'package:terrapipe/utils/helper_functions.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {

  SignUpController signUpController = Get.put(SignUpController());
  LoginController loginController=Get.put(LoginController());
  @override

  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  static const String _saltKey = "device_salt";
  void navigateToNextScreen() async {
    // await Future.delayed(const Duration(seconds: 4));
    String email = await HelperFunctions.getFromPreference("userEmail");
    String deviceSalt= await HelperFunctions.getFromPreference(_saltKey);
    debugPrint("Splash device Salt:::: ${deviceSalt}");
    if(deviceSalt.isNotEmpty){
      await loginController.hashLogin();
    }else{
      await signUpController.hashSignup();
    }
    print("Retrieved Email: $email");  // Debugging
    if (email != null && email.toString().isNotEmpty ) {
      print("Navigating to BottomBar");
      Get.offNamed(AppRoutes.bottomBar);
    } else {
      print("Navigating to UserInfo");
      Get.offNamed(AppRoutes.userInfo);
    }
  }

}
