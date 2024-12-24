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

    response = await http
        .patch(Uri.parse(BASE_URL + GET_SCANNED_DATA + scannedValue), headers: {
      "Content-Type": "application/json",
      "accesstoken": accesstoken
    });
    print('--=scan url===>${BASE_URL + GET_SCANNED_DATA + scannedValue}');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      print('scan resp=====>${response.body}');
      Navigator.pop(context, true);
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
}
