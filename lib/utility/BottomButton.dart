// BottomButton

import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Colors.dart';
import 'Fonts.dart';

Widget BottomButton(
    String ButtonTitle, BuildContext context, Function navigationRoute) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  return Container(
    child: InkWell(
      onTap: () {
        navigationRoute();
      },
      child: Container(
        margin: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.09,
            right: screenWidth * 0.09),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(getScreenWidth(15))),
            side: BorderSide(width: 1, color: appThemeColor),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: appThemeColor,
              borderRadius:
                  BorderRadius.all(Radius.circular(getScreenWidth(15))),
            ),
            alignment: Alignment.center,
            height: screenHeight * 0.06,
            child: Text(
              ButtonTitle,
              style: TextStyle(
                fontFamily: ffGSemiBold,
                fontSize: getScreenWidth(18),
                color: buttonTextWhiteColor,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
