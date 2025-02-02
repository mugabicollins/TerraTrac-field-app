import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:terrapipe/app/modules/saved_fields/controllers/saved_field_controller.dart';
import 'package:terrapipe/utils/constants/app_colors.dart';
import 'package:terrapipe/widgets/app_buttons/custom_button.dart';

class ScoreDialog extends StatefulWidget {
  @override
  State<ScoreDialog> createState() => _ScoreDialogState();
}

class _ScoreDialogState extends State<ScoreDialog> {
  SavedFieldController savedFieldController = Get.put(SavedFieldController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Deforestation Scores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Terrapipe TMF Score: ${double.parse(savedFieldController.terraPipeTMFScore.value).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Whisp TMF Score: ${double.parse(savedFieldController.wispTMFScore.value).toStringAsFixed(2)}%',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            CustomButton(
                label: "Close",
                color: AppColor.primaryColor,
                width: Get.width*0.4,
                onTap: () {
                  Get.back();
                })
          ],
        ),
      ),
    );
  }
}
