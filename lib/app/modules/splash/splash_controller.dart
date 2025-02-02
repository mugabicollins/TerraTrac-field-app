import 'package:get/get.dart';
import 'package:terrapipe/utils/helper_functions.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  @override
  void onInit() {
    super.onInit();
    navigateToNextScreen();
  }

  void navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4));


    String email = await HelperFunctions.getFromPreference("userEmail");
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
