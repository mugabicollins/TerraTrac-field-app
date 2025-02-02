import 'package:get/get.dart';
import 'package:terrapipe/app/modules/bottom_nav_bar/bottom_bar_view.dart';
import 'package:terrapipe/app/modules/splash/splash_binding.dart';
import 'package:terrapipe/app/modules/splash/splash_view.dart';
import 'package:terrapipe/routes/app_routes.dart';
import '../app/modules/home/views/walk_traking/walk_tracking_view.dart';
import '../app/modules/user_info/userInfo.dart';
class AppPages {
  static final List<GetPage> pages = [

    // splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    // Userinfo
    GetPage(
      name: AppRoutes.userInfo,
      page: () => Userinfo(),
    ),
    // bottom bar
    GetPage(
      name: AppRoutes.bottomBar,
      page: () => BottomBarView(),
    ),
    GetPage(
      name: AppRoutes.bottomBar,
      page: () => WalkTrackingPage(),
    ),
  ];
}
