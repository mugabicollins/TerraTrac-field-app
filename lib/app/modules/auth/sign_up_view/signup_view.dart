import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:terrapipe/app/modules/auth/sign_up_view/sign_up_controller.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/utils/constants/app_images.dart';
import 'package:terrapipe/widgets/loader/bounce_loader.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});
  final SignUpController _signupController = Get.put(SignUpController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Obx(() => ModalProgressHUD(
          inAsyncCall: _signupController.loading.value,
          opacity: 0.85,
          color: Colors.black,
          progressIndicator: BounceAbleLoader(
            title: "Creating Your Account",
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
              ),
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
                      SizedBox(
                        height: Get.height * 0.1,
                      ),

                      const Text(
                        "Get Started",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w600),
                      ),

                      const Text(
                        "Create your new account",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: Get.height * 0.05,
                      ),

                      // /// first name field is here
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text(
                      //       "First Name",
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //     const SizedBox(
                      //       height: 5,
                      //     ),
                      //     TextFormField(
                      //       controller: _controller.firstName,
                      //       style: const TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500,
                      //           fontSize: 16),
                      //       cursorColor: Colors.white,
                      //       decoration: const InputDecoration(
                      //         hintText: 'Enter your first name',
                      //         labelStyle: TextStyle(color: Colors.white),
                      //         hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12), // Adjust the radius value as needed
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: Colors.white,
                      //             // Active border color set to white
                      //             width: 1.0,
                      //           ),
                      //         ),
                      //       ),
                      //       validator: (value) {
                      //         if (value == null || value.isEmpty) {
                      //           return 'Please enter your first name';
                      //         }
                      //         return null;
                      //       },
                      //     ),
                      //
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      // /// last name is here
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text(
                      //       "Last Name",
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //     const SizedBox(
                      //       height: 5,
                      //     ),
                      //     TextFormField(
                      //       controller: _controller.lastname,
                      //       style: const TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500,
                      //           fontSize: 16),
                      //       cursorColor: Colors.white,
                      //       decoration: const InputDecoration(
                      //         hintText: 'Enter your last name',
                      //         labelStyle: TextStyle(color: Colors.white),
                      //         hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12), // Adjust the radius value as needed
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: Colors.white,
                      //             // Active border color set to white
                      //             width: 1.0,
                      //           ),
                      //         ),
                      //       ),
                      //       validator: (value) {
                      //         if (value == null || value.isEmpty) {
                      //           return 'Please enter your last name';
                      //         }
                      //         return null;
                      //       },
                      //     ),
                      //
                      //   ],
                      // ),
                      // const SizedBox(height: 16),
                      // /// company name
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     const Text(
                      //       "Company Name",
                      //       style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500),
                      //     ),
                      //     const SizedBox(
                      //       height: 5,
                      //     ),
                      //     TextFormField(
                      //       controller: _controller.companyName,
                      //       style: const TextStyle(
                      //           color: Colors.white,
                      //           fontWeight: FontWeight.w500,
                      //           fontSize: 16),
                      //       cursorColor: Colors.white,
                      //       decoration: const InputDecoration(
                      //         hintText: 'Enter your company name',
                      //         labelStyle: TextStyle(color: Colors.white),
                      //         hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      //         border: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12), // Adjust the radius value as needed
                      //           ),
                      //         ),
                      //         focusedBorder: OutlineInputBorder(
                      //           borderRadius: BorderRadius.all(
                      //             Radius.circular(12),
                      //           ),
                      //           borderSide: BorderSide(
                      //             color: Colors.white,
                      //             // Active border color set to white
                      //             width: 1.0,
                      //           ),
                      //         ),
                      //       ),
                      //       validator: (value) {
                      //         if (value == null || value.isEmpty) {
                      //           return 'Please enter your company name';
                      //         }
                      //         return null;
                      //       },
                      //     ),
                      //
                      //   ],
                      // ),
                      const SizedBox(height: 16),

                      /// email is here
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email Address",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _signupController.emailController,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      12), // Adjust the radius value as needed
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  // Active border color set to white
                                  width: 1.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  // Active border color set to white
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
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
                      const SizedBox(height: 16),

                      /// phone is here
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Phone Number",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFormField(
                            controller: _signupController.phoneNumber,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Enter your phone number',
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      12), // Adjust the radius value as needed
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.grey,
                                  // Active border color set to white
                                  width: 1.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12),
                                ),
                                borderSide: BorderSide(
                                  color: Colors.white,
                                  // Active border color set to white
                                  width: 1.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// password field
                      /// Password field
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(() => TextFormField(
                                controller:
                                    _signupController.passwordController,
                                obscureText:
                                    _signupController.isPasswordObscure.value,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      // Active border color set to white
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_signupController
                                            .isPasswordObscure.value
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: _signupController
                                        .togglePasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters long';
                                  }
                                  if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                    return 'Password must contain at least one uppercase letter';
                                  }
                                  if (!RegExp(r'[a-z]').hasMatch(value)) {
                                    return 'Password must contain at least one lowercase letter';
                                  }
                                  if (!RegExp(r'\d').hasMatch(value)) {
                                    return 'Password must contain at least one number';
                                  }
                                  return null;
                                },
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),

                      /// Confirm Password field
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Confirm Password",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Obx(() => TextFormField(
                                controller:
                                    _signupController.confirmPasswordController,
                                obscureText: _signupController
                                    .isConfirmPasswordObscure.value,
                                cursorColor: Colors.white,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16),
                                decoration: InputDecoration(
                                  hintText: 'Confirm your password',
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  hintStyle: const TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      // Active border color set to white
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 1.0,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_signupController
                                            .isConfirmPasswordObscure.value
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: _signupController
                                        .toggleConfirmPasswordVisibility,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value !=
                                      _signupController
                                          .passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              )),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Login button with validation check
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              _signupController.signup();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColor.green, // Replaces 'primary'
                            foregroundColor:
                                Colors.white, // Replaces 'onPrimary'
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      /// already have an account
                      Center(
                        child: GestureDetector(
                          onTap: _signupController.navigateToSignup,
                          child: const Text(
                            "Already hava an account? Login",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
