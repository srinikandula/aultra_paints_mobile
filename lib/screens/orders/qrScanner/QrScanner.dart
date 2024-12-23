import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/validations.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

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
    USER_ID = prefs.getInt('USER_ID');
    Company_ID = prefs.getInt('Company_ID');
    argumentData = ModalRoute.of(context)!.settings.arguments;
    // print('argumentData====>$argumentData');
    setState(() {
      argumentData;
    });
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  handleScannedData(code) {
    // String input = '391854688091/05AAACM3025E1Z5/9/29/2024 8:33:00 AM';
    String input = code;

    List<String> parts = input.split('/');

    // for (int i = 0; i < parts.length; i++) {
    //   print('Part $i: ${parts[i]}');
    // }

// Optionally, you can handle specific parts if you know their purpose
    // if (parts.length >= 3) {
    String ewayBillNumber = parts[0];
    // String gstNumber = parts[1];
    // String dateTimePart = parts.sublist(2).join(
    //     '/'); // Join remaining parts in case date/time has multiple slashes

    // try {
    //   DateTime dateTime =
    //       DateFormat('M/d/yyyy h:mm:ss a').parse(dateTimePart);
    //   print('Date and Time: $dateTime');
    // } catch (e) {
    //   print('Failed to parse date and time: $e');
    // }

    print('E-Way Bill: $ewayBillNumber');
    // print('GST Number: $gstNumber');
    // print('DateTime Part: $dateTimePart');

    // }

    // if (ewayBillNumber) {
    var tempData = {
      'lrNumber': argumentData['lrNumber'],
      'pageSelection': argumentData['pageSelection'],
      'ewbNumber': ewayBillNumber
    };
    tempData['ewbNumber'] = ewayBillNumber;
    print('mobile tempData====>$tempData');
    // setState(() {
    //   allowScanner = false;
    // });
    // tempData['lrNumber'] = argumentData['lrNumber'];
    Navigator.pushNamed(context, '/invoiceDetailsForm', arguments: tempData)
        .then((_) {
      setState(() {
        allowScanner = false;
      });
    });
    // } else {
    //   _showSnackBar("Scan valid QR Code", context, false);
    //   setState(() {
    //     allowScanner = false;
    //   });
    // }
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
                      // InkWell(
                      //   onTap: () {
                      //     var tempData = {
                      //       'lrNumber': argumentData['lrNumber'],
                      //       'pageSelection': argumentData['pageSelection'],
                      //       'ewbNumber': '261842331659'
                      //     };
                      //     tempData['ewbNumber'] = '261842331659';
                      //     print('manual scan tempData====>$tempData');
                      //     setState(() {
                      //       allowScanner = false;
                      //     });
                      //     Navigator.pushNamed(context, '/invoiceDetailsForm',
                      //             arguments: tempData)
                      //         .then((result) {
                      //       if (result == true) {
                      //         setState(() {
                      //           allowScanner = true;
                      //         });
                      //       }
                      //     });
                      //   },
                      //   child: Text("HELLO PRAVEEN \n SCREN CHGANGE"),
                      // ),
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
                                  // print(
                                  //     'scanned code==== $code, ${code.runtimeType}');
                                  if (code != null) {}
                                  // handleScannedData(code);
                                  // //====
                                  List<String> parts = code!.split('/');
                                  String ewayBillNumber = parts[0];
                                  // print('E-Way Bill: $ewayBillNumber');

                                  if (ewayBillNumber.isNotEmpty &&
                                      ewbNumberLenghtRegex
                                          .hasMatch(ewayBillNumber)) {
                                    var tempData = {
                                      'lrNumber': argumentData['lrNumber'],
                                      'pageSelection':
                                          argumentData['pageSelection'],
                                      'ewbNumber': ewayBillNumber
                                    };
                                    tempData['ewbNumber'] = ewayBillNumber;
                                    // print('scanned tempData====>$tempData');
                                    setState(() {
                                      allowScanner = false;
                                    });
                                    Navigator.pushNamed(
                                            context, '/invoiceDetailsForm',
                                            arguments: tempData)
                                        .then((result) {
                                      if (result == true) {
                                        setState(() {
                                          allowScanner = true;
                                        });
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      allowScanner = false;
                                    });
                                    // Directly display an AlertDialog if ewayBillNumber is invalid
                                    AlertDialog alert = AlertDialog(
                                      title: Text('Invalid QR Code'),
                                      content: Text(
                                          'Please scan a valid 12-digit E-Way Bill number QR Code.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            setState(() {
                                              allowScanner = true;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            alert);
                                  }

                                  //     .then((_) {
                                  //   setState(() {
                                  //     // allowScanner = false;
                                  //   });
                                  // });

                                  //==================
                                  // if (code != null) {
                                  //   String? text = code;

                                  //   var charCheck = text.contains('/');
                                  //   if (charCheck) {
                                  //     List<String>? substrings = text.split("/");
                                  //     print('substrings====>${substrings}');
                                  //     scannedValue = substrings[0];

                                  //     if (scannedValue != null) {
                                  //       handleScannedData(scannedValue);
                                  //     } else {
                                  //       _showSnackBar("Please scan valid QR code",
                                  //           context, false);
                                  //       setState(() {
                                  //         allowScanner = true;
                                  //       });
                                  //     }
                                  //   } else {
                                  //     _showSnackBar("Please scan valid QR code",
                                  //         context, false);
                                  //     setState(() {
                                  //       allowScanner = true;
                                  //     });
                                  //   }
                                  // } else {
                                  //   _showSnackBar(
                                  //       "No Data Present,Please try again",
                                  //       context,
                                  //       false);
                                  //   setState(() {
                                  //     allowScanner = true;
                                  //   });
                                  // }
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

  Widget returnBottomButton() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(width: 1, color: appThemeColor),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: appThemeColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            alignment: Alignment.center,
            height: screenHeight * 0.07,
            child: const Text(
              "Confirm",
              style: TextStyle(
                fontFamily: ffGSemiBold,
                fontSize: 18.0,
                color: buttonTextWhiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
