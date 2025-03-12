import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as d;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terrapipe/app/modules/auth/login_view/login_controller.dart';
import 'package:terrapipe/services/api.dart';
import 'package:terrapipe/utils/helper_functions.dart';

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  LoginController loginController=Get.put(LoginController());
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
  static const String _saltKey = "device_salt";
  static const String _deviceId = "device_hash";


  // Generate a random salt
  static String generateSalt({int length = 32}) {
    final Random random = Random.secure();
    final List<int> saltBytes = List<int>.generate(length, (i) => random.nextInt(256));
    return base64UrlEncode(saltBytes);
  }

  // Get Salt (Retrieve or Generate & Save)
  static Future<String> getDeviceSalt() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salt = prefs.getString(_saltKey);
    print("First Time Salt Created ::::::::::${salt}");
    if (salt == null) {
      salt = generateSalt(); // Generate new salt if not found
      await prefs.setString(_saltKey, salt); // Save for future use
    }

    return salt;
  }
  Future<String> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android device ID
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor!; // iOS device ID
    } else {
      return "Unknown Device";
    }
  }

// Generate SHA-256 Hash using Device ID + Salt
  Future<String> generateDeviceHash({deviceId,salt}) async {
    String deviceId = await getDeviceId();
    String salt =  await getDeviceSalt();
    String combined = deviceId + salt; // Combine device ID & salt
    List<int> bytes = utf8.encode(combined); // Convert to bytes
    Digest hash = sha256.convert(bytes); // Generate SHA-256 hash
    return hash.toString();
  }

  Future<void> hashSignup() async {

    String saltId =  await getDeviceSalt();
    String deviceId=await getDeviceId();
    debugPrint("Here is the Salt Data ::::: ${saltId}");
    debugPrint("Here is the DeviceId ::::: ${deviceId}");
    String deviceHash = await generateDeviceHash(deviceId: deviceId,salt: saltId);
    // HelperFunctions.saveInPreference(_deviceId,deviceHash);
    // debugPrint("🔐 Device SHA-256 Hash: $deviceHash");
    const String firstApiUrl = "${Api.baseUrl}/signup";
    var dio = d.Dio();
    try {
      var headers = {
        'Content-Type': 'application/json',
        'X-DEVICE-ID': deviceHash
      };
      var firstResponse = await dio.post(
        firstApiUrl,
        options: d.Options(headers: headers),
      );
      print("First API Response 200: ${firstResponse.statusCode}");
      if (firstResponse.statusCode == 201) {
        print("First API Response 200: ${firstResponse.data}");
        await loginController.hashLogin();
      }
      else {
        print("First API Response: ${firstResponse.data}");
      }
    } on d.DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? "An unexpected error occurred";
      if (kDebugMode) {
        print("Error during API calls: ${e.response?.data}");
      }
    } finally {

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


/// PREVIOUS LOGIN FUNCTION
//   Future<void> signup() async {
//   // final email = emailController.text.trim();
//   // final password = passwordController.text.trim();
//   // if (email.isEmpty || password.isEmpty) {
//   //   Get.snackbar('Error', 'Email and password cannot be empty',
//   //       snackPosition: SnackPosition.BOTTOM);
//   //   return;
//   // }
//
//   const String firstApiUrl = "${Api.baseUrl}/signup";
//   const String secondApiUrl = "https://be.terrapipe.io/signup";
//
//   var dio = d.Dio();
//   loading.value = true;
//   update();
//
//   try {
//     // First API body
//     var firstApiBody = {
//       'email': email,
//       'password': password,
//       'phone_num': phoneNumber.text.trim(),
//       'confirm_pass': confirmPasswordController.text.trim(),
//       'newsletter': 'checked',
//       'discoverable': '',
//     };
//
//     // Second API body
//     var secondApiBody = {
//       'email': email,
//       'password': password,
//       'phone_number': phoneNumber.text.trim(),
//       'confirm_password': confirmPasswordController.text.trim(),
//     };
//
//     var headers = {'Content-Type': 'application/json'};
//
//     // First API Call
//     var firstResponse = await dio.post(
//       firstApiUrl,
//       data: json.encode(firstApiBody),
//       options: d.Options(headers: headers),
//     );
//
//     if (firstResponse.statusCode == 200) {
//       print("First API Response: ${firstResponse.data}");
//       // showSnackBar(
//       //   color: Colors.green,
//       //   title: "Success",
//       //   message: "First API call succeeded. Proceeding to next step...",
//       // );
//
//       // Second API Call
//       var secondResponse = await dio.post(
//         secondApiUrl,
//         data: json.encode(secondApiBody),
//         options: d.Options(headers: headers),
//       );
//
//       if (secondResponse.statusCode == 200) {
//         print("Second API Response: ${secondResponse.data}");
//         showSnackBar(
//           color: Colors.green,
//           title: "Success",
//           message: "Signup successful. Please verify your email.",
//         );
//
//         // Navigate to login page after successful signup
//         Get.offAll(() => LoginPage());
//       } else {
//         print("Second API Response: ${secondResponse.data}");
//         showSnackBar(
//           color: Colors.red,
//           title: "Error",
//           message: "Second API call failed. ${secondResponse.statusMessage}",
//         );
//       }
//     } else {
//       print("First API Response: ${firstResponse.data}");
//       showSnackBar(
//         color: Colors.red,
//         title: "Error",
//         message: "First API call failed. ${firstResponse.statusMessage}",
//       );
//     }
//   } on d.DioException catch (e) {
//     final errorMessage =
//         e.response?.data['message'] ?? "An unexpected error occurred";
//     showSnackBar(
//       color: Colors.red,
//       title: "Failure",
//       message: errorMessage,
//     );
//
//     if (kDebugMode) {
//       print("Error during API calls: ${e.response?.data}");
//     }
//   } finally {
//     loading.value = false;
//     update();
//   }
// }
}
