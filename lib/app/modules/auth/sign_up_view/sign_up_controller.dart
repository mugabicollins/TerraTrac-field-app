import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as d;
import 'package:terrapipe/app/modules/auth/login_view/login_controller.dart';
import 'package:terrapipe/app/modules/auth/login_view/login_view.dart';
import 'package:terrapipe/services/api.dart';
import 'package:terrapipe/utils/helper_functions.dart';

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstName = TextEditingController();
  final lastname = TextEditingController();
  final phoneNumber = TextEditingController();
  final companyName = TextEditingController();
  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;

  void togglePasswordVisibility() {
    isPasswordObscure.value = !isPasswordObscure.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscure.value = !isConfirmPasswordObscure.value;
  }

  final loading = false.obs;

  Future<void> signup() async {
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    Get.snackbar('Error', 'Email and password cannot be empty',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  const String firstApiUrl = "${Api.baseUrl}/signup";
  const String secondApiUrl = "https://be.terrapipe.io/signup";

  var dio = d.Dio();
  loading.value = true;
  update();

  try {
    // First API body
    var firstApiBody = {
      'email': email,
      'password': password,
      'phone_num': phoneNumber.text.trim(),
      'confirm_pass': confirmPasswordController.text.trim(),
      'newsletter': 'checked',
      'discoverable': '',
    };

    // Second API body
    var secondApiBody = {
      'email': email,
      'password': password,
      'phone_number': phoneNumber.text.trim(),
      'confirm_password': confirmPasswordController.text.trim(),
    };

    var headers = {'Content-Type': 'application/json'};

    // First API Call
    var firstResponse = await dio.post(
      firstApiUrl,
      data: json.encode(firstApiBody),
      options: d.Options(headers: headers),
    );

    if (firstResponse.statusCode == 200) {
      print("First API Response: ${firstResponse.data}");
      // showSnackBar(
      //   color: Colors.green,
      //   title: "Success",
      //   message: "First API call succeeded. Proceeding to next step...",
      // );

      // Second API Call
      var secondResponse = await dio.post(
        secondApiUrl,
        data: json.encode(secondApiBody),
        options: d.Options(headers: headers),
      );

      if (secondResponse.statusCode == 200) {
        print("Second API Response: ${secondResponse.data}");
        showSnackBar(
          color: Colors.green,
          title: "Success",
          message: "Signup successful. Please verify your email.",
        );

        // Navigate to login page after successful signup
        Get.offAll(() => LoginPage());
      } else {
        print("Second API Response: ${secondResponse.data}");
        showSnackBar(
          color: Colors.red,
          title: "Error",
          message: "Second API call failed. ${secondResponse.statusMessage}",
        );
      }
    } else {
      print("First API Response: ${firstResponse.data}");
      showSnackBar(
        color: Colors.red,
        title: "Error",
        message: "First API call failed. ${firstResponse.statusMessage}",
      );
    }
  } on d.DioException catch (e) {
    final errorMessage =
        e.response?.data['message'] ?? "An unexpected error occurred";
    showSnackBar(
      color: Colors.red,
      title: "Failure",
      message: errorMessage,
    );

    if (kDebugMode) {
      print("Error during API calls: ${e.response?.data}");
    }
  } finally {
    loading.value = false;
    update();
  }
}


  void navigateToSignup() {
    final loginController = Get.find<LoginController>();
    loginController.clearFields();
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
