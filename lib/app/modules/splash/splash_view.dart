import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:terrapipe/app/data/repositories/shared_preference.dart';
import 'package:terrapipe/app/modules/auth/login_view/login_controller.dart';
import 'package:terrapipe/app/modules/auth/login_view/login_view.dart';
import 'package:terrapipe/app/modules/splash/splash_controller.dart';
import 'package:terrapipe/routes/app_routes.dart';
import 'package:terrapipe/utils/App_strings.dart';
import 'package:terrapipe/utils/app_text/app_text.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import '../../../utils/constants/app_images.dart';
import '../bottom_nav_bar/bottom_bar_view.dart';
import '../user_info/userInfo.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle( const SystemUiOverlayStyle(
      statusBarColor:Colors.transparent, // Transparent status bar
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor:Colors.transparent,
    ));
    return GetBuilder<SplashController>(
        autoRemove: false,
        builder: (controller) =>Scaffold(
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
              child:  AppText(
                title: AppStrings.welcome,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
