import 'dart:async';
import 'dart:convert';

import '../../../utility/loader.dart';
import '/utility/check_internet.dart';
import '/utility/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/config.dart';
import '../../../utility/Utils.dart';
import '../../../utility/validations.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';

import 'package:http/http.dart' as http;
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected = 1;

  late var names = [];
  late var totalList = [];
  late var searchData = [];

  var stringResponse = '';
  Map mapResponse = {};

  // var verificationCode;

  var loggedUserName;
  var loggedUserPhoneNumber;
  var loggedUserRole;
  bool isOTPButtonEnabled = true;
  int resendDelay = 90;
  Timer? timer;

  // Initialize FocusNodes and Controllers as class-level variables
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());
  String verificationCode = '';

  @override
  void dispose() {
    // Dispose the controllers and focus nodes when the widget is disposed
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    for (var controller in controllers) {
      controller.dispose();
    }
    timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    fetchArguments();
    super.initState();
  }

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }

  onBackPressed() {
    Utils.clearToasts(context);
    Navigator.pop(context, true);
  }

  fetchArguments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedUserName = prefs.getString('loggedUserName');
    loggedUserPhoneNumber = prefs.getString('loggedUserPhoneNumber');
    loggedUserRole = prefs.getString('loggedUserRole');
    setState(() {
      loggedUserName;
      loggedUserPhoneNumber;
    });
    startOTPTimer();
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> onVerifyOTP(otpCodes) async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {"phoneNumber": loggedUserPhoneNumber, "otp": otpCodes};
    var body = json.encode(map);
    print('otp body===>${body}');
    response = await http.post(Uri.parse(BASE_URL + POST_DRIVER_OTP),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // print('otp resp ==== $mapResponse');
      Navigator.pop(context);
      _showSnackBar(
          mapResponse['message'], context, mapResponse["status"] == "success");
      if (mapResponse["status"] == "success") {
        var userData = mapResponse['data'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', userData['accessToken']);
        await prefs.setString('USER_NAME', userData['USER_NAME']);
        await prefs.setInt('USER_ID', userData['USER_ID']);
        await prefs.setString('BACKEND_ROLE', userData['roles'][0]);
        await prefs.setInt('Company_ID', 0);
        Navigator.pushNamed(context, '/dashboardPage');
      }
    } else {
      _showSnackBar(mapResponse['message'], context, false);
      Navigator.pop(context);
    }
  }

  Widget returnOTPfields() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 20),
      width: getProportionateScreenWidth(300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return SizedBox(
            width: getProportionateScreenWidth(43),
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              style: TextStyle(
                fontSize: getProportionateScreenWidth(24),
                fontFamily: ffGSemiBold,
                color: otpTextinputColor,
              ),
              decoration: const InputDecoration(
                fillColor: whiteBgColor,
                counterText: "", // Hide the counter text (default "0/1")
                border: OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(1.0),
                  borderSide: BorderSide(color: otpTextinputBorderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(1.0),
                  borderSide: BorderSide(color: otpTextinputColor),
                ),
                filled: true,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (index < focusNodes.length - 1) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                } else if (index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
                setState(() {
                  verificationCode =
                      controllers.map((controller) => controller.text).join('');
                });
              },
              onSubmitted: (value) {
                if (index == focusNodes.length - 1) {
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  // returnOTPfields() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: List.generate(6, (index) {
  //       return SizedBox(
  //         width: 50,
  //         child: TextField(
  //           keyboardType: TextInputType.number,
  //           textAlign: TextAlign.center,
  //           maxLength: 1,
  //           style: const TextStyle(
  //             fontSize: 24,
  //             fontFamily: ffGSemiBold,
  //             color: otpTextinputColor,
  //           ),
  //           decoration: InputDecoration(
  //             counterText: '',
  //             border: OutlineInputBorder(
  //               borderSide: BorderSide(color: otpTextinputBorderColor),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide:
  //                   BorderSide(color: otpTextinputBorderColor, width: 2.0),
  //             ),
  //             filled: true,
  //             fillColor: whiteBgColor,
  //           ),
  //           inputFormatters: [
  //             FilteringTextInputFormatter.digitsOnly,
  //             LengthLimitingTextInputFormatter(1),
  //           ],
  //           onChanged: (value) {
  //             if (value.isNotEmpty && index < 5) {
  //               FocusScope.of(context).nextFocus();
  //             } else if (value.isEmpty && index > 0) {
  //               FocusScope.of(context).previousFocus();
  //             }
  //           },
  //         ),
  //       );
  //     }),
  //   );
  // }

// Add this method to clear the fields when OTP is resent
  void clearOTPFields() {
    for (var controller in controllers) {
      controller.clear();
    }
    setState(() {
      verificationCode = '';
    });
  }

  void startOTPTimer() {
    setState(() {
      isOTPButtonEnabled = false;
      resendDelay = 90;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendDelay == 0) {
        setState(() {
          isOTPButtonEnabled = true;
        });
        timer.cancel();
      } else {
        setState(() {
          resendDelay--;
        });
      }
    });
  }

  resendOTP() async {
    startOTPTimer();
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "password": "",
      "username": "",
      "userType": loggedUserRole,
      "phoneNumber": loggedUserPhoneNumber
    };
    var body = json.encode(map);
    // print('otp body===>$body');
    response = await http.post(Uri.parse(BASE_URL + POST_LOGIN_DETAILS),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print('otp resp ==== $mapResponse');
      clearOTPFields();
      Navigator.pop(context);
      _showSnackBar(
          mapResponse['message'], context, mapResponse["status"] == "success");
    } else {
      _showSnackBar(mapResponse['message'], context, false);
      Navigator.pop(context);
    }
  }

  Future<bool> _onWillPop() async {
    onBackPressed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: loginBgColor,
        body: SafeArea(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          color: loginBgColor,
                          child: Column(
                            children: [
                              Container(
                                  child: Stack(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: getProportionateScreenWidth(20)),
                                    width: screenWidth,
                                    height: getProportionateScreenHeight(250),
                                    child: Image.asset(
                                      'assets/images/warehouse_image.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    top: screenHeight * 0.01,
                                    left: screenWidth * 0.07,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        onBackPressed();
                                      },
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        color: backButtonColor,
                                        size: 20,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: backButtonBgColor,
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                              Container(
                                width: screenWidth * 0.8,
                                height: getProportionateScreenHeight(40),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logiFreight_logo.png',
                                      height: getProportionateScreenHeight(40),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: screenWidth * 0.1, right: 100),
                                child: const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Enter OTP received on your mobile number. ',
                                    style: TextStyle(
                                      fontFamily: ffGRegular,
                                      color: loginSubHeadingColor,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),
                              ),
                              returnOTPfields(),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: !isOTPButtonEnabled
                                    ? null
                                    : () {
                                        Utils.clearToasts(context);
                                        resendOTP();
                                      },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(
                                      right: screenWidth * 0.11),
                                  child: Text(
                                    isOTPButtonEnabled
                                        ? 'Resend OTP'
                                        : 'Resend OTP in $resendDelay s',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.5,
                                        fontSize: 14,
                                        fontFamily: ffGMedium,
                                        color: isOTPButtonEnabled
                                            ? appThemeColor
                                            : drawerSubListColor),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Utils.clearToasts(context);
                                  if (verificationCode != null) {
                                    if (verificationCode.length == 6) {
                                      if (onlyNumberRegex
                                          .hasMatch(verificationCode)) {
                                        onVerifyOTP(verificationCode);
                                      } else {
                                        _showSnackBar(
                                            "Please enter only numbers",
                                            context,
                                            false);
                                      }
                                    } else {
                                      _showSnackBar("Please enter 6 digit OTP",
                                          context, false);
                                    }
                                  } else {
                                    _showSnackBar(
                                        "Please enter OTP", context, false);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: screenWidth * 0.09,
                                      right: screenWidth * 0.09),
                                  child: Card(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      side: BorderSide(
                                          width: 1, color: appThemeColor),
                                    ),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: appThemeColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                      alignment: Alignment.center,
                                      height: getProportionateScreenHeight(60),
                                      child: Text(
                                        "Next",
                                        style: TextStyle(
                                          fontFamily: ffGSemiBold,
                                          fontSize:
                                              getProportionateScreenWidth(18),
                                          color: buttonTextWhiteColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
