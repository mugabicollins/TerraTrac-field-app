import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/app/modules/auth/sign_up_view/sign_up_controller.dart';
import 'package:terrapipe/app/modules/user_info/user_info_controller.dart';
import 'package:terrapipe/routes/app_routes.dart';
import 'package:terrapipe/utils/App_strings.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/utils/constants/app_images.dart';
import 'package:terrapipe/utils/helper_functions.dart';
import 'package:terrapipe/widgets/app_buttons/custom_general_button.dart';
import 'package:terrapipe/widgets/loader/bounce_loader.dart';
import 'package:terrapipe/widgets/textfields/custom_auth_fields.dart';

import '../../../utils/app_text/app_text.dart';

class Userinfo extends StatelessWidget {
  Userinfo({super.key});

  final UserInfoController userInfoController = Get.put(UserInfoController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ModalProgressHUD(
          inAsyncCall: userInfoController.loading.value,
          opacity: 0.85,
          color: Colors.black,
          progressIndicator: BounceAbleLoader(
            title: AppStrings.saveInfo,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
            ),
            extendBodyBehindAppBar: true,
            body: Form(
              key: _formKey,
              child: Container(
                height: Get.height,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Image.asset(AppImages.galaxyBg).image)),
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      verticalGap(
                        Get.height * 0.1,
                      ),
                      AppText(
                          title: AppStrings.getStarted,
                          color: Colors.white,
                          size: 25,
                          fontWeight: FontWeight.w600),
                      AppText(
                          title: AppStrings.needInfo,
                          color: Colors.white,
                          size: 25,
                          fontWeight: FontWeight.w600),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),
                      const SizedBox(height: 16),

                      // email is here
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                              title: AppStrings.emailAddress,
                              color: Colors.white,
                              size: 16,
                              fontWeight: FontWeight.w500),
                           verticalGap(Get.height*0.005,),
                          CustomAuthField(
                            controller: userInfoController.emailController,
                            hintText: AppStrings.emailAddressHint,
                            obscureText: false,
                            prefixIcon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.emailAddress;
                              }
                              // Regex for email validation
                              String pattern =
                                  r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                        ],
                      ),
                       verticalGap(Get.height*0.016),
                      // phone is here
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                              title: AppStrings.phoneNumber,
                              color: Colors.white,
                              size: 16,
                              fontWeight: FontWeight.w500),
                          verticalGap(Get.height*0.005,),

                          CustomAuthField(
                            controller: userInfoController.phoneNumber,
                            hintText: AppStrings.phoneNumberHint,
                            obscureText: false,
                            prefixIcon: Icons.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.phoneNumberError;
                              }
                              String pattern = r'^(?:[+0]9)?[0-9]{10,14}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return AppStrings.phoneNumberValidError;
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                      verticalGap(Get.height*0.1),

                      // skip
                      SizedBox(
                        width: double.infinity,
                        child: GeneralTextButton(
                            buttonText: AppStrings.skip,
                            buttonColor: Colors.transparent,
                            borderColor: AppColor.white,
                            textColor: AppColor.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            onTap: (){
                              Get.offAllNamed(AppRoutes.bottomBar);
                            }),
                      ),
                      verticalGap(Get.height*0.016),

                      /// continue
                      SizedBox(
                        width: double.infinity,
                        child: GeneralTextButton(
                            buttonText: AppStrings.next,
                            buttonColor: Colors.green,
                            borderColor: AppColor.green,
                            textColor: AppColor.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            onTap: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                await userInfoController.saveInfo();
                              }
                            }),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
