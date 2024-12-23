import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Colors.dart';
import 'Fonts.dart';
import 'Utils.dart';
import 'size_config.dart';

class SingleParamHeader extends StatelessWidget {
  final String headerText;
  final String subHeaderText;
  final BuildContext context;
  final bool showQueryButton;
  final Function onBack;

  SingleParamHeader(this.headerText, this.subHeaderText, this.context,
      this.showQueryButton, this.onBack);

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(
          left: getScreenWidth(20),
          right: getScreenWidth(20),
          top: getScreenHeight(70)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Utils.clearToasts(context);
              onBack();
            },
            child: Container(
                padding: EdgeInsets.all(getScreenWidth(10)),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(getScreenWidth(50)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: getScreenWidth(18),
                  color: backButtonCircleIconColor,
                )),
          ),
          SizedBox(width: getScreenWidth(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headerText,
                  style: TextStyle(
                    fontSize: getScreenWidth(20),
                    height: 1.2,
                    fontFamily: ffGBold,
                    color: buttonBorderColor,
                  ),
                ),
                subHeaderText != ""
                    ? Text(
                        subHeaderText,
                        style: TextStyle(
                          fontSize: getScreenWidth(12),
                          fontFamily: ffGSemiBold,
                          color: buttonBorderColor,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          // headerText == 'Create Indent' ||
          //         headerText == 'Enter\nInvoice Details' ||
          //         headerText == 'Invoice Details'
          !showQueryButton
              ? SizedBox.shrink()
              : InkWell(
                  onTap: () async {
                    var url =
                        Uri.parse("https://logipace.mahindralogistics.com");
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
                        horizontal: headerText == 'Pending Assignment'
                            ? getScreenWidth(5)
                            : getScreenWidth(5),
                        vertical: getScreenHeight(8)),
                    decoration: BoxDecoration(
                      color: appDarkRed,
                      borderRadius: BorderRadius.circular(getScreenWidth(8)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Raise a query',
                          style: TextStyle(
                            fontSize: getScreenWidth(10),
                            fontFamily: ffGSemiBold,
                            color: white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: getScreenWidth(15),
                          height: getScreenWidth(15),
                          child: Image.asset(
                            'assets/images/queryAsk.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
