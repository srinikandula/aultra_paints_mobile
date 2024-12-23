import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Colors.dart';
import 'Fonts.dart';

Widget FooterButton(String ButtonTitle, String buttonFrom, BuildContext context,
    Function navigationRoute) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  return Container(
    child: InkWell(
      onTap: () {
        navigationRoute();
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01,
            horizontal: screenWidth *
                (buttonFrom == 'download'
                    ? 0.03
                    : buttonFrom == 'fullWidth'
                        ? 0
                        : 0.08)),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(getScreenWidth(10))),
            side: BorderSide(width: 1, color: appDarkRed),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: appDarkRed,
              borderRadius:
                  BorderRadius.all(Radius.circular(getScreenWidth(10))),
            ),
            alignment: Alignment.center,
            height: getScreenHeight(60),
            child: Text(
              ButtonTitle,
              style: TextStyle(
                fontFamily: ffGSemiBold,
                fontSize: getScreenWidth(16),
                color: white,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
