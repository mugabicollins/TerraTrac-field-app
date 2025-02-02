import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:terrapipe/app/data/repositories/shared_preference.dart';
import 'package:terrapipe/app/modules/home/controllers/home_controller.dart';
import 'package:terrapipe/app/modules/home/views/home_screen.dart';
import 'package:terrapipe/app/modules/saved_fields/controllers/saved_field_controller.dart';
import 'package:terrapipe/app/modules/saved_fields/views/saved_field_view.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/utils/helper_functions.dart';
import 'package:terrapipe/widgets/appbars/custom_appbar.dart';
import 'package:terrapipe/widgets/app_buttons/custom_button.dart';

class BottomBarView extends StatefulWidget {
  BottomBarView({super.key});

  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  var userEmail = "Guest User";
  var bottomSelectedIndex = 0;
  PageController bottomController = PageController(initialPage: 0);
  SavedFieldController savedFieldController = Get.put(SavedFieldController());
  final HomeController homeController = Get.put(HomeController());
  var bottomIcons = [
    {'icon': 'assets/icons/bottombaricons/home.png', 'name': "Home"},
    {'icon': 'assets/icons/bottombaricons/fav.png', 'name': "My Fields"},
  ];

  Future<bool> _showBackDialog() async {
    return await Get.defaultDialog(
          title: 'Confirm Exit',
          backgroundColor: AppColor.white,
          titlePadding: const EdgeInsets.only(top: 25),
          middleText: 'Are you sure you want to exit the map?',
          textCancel: 'Cancel',
          textConfirm: 'Exit',
          confirmTextColor: AppColor.white,
          contentPadding: const EdgeInsets.all(30),
          buttonColor: AppColor.black,
          cancel: CustomButton(
            label: 'Cancel',
            textStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            borderColor: AppColor.primaryColor,
            width: Get.width / 3.5,
            color: Colors.white,
            onTap: () {
              Get.back(result: false);
            },
          ),
          confirm: CustomButton(
            label: 'Confirm',
            width: Get.width / 3.5,
            color: AppColor.primaryColor,
            onTap: () {
              Get.back(result: true);
            },
          ),
        ) ??
        false;
  }

  loadUserData() async {
    savedFieldController.isFetchFieldLoading.value = true;
    await savedFieldController.fetchGeoId();
    userEmail = await HelperFunctions.getFromPreference("userEmail") ?? "";
    setState(() {});
  }

  @override
  void initState() {
    loadUserData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: AppColor.white, // Transparent status bar
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColor.white,
    ));
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog();
        if (context.mounted && shouldPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          userEmail: userEmail,
        ),
        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
              color: AppColor.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 3)),
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: FloatingActionButton(
              onPressed: () async {
                if (homeController.enableSideMenu.value) {
                  homeController.enableSideMenu.value = false;
                  homeController.update();
                } else {
                  homeController.enableSideMenu.value = true;
                  homeController.update();
                }

                // bottomController.jumpToPage(1);
                // bottomSelectedIndex = 1;
                // setState(() {});
              },
              backgroundColor: AppColor.primaryColor,
              child: const Icon(Icons.add),
            ),
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 75,
          child: StylishBottomBar(
            backgroundColor: AppColor.white,
            elevation: 15,
            iconSpace: 5,
            notchStyle: NotchStyle.circle,
            borderRadius: BorderRadius.circular(100),
            option: AnimatedBarOptions(
              inkEffect: false,
              iconSize: 25,
              barAnimation: BarAnimation.fade,
              padding: const EdgeInsets.all(0),
              iconStyle: IconStyle.animated,
              opacity: 0.8,
            ),
            hasNotch: true,
            fabLocation: StylishBarFabLocation.center,
            currentIndex: bottomSelectedIndex,
            onTap: (index) {
              bottomController.jumpToPage(index);
              bottomSelectedIndex = index;
              setState(() {});
            },
            items: [
              /// home
              BottomBarItem(
                icon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.home),
                ),

                /// this show when animation type liquid
                backgroundColor: AppColor.primaryColor,
                title: const Text(
                  "Home",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                showBadge: false,
              ),
              BottomBarItem(
                icon: const SizedBox(),

                /// this show when animation type liquid
                backgroundColor: AppColor.primaryColor,
                title: const Text(
                  "",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                showBadge: false,
              ),

              /// saved fields
              BottomBarItem(
                icon: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.save),
                ),

                /// this show when animation type liquid
                backgroundColor: AppColor.primaryColor,
                title: const Text(
                  "Save Fields",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
                showBadge: false,
              )
            ],
          ),
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (val) {
            print("here is the caas ${val}");
            bottomSelectedIndex = val;
            bottomController.jumpToPage(val);
            setState(() {});
          },
          controller: bottomController,
          children: const [
            HomeScreen(),
            SizedBox(),
            SavedFieldView(),
          ],
        ),
      ),
    );
  }
}
