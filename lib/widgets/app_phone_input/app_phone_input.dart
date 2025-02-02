import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';

class AppPhoneInput extends StatelessWidget {
  const AppPhoneInput({
    super.key,
    required this.onChanged,
    required this.onCountryChanged,
    this.errorText,
    this.controller,
    this.initialCountryCode = 'AE',
  });

  final ValueChanged<PhoneNumber?> onChanged;
  final String? errorText;
  final TextEditingController?  controller;
  final ValueChanged<Country> onCountryChanged;
  final String? initialCountryCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntlPhoneField(
          sheetTitle: "Select Country",
          searchText: "Select Country",
          dropdownIconPosition: IconPosition.trailing,
          controller: controller,
          initialCountryCode: initialCountryCode,
          dropdownIcon: Icon(
            Icons.arrow_drop_down,
            size: 25,
            color: AppColor.white,
          ),
          pickerDialogStyle: PickerDialogStyle(
              backgroundColor: AppColor.white,
              countryNameStyle:  TextStyle(color: AppColor.black)),
          flagsButtonPadding: const EdgeInsets.only(left: 5),
          onCountryChanged: onCountryChanged,
          dropdownTextStyle:  TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15, color: AppColor.white),
          style:  TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15, color: AppColor.white),
          decoration:  InputDecoration(
            hintText: 'Enter your number',
            labelStyle:  TextStyle(color: AppColor.white),
            hintStyle:  TextStyle(color: AppColor.grey, fontSize: 14),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12), // Adjust the radius value as needed
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
              borderSide: BorderSide(
                color: AppColor.white,
                width: 1.0,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        if (errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16, right: 16),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColor.red,
                fontSize: 9,
              ),
            ),
          )
      ],
    );
  }
}
