import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/auth/login_view/login_controller.dart';
import 'package:terrapipe/auth/login_view/login_view.dart';
import 'package:terrapipe/local_db_helper/shared_preference.dart';
import 'package:terrapipe/utilts/app_colors.dart';
import 'package:terrapipe/widgets/custom_button.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  String userEmail;
   CustomAppBar({Key? key, this.userEmail=""})
      : preferredSize = const Size.fromHeight(65),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.only(
          left: 10.0,
        ),
        decoration: BoxDecoration(
          color: AppColor.white,
          boxShadow:const  [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // spacing: 10,
            children: [
              // Profile Image
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/profile.png',
                        image:
                            'https://static.vecteezy.com/system/resources/previews/019/900/322/non_2x/happy-young-cute-illustration-face-profile-png.png',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(
                    widget.userEmail,
                    style: TextStyle(
                      color: AppColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              loginController.isLogoutloading.value
                  ? const Padding(
                      padding: EdgeInsets.only(right: 5.0),
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : IconButton(
                      icon:
                          const Icon(Icons.logout_rounded, color: Colors.black),
                      onPressed: () {
                        Get.defaultDialog(
                            title: 'Confirm Logout',
                            contentPadding:
                                const EdgeInsets.only(left: 15, right: 15),
                            backgroundColor: Colors.white,
                            middleText: 'Are you sure you want to logout?',
                            confirmTextColor: Colors.white,
                            buttonColor: Colors.black,
                            titlePadding: const EdgeInsets.only(top: 15),
                            content: Column(
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  "Are you sure you want to logout?",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomButton(
                                      label: 'Cancel',
                                      borderColor: AppColor.primaryColor,
                                      width: Get.width / 3.5,
                                      color: Colors.white,
                                      textStyle: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      onTap: () {
                                        Get.back();
                                      },
                                    ),
                                    CustomButton(
                                      label: 'Logout',
                                      textStyle: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                      borderColor: AppColor.primaryColor,
                                      width: Get.width / 3.5,
                                      color: AppColor.primaryColor,
                                      onTap: () async {
                                        Get.back();
                                        // await loginController.logout();
                                        await SharedPreference.instance.clearLocalData();
                                        Get.offAll(LoginPage());
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ));
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
