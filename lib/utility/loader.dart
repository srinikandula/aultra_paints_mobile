import 'dart:convert';

import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:lodash_flutter/lodash_flutter.dart';
import '../model/request/inbound_pdi_request.dart';
import '../model/request/outbound_pdi_request.dart';
import 'Colors.dart';
import 'Fonts.dart';


class Loader {
  static bool _isLoaderVisible = false;
  static String msg = "0";
  static showLoader(BuildContext context) {
    if (!_isLoaderVisible) {
      _isLoaderVisible = true;
      SizeConfig().init(context);
      showGeneralDialog(
        context: context,
        barrierColor: colorC8C7C7.withOpacity(0.9),
        // barrierColor: Colors.black12.withOpacity(0.6), // Background color
        barrierDismissible: false,
        // barrierLabel: 'Dialog',
        // transitionDuration: Duration(milliseconds: 400),
        pageBuilder: (context, __, ___) {
          return Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    // width: getProportionateScreenWidth(500),
                    // height: getProportionateScreenWidth(250),
                    child: Image.asset(
                      'assets/images/loader.gif',
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: getProportionateScreenHeight(80), right: getProportionateScreenHeight(10)),
                        child: Text(
                          "Loading",
                          style: TextStyle(
                              fontSize: getProportionateScreenWidth(20),
                              fontFamily: ffGBold,
                              color: black),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          );
        },
      );

      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder: (BuildContext context) {
      //     return Dialog(
      //       backgroundColor: Colors.transparent,
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           SizedBox(
      //             width: getProportionateScreenWidth(200),
      //             height: getProportionateScreenWidth(100),
      //             child: Image.asset(
      //               'assets/images/loader.gif',
      //               fit: BoxFit.fill,
      //             ),
      //           ),
      //           // SizedBox(height: getProportionateScreenWidth(20)),
      //           // Text(
      //           //   "Loading",
      //           //   style: TextStyle(
      //           //       fontSize: getProportionateScreenWidth(20),
      //           //       fontFamily: ffGBold,
      //           //       color: black),
      //           // )
      //         ],
      //       ),
      //     );
      //   },
      // );
    }
  }

  static void hideLoader(BuildContext context) {
    if(_isLoaderVisible) {
      _isLoaderVisible = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
