import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:terrapipe/app/data/repositories/shared_preference.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import '../../app/modules/auth/login_view/login_view.dart';
import '../app_buttons/custom_button.dart';

class SessionExpireDialog extends StatelessWidget {
  const SessionExpireDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
            ),
            Lottie.asset(
              "assets/animation/sad.json",
              height: 120,
              width: 120,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Whoops, Your session has expired",
              style: TextStyle(
                  fontSize: 24,
                  color: AppColor.black,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'The session has expired because the same credentials were used to log in on another device. Please log in again.',
              style: TextStyle(
                  fontSize: 15,
                  color: AppColor.black,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(
              label: "Login",
              width: Get.width * 0.5,
              onTap: () async {
                await SharedPreference.instance.clearLocalData();
                // Get.offAll(LoginPage());
              },
              color: AppColor.primaryColor,
              textColor: AppColor.white,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
