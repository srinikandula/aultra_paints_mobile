import '/utility/size_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Colors.dart';
import 'Fonts.dart';
import 'Utils.dart';

Widget getHeader(BuildContext context, bool isQuery, String header) {
  return Container(
    color: Colors.white,
    margin: EdgeInsets.only(
        left: getProportionateScreenWidth(20),
        top: getProportionateScreenWidth(70)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context, true);
          },
          child: Container(
              padding: EdgeInsets.all(getProportionateScreenWidth(10)),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(getProportionateScreenWidth(50)),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: getProportionateScreenWidth(22),
                color: backButtonCircleIconColor,
              )),
        ),
        SizedBox(width: getProportionateScreenWidth(20)),
        Text(
          header,
          style: TextStyle(
              fontSize: getProportionateScreenWidth(20),
              fontFamily: ffGBold,
              height: 1.2,
              color: buttonBorderColor),
        ),
        header == "EPOD Copy"
            ? SizedBox(width: getProportionateScreenWidth(50))
            : SizedBox(width: getProportionateScreenWidth(70)),
        isQuery
            ? InkWell(
                onTap: () async {
                  var url = Uri.parse("https://logipace.mahindralogistics.com");
                  try {
                    if (await canLaunchUrl(url)) {
                      Utils.openUrl(url);
                    } else {
                      _showSnackBar(
                          "Could not open URL in browser.", context, false);
                    }
                  } catch (e) {
                    _showSnackBar(
                        "Failed to open URL in browser.", context, false);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(8),
                      vertical: getProportionateScreenWidth(8)),
                  decoration: BoxDecoration(
                    color: appDarkRed,
                    borderRadius:
                        BorderRadius.circular(getProportionateScreenWidth(8)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Raise a query',
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(10),
                          fontFamily: ffGSemiBold,
                          color: white,
                        ),
                      ),
                      SizedBox(width: getProportionateScreenWidth(8)),
                      SizedBox(
                        width: getProportionateScreenWidth(15),
                        height: getProportionateScreenWidth(15),
                        child: Image.asset(
                          'assets/images/queryAsk.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ],
    ),
  );
}

void _showSnackBar(String message, BuildContext context, ColorCheck) {
  final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: ColorCheck ? Colors.green : Colors.red,
      duration: Utils.returnToastDuration());
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
