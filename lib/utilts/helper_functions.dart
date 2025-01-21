import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terrapipe/utilts/app_colors.dart';

class HelperFunctions {
  static Future<File?> pickImage(ImageSource imageSource) async {
    File imageFile;
    final file =
    await ImagePicker().pickImage(source: imageSource, imageQuality: 20);
    if (file != null) {
      imageFile = File(file.path);
      return imageFile;
    } else {
      print("No image selected");
    }
    return null;
  }

  static saveInPreference(String preName, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(preName, value);
  }

  static Future<String> getFromPreference(String preName) async {
    String returnValue = "";

    final prefs = await SharedPreferences.getInstance();
    returnValue = prefs.getString(preName) ?? "";
    return returnValue;
  }

  static saveBoolInPreference(String preName,  value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preName, value);
  }

  static Future<bool> getBoolFromPreference(String preName) async {
    bool returnValue = false;
    final prefs = await SharedPreferences.getInstance();
    returnValue = prefs.getBool(preName) ?? false;
    return returnValue;
  }

  Future<bool> clearPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    return true;
  }
}

Future<bool> signout() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  return true;
}

Future<void> showSnackBar(
    {title,
      message,
      color = Colors.red,
      position = SnackPosition.BOTTOM,
      duration = 4}) async {
  Get.snackbar(title, message,
      duration: Duration(seconds: duration),
      colorText: AppColor.white,
      backgroundColor: color,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      snackPosition: position,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10));
}
