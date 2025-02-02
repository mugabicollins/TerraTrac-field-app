import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class BounceAbleLoader extends StatelessWidget {
   BounceAbleLoader({super.key, this.title = '', this.subTitile,
    this.loadingColor=Colors.white,
     this.textColor=Colors.white
  });

  Color textColor;
  Color loadingColor;
  final String? title;
  final String? subTitile;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           SpinKitThreeBounce(
            size: 30,
            color: loadingColor,
          ),
          SizedBox(
            height: Get.height * 0.05,
          ),
          Text(
            title.toString(),
            style:  TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
           Text(
            "Please Wait",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
