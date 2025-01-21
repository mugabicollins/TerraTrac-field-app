import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:terrapipe/auth/login_view/login_controller.dart';
import 'package:terrapipe/auth/login_view/login_view.dart';
import 'package:terrapipe/local_db_helper/shared_preference.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/utilts/app_images.dart';
import '../bottom_nav_bar/bottom_bar_view.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  LoginController loginController = Get.put(LoginController());
  void navigateToNextScreen() async {
    var email = await SharedPreference.instance.getString();
    print(email);
    await Future.delayed(const Duration(seconds: 2), () {
      if (email != null) {
        Get.offAll(() => BottomBarView());
      } else {
        Get.offAll(() => LoginPage());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle( const SystemUiOverlayStyle(
      statusBarColor:Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor:Colors.transparent,
    ));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primaryColor,
              AppColor.secondaryColor,
              AppColor.secondaryColor1,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: 0,
              child: Image.asset(
                AppImages.splashImage,
                // width: 300,
                // height: 300,
              ),
            ),
            // SizedBox(height: Get.height * 0.01),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: Get.height*0.68,
              child:  Text(
                'Welcome to Terra Trac',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
