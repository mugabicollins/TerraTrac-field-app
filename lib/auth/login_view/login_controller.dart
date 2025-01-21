import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:terrapipe/auth/login_view/login_view.dart';
import 'package:terrapipe/local_db_helper/shared_preference.dart';
import 'package:terrapipe/services/api.dart';
import 'package:dio/dio.dart' as d;
import 'package:terrapipe/utilts/helper_functions.dart';
import '../../bottom_nav_bar/bottom_bar_view.dart';
import '../sign_up_view/signup_view.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final isPasswordObscure = true.obs;
  final isBossChecked = false.obs;
  final isKeepMeLoggedInChecked = false.obs;
  final loading = false.obs;
  final isLogoutloading = false.obs;
  RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    requestPermission();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    clearFields();
    loadUserEmail();
  }

  Future<void> loadUserEmail() async {
    userEmail.value = await SharedPreference.instance.getString() ?? '';
  }

  void togglePasswordVisibility() {
    isPasswordObscure.value = !isPasswordObscure.value;
  }

  void toggleBossCheckbox(bool? value) {
    isBossChecked.value = value ?? false;
  }

  void toggleKeepMeLoggedInCheckbox(bool? value) {
    isKeepMeLoggedInChecked.value = value ?? false;
  }

  void navigateToSignup() {
    Get.to(() => SignupPage());
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void clearFields() {
    toggleKeepMeLoggedInCheckbox(false);
    emailController.clear();
    passwordController.clear();
  }

  // Check and request location permissions
  Future<void> requestPermission() async {
    PermissionStatus permission = await Permission.location.request();
    if (permission.isGranted) {
      // getCurrentLocation();
    } else if (permission.isDenied) {
      // Handle denied permission (can show a message or request again)
      print('Location permission denied');
    } else if (permission.isPermanentlyDenied) {
      // Open settings for the user to manually enable the permission
      openAppSettings();
    }
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    const String firstApiUrl = Api.baseUrl;
    const String secondApiUrl = 'https://be.terrapipe.io';
    var dio = d.Dio();
    loading.value = true;

    try {
      var firstApiHeaders = {'Content-Type': 'application/json'};
      var secondApiHeaders = {'Content-Type': 'application/json'};
      var firstApiBody = jsonEncode({'email': email, 'password': password});
      var secondApiBody = jsonEncode({'email': email, 'password': password});
      var responses = await Future.wait([
        dio.post(firstApiUrl, data: firstApiBody, options: d.Options(headers: firstApiHeaders)),
        dio.post(secondApiUrl, data: secondApiBody, options: d.Options(headers: secondApiHeaders)),
      ]);
      var firstApiResponse = responses[0];
      var secondApiResponse = responses[1];
      if (firstApiResponse.statusCode == 200) {
        var firstApiData = firstApiResponse.data;
        // Process first API response
        if (firstApiData['message'] == 'Invalid email or password.') {
          showSnackBar(
              color: Colors.red,
              title: "Failed",
              message: "Invalid email or password");
          return;
        }

        // Save tokens and proceed
        await SharedPreference.instance.saveToken(firstApiData['access_token']);
        await SharedPreference.instance.saveRefreshToken(firstApiData['refresh_token']);
        await SharedPreference.instance.saveEmail(email);
        await getSecretApiKey();
      } else {
        showSnackBar(
            color: Colors.red,
            title: "Failed",
            message: "First API call failed");
        return;
      }

      if (secondApiResponse.statusCode == 200) {
        print("Second API Response: ${secondApiResponse.data}");
        var secondApiData = secondApiResponse.data;
        await SharedPreference.instance.savePiplineAccessToken(secondApiData['access_token']);
        await SharedPreference.instance.saveRefreshToken(secondApiData['refresh_token']);
        showSnackBar(
            color: Colors.green,
            title: "Success",
            message: "Login Successfully");
      } else {
        showSnackBar(
            color: Colors.red,
            title: "Failed",
            message:
                "Second API call failed: ${secondApiResponse.statusMessage}");
      }
    } on d.DioException catch (e) {
      showSnackBar(
          color: Colors.red,
          title: "Failure",
          message:
              e.response?.data?['message'] ?? "Unable to process your request");
      if (kDebugMode) {
        print("Error during API calls: ${e.response?.data}");
        print("Request URL: ${e.requestOptions.uri}");
        print("Request Data: ${e.requestOptions.data}");
      }
    } finally {
      loading.value = false;
    }
  }

  Future logout() async {
    const String url = '${Api.baseUrl}/logout';
    var dio = d.Dio();

    var refreshToken = await SharedPreference.instance.getRefreshToken();

    var headers = {
      'Authorization': 'Bearer $refreshToken',
    };
    try {
      isLogoutloading.value = true;
      update();

      var response = await dio.get(
        url,
        options: d.Options(headers: headers),
      );
      if (response.statusCode == 200) {
        var messasge = response.data;
        if (kDebugMode) {
          print('resposne: $messasge');
        }
        isLogoutloading.value = false;
        clearFields();

        Get.offAll(
          () => LoginPage(),
        );
      }
    } on d.DioException catch (e) {
      isLogoutloading.value = false;
      update();
      showSnackBar(
          color: Colors.red, title: "Failure", message: "Failed to logout");
      if (kDebugMode) {
        print("Logout error ::::::::::>>>>>>>>>>> $url");
        print('Request failed: ${e.response?.data}');
      }
      return null;
    }
  }

  Future getSecretApiKey() async {
    String url = '${Api.baseUrl}/generate-api-keys';
    var dio = d.Dio();
    var token = await SharedPreference.instance.getToken();
    try {
      if (token.isEmpty) {
        throw Exception('Token is missing. Please log in.');
      }

      loading.value = true;

      var headers = {'Authorization': 'Bearer $token'};

      var response = await dio.get(
        url,
        options: d.Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var message = response.data;

        String apiKey = message['api_key'];
        String clientSecret = message['client_secret'];
        await SharedPreference.instance.saveSecretKeys(apiKey, clientSecret);
        emailController.clear();
        passwordController.clear();
        Get.offAll(() =>  BottomBarView());

        print('Keys stored locally: api_key: $apiKey, client_secret: $clientSecret');
      } else {
        throw Exception('Failed to get secret key: ${response.statusMessage}');
      }
    } on d.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        Get.snackbar(
          'Session Expired',
          'Please log in again',
          colorText: Colors.white,
          backgroundColor: Colors.red,
        );
        Get.offAll(() => LoginPage());
      } else {
        showSnackBar(
          color: Colors.red,
          title: "Failure",
          message: "Failed to get secret keys",
        );
        if (kDebugMode) {
          print("Error ::::::::::>>>>>>>>>>> $url");
          print('Request failed: ${e.response?.data}');
        }
      }
    } finally {
      loading.value = false;
    }
  }
}
