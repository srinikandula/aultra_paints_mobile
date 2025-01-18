import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/config.dart';
import '../../../services/error_handling.dart';
import '../../../utility/SingleParamHeader.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_mobile_vision/qr_camera.dart';
import 'package:http/http.dart' as http;

class QrScanner extends StatefulWidget {
  const QrScanner({Key? key}) : super(key: key);

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  int? selected;

  var accesstoken;
  var USER_ID;
  var Company_ID;

  var ewbNumber;

  var argumentData;
  bool allowScanner = true;

  var scannedValue;

  @override
  void initState() {
    fetchLocalStorageDate();
    super.initState();
  }

  fetchLocalStorageDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    // sendScannedValue('a5be85ed-4b0d-480c-9851-9864638b89f5');

    // final apiResponse = {
    //   "message": "Coupon redeemed Successfully..!",
    //   "data": {
    //     "qr_code_id": "433b889c-b38f-4bd9-89f9-0498a5d8dfa6",
    //     "isProcessed": true,
    //     "updatedBy": "6771ab7eedc91a9596744def",
    //     "redeemablePoints": 5
    //   }
    // };

    // showApiResponsePopup(context, apiResponse);
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future sendScannedValue(scannedValue) async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var QRCodeId = scannedValue.split('tx=')[1];
    var apiUrl = BASE_URL + GET_SCANNED_DATA + QRCodeId;

    response = await http.patch(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": accesstoken
    });
    print('--=scan url===>${apiUrl}');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      var apiResp = json.decode(response.body);
      print('scan resp=====>${apiResp}');
      // _showSnackBar(apiResp['message'], context, true);
      // Navigator.pop(context, true);
      showApiResponsePopup(context, apiResp);
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
      setState(() {
        allowScanner = true;
      });
    }
  }

  onBackPressed() {
    Utils.clearToasts(context);
    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  Future<bool> _onWillPop() async {
    onBackPressed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: whiteBgColor,
        body: Column(
          children: [
            SingleParamHeader('QR Scanner', '', context, false,
                () => Navigator.pop(context, true)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        color: greyButtonBgColor,
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.03,
                            right: MediaQuery.of(context).size.width * 0.03),
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: allowScanner == false
                            ? null
                            : QrCamera(
                                qrCodeCallback: (code) {
                                  HapticFeedback.vibrate();
                                  print(
                                      'scanned code==== $code, ${code.runtimeType}');
                                  if (code != null) {
                                    setState(() {
                                      allowScanner = false;
                                    });
                                    sendScannedValue(code);
                                  }
                                },
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showApiResponsePopup(BuildContext context, Map<String, dynamic> response) {
    final message = response["message"] ?? "No message";
    final data = response["data"] ?? {};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
              // onWillPop: () async => true,
              onWillPop: _onWillPop,
              // onWillPop: () async => {
              //   Navigator.pop(context, true);
              //   return true;
              // },
              child: Dialog(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                child: Container(
                  width: 100,
                  // height: 300,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      Container(
                        child: Center(
                          child: Text("${data['cash'] ?? 0} ₹", style: TextStyle(fontSize: 80, color: Colors.white, fontFamily: ffGSemiBold,),),
                        ),
                      ),
                      // Text(message, style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: ffGSemiBold,)),
                      SizedBox(height: 40),
                      Container(
                        child: Center(
                          child: Text("Coupon Redeemed from Aultra Paints.", style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: ffGSemiBold,), textAlign: TextAlign.center,),
                        )
                      ),
                      SizedBox(height: 20),
                      Container(
                        child: Center(
                          child: Text("With Coupon : ${data['couponCode'] ?? 0}", style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: ffGSemiBold,),),
                        )
                      ),
                      // SizedBox(height: 2),
                      // Text("Reward Points: ${data['rewardPoints'] ?? 0}", style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: ffGSemiBold,),),
                      // SizedBox(height: 40),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                            Navigator.pop(context, true);
                          },
                          child: Text("OK", style: TextStyle(fontSize: 14, color: Colors.white, fontFamily: ffGSemiBold,)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
