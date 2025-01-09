import 'dart:convert';
import 'dart:io';

import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Colors.dart';
import 'Fonts.dart';

//AES/CBC/PKCS7Padding

//1234567890123456

class Utils {
  static var labelLarge;
 

  static List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();

  static void showSheet(
    BuildContext context, {
    required Widget child,
    required VoidCallback onClicked,
  }) =>
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            child,
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Done'),
            onPressed: onClicked,
          ),
        ),
      );

  static void showMuliButtonSheet(
    BuildContext context, {
    required Widget child,
    required Widget button,
    required VoidCallback onClicked,
  }) =>
      showCupertinoModalPopup(
        barrierColor: modalBgDisableColor,
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            child,
            // button,
          ],
          cancelButton: InkWell(
            child: button,
            onTap: onClicked,
          ),
        ),
      );

  static void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text, style: TextStyle(fontSize: 24)),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static getCurrentDate() {
    return DateFormat('yyyy/MM/dd').format(DateTime.now());
  }

  static returnRedStar() {
    return Text(
      '*',
      style: TextStyle(
          fontSize: getScreenWidth(22),
          fontFamily: ffGMedium,
          color: appDarkRed),
    );
  }

  static returnInvoiceRedStar(title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: getScreenWidth(16),
              fontFamily: ffGMedium,
              color: textInputHeadingColor),
        ),
        // Utils.returnRedStar() //instead adding optional text for non mandatory
      ],
    );
  }

  static returnIndentRedStar(title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: getScreenWidth(16),
            fontFamily: ffGMedium,
          ),
        ),
        // Utils.returnRedStar()  //instead adding optional text for non mandatory
      ],
    );
  }

  static returnIndentColumnText() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Dedicated vehicle\nAllotment',
            style: TextStyle(
              fontSize: getScreenWidth(16),
              fontFamily: ffGMedium,
              color: Colors.black,
            ),
          ),
          // TextSpan(
          //   text: ' *',
          //   style: TextStyle(
          //     fontSize: getScreenWidth(22),
          //     fontFamily: ffGMedium,
          //     color: appDarkRed,
          //   ),
          // ),
        ],
      ),
    );
  }

  static returnOptionalText(title) {
    return Row(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: getScreenWidth(16),
            fontFamily: ffGMedium,
          ),
        ),
        Text(
          ' (Optional)',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: getScreenWidth(10),
              fontFamily: ffGRegular,
              color: DetailsSubListColor),
        )
      ],
    );
  }

  static getCurrentDateDMY() {
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day);
    return date;
  }

  static returnToastDuration() {
    return Duration(milliseconds: 2000);
  }

  static returnStatusToastDuration(status) {
    return status ? Duration(milliseconds: 800) : Duration(seconds: 5);
  }

  static getCurrentDateDMYupdated(DateTime dateTime) {
    // print('reached updated');
    // DateTime now = new dateTime.now();
    DateTime date = new DateTime(dateTime.year, dateTime.month, dateTime.day);
    return date;
  }

  static returnActualDateFormat(hintDate) {
    // print('reached start');
    // var oldDateStr = DateTime.parse(hintDate.toString());
    // print('reached mid');
    // var tempMonth = oldDateStr.month <= 9
    //     ? '0' + oldDateStr.month.toString()
    //     : oldDateStr.month.toString();
    // var tempDay = oldDateStr.day <= 9
    //     ? '0' + oldDateStr.day.toString()
    //     : oldDateStr.day.toString();
    // print('reached last');
    // var tempDate = oldDateStr.year.toString() + '-' + tempMonth + '-' + tempDay;

    // var finalStamp = tempDate;
    // print('finalStamp=========> $finalStamp');
    // return finalStamp;
    return DateFormat('yyyy-MM-dd').format(hintDate);
  }

  static returnBasedHoursonPM(setDate) {
    // print('setDate PM=== $setDate');
    if (setDate == '01') {
      return '13';
    } else if (setDate == '02') {
      return '14';
    } else if (setDate == '03') {
      return '15';
    } else if (setDate == '04') {
      return '16';
    } else if (setDate == '05') {
      return '17';
    } else if (setDate == '06') {
      return '18';
    } else if (setDate == '07') {
      return '19';
    } else if (setDate == '08') {
      return '20';
    } else if (setDate == '09') {
      return '21';
    } else if (setDate == '10') {
      return '22';
    } else if (setDate == '11') {
      return '23';
    } else if (setDate == '12') {
      return '00';
    } else if (setDate == '00') {
      return '12';
    }
  }

  static returnBasedHoursonAM(setDate) {
    // print('setDate AM=== $setDate');
    if (setDate == '12') {
      return '00';
    } else if (setDate == '13') {
      return '01';
    } else if (setDate == '14') {
      return '02';
    } else if (setDate == '15') {
      return '03';
    } else if (setDate == '16') {
      return '04';
    } else if (setDate == '17') {
      return '05';
    } else if (setDate == '18') {
      return '06';
    } else if (setDate == '19') {
      return '07';
    } else if (setDate == '20') {
      return '08';
    } else if (setDate == '21') {
      return '09';
    } else if (setDate == '22') {
      return '10';
    } else if (setDate == '23') {
      return '11';
    } else if (setDate == '00') {
      return '12';
    }
  }

  static returnFilterDateFormat(hintDate) {
    return DateFormat('yyyy,MM,dd').format(hintDate);
  }

  static clearToasts(context) {
    return ScaffoldMessenger.of(context).clearSnackBars();
  }

  // static showLoading() {
  //   EasyLoading.show(status: 'loading...');
  // }

  // static hideLoading() {
  //   EasyLoading.dismiss();
  // }

  static isValidEmail(email) {
    // Check if this field is empty
    // if (email == null || email.isEmpty) {
    //   return 'This field is required';
    // }

    // // using regular expression
    // if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
    //   return "Please enter a valid email address";
    // }
    String valueText = '';

    if (email) {
      if (RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
        // valueText = LodashFlutter.toLowerCase(email).toString();
      } else {
        valueText = "Please enter a valid email address";
      }
    } else {
      valueText = 'Please enter email address';
    }

    return 'true';
  }

  static returnScreenLoader(BuildContext context) {
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
                Container(
                  margin: EdgeInsets.only(left: getProportionateScreenHeight(80), right: getProportionateScreenHeight(10)),
                  child: SizedBox(
                    // width: getProportionateScreenWidth(500),
                    // height: getProportionateScreenWidth(250),
                    child: Image.asset(
                      'assets/images/app_logo_load.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // margin: EdgeInsets.only(top: getProportionateScreenHeight(80), right: getProportionateScreenHeight(10)),
                      child: Text(
                        "Loading...",
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
  }

  static returnDashboardScreenLoader(BuildContext context) {
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
                Container(
                  margin: EdgeInsets.only(left: getProportionateScreenHeight(80), right: getProportionateScreenHeight(10)),
                  child: SizedBox(
                    // width: getProportionateScreenWidth(500),
                    // height: getProportionateScreenWidth(250),
                    child: Image.asset(
                      'assets/images/app_logo_load.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      // margin: EdgeInsets.only(top: getProportionateScreenHeight(80), right: getProportionateScreenHeight(10)),
                      child: Text(
                        "Loading...",
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
  }

  static openUrl(Uri uri) async {
    if (Platform.isIOS) {
      await launchUrl(uri);
    } else {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
