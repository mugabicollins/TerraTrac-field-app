// import 'package:get/get.dart';
// import 'package:terrapipe/auth/login_view/login_view.dart';
// import 'package:terrapipe/home_page/home_screen.dart';
// import 'package:terrapipe/local_db_helper/shared_preference.dart';

// class SplashController extends GetxController {
//   @override
//   void onInit() {
//     super.onInit();
//     navigateToNextScreen();
//   }

//   void navigateToNextScreen() async {
//     var email = await SharedPreference.instance.getString();

//     await Future.delayed(const Duration(seconds: 2), () {
//       if (email != null) {
//         Get.offAll(() => HomeScreen());
//       } else {
//         Get.offAll(() => LoginPage());
//       }
//     });
//   }
// }
