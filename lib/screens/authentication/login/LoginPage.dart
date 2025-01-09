import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../utility/loader.dart';
import '/utility/check_internet.dart';
import '/utility/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';

import '/model/request/LoginRequest.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected = 1;

  final LoginRequest _loginRequest = LoginRequest();

  String stringResponse = '';
  Map mapResponse = {};
  late var names = [];
  late var totalList = [];
  late var searchData = [];
  String? selectedRole;
  String? selectedRoleValue;
  FocusNode inputNode = FocusNode();

  @override
  void initState() {
    handleLocalStorage();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      openKeyboard();
    });
  }

  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  handleLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('counter', 10);
  }

  onBackPressed() {
    Navigator.pop(context, true);
  }

  Future<void> checkUserLogin(
      String tempFirstValue, String tempSecondValue) async {
    try {
      bool isConnected = await CheckInternet.isInternet();
      if (!isConnected) {
        _showSnackBar(
          "No internet connection. Please try again.",
          context,
          false,
        );
        return;
      }

      Loader.showLoader(context);

      final apiURL = '$BASE_URL$POST_SEND_LOGIN_OTP';
      Map<String, String> requestBody = {"mobile": tempFirstValue};
      final body = json.encode(requestBody);

      print('login body===>${body}=========>${apiURL}');

      final response = await http.post(
        Uri.parse(apiURL),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print('API Response checl: ${response.body}');

      final apiResp = json.decode(response.body);
      print('API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        Loader.hideLoader(context);
        onLogin(tempFirstValue);
      } else {
        Loader.hideLoader(context);
        _showSnackBar(
          apiResp['message'] ?? "Unexpected error occurred.",
          context,
          false,
        );
      }
    } catch (e) {
      // Handle errors
      Loader.hideLoader(context);
      _showSnackBar(
        "An error occurred: ${e.toString()}",
        context,
        false,
      );
      print('Error: $e');
    }
  }

  onLogin(tempFirstValue) async {
    // print('userdata====>${userData}');
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_MOBILE_NUMBER', tempFirstValue);

    Navigator.pushNamed(context, '/otpPage', arguments: {});
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<bool> _onWillPop() async {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
          child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                                    width: screenWidth,
                                    height: getScreenHeight(150),
                                    child: null,
                                  ),
                                ],
                              )),
                              Container(
                                width: screenWidth * 0.8,
                                height: getScreenWidth(40),
                                child: Row(
                                  children: [
                                    Image.asset('assets/images/app_logo.png'),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: 5,
                                    left: screenWidth * 0.1,
                                    right: 100),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Login with your provided credentials',
                                    style: TextStyle(
                                      fontFamily: ffGRegular,
                                      color: loginSubHeadingColor,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    top: screenHeight * 0.02,
                                    left: screenWidth * 0.1,
                                    right: screenWidth * 0.1),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: TextField(
                                  keyboardType: TextInputType.text,
                                  // autofocus: true,
                                  // focusNode: inputNode,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Mobile Number',
                                    labelStyle: TextStyle(
                                      fontFamily: ffGMedium,
                                      fontSize: 18.0,
                                      color: textInputPlaceholderColor,
                                    ),
                                    contentPadding: EdgeInsets.all(15),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _loginRequest.phoneNumber = value.trim();
                                  },
                                ),
                              ),
                              // SizedBox(height: 10),
                              // Container(
                              //   margin: EdgeInsets.only(
                              //       top: screenHeight * 0.01,
                              //       left: screenWidth * 0.1,
                              //       right: screenWidth * 0.1),
                              //   decoration: BoxDecoration(
                              //     color: white,
                              //     borderRadius: BorderRadius.circular(10),
                              //     border: Border.all(
                              //       width: 1,
                              //       color: border,
                              //       style: BorderStyle.solid,
                              //     ),
                              //   ),
                              //   child: TextField(
                              //     keyboardType: TextInputType.text,
                              //     // autofocus: false,
                              //     // focusNode: inputNode,
                              //     onTapOutside: (event) {
                              //       FocusManager.instance.primaryFocus
                              //           ?.unfocus();
                              //     },
                              //     decoration: const InputDecoration(
                              //       labelText: 'Enter Password',
                              //       labelStyle: TextStyle(
                              //         fontFamily: ffGMedium,
                              //         fontSize: 18.0,
                              //         color: textInputPlaceholderColor,
                              //       ),
                              //       contentPadding: EdgeInsets.all(15),
                              //       border: InputBorder.none,
                              //     ),
                              //     onChanged: (value) {
                              //       _loginRequest.password = value.trim();
                              //     },
                              //   ),
                              // ),

                              SizedBox(height: 30),
                              InkWell(
                                onTap: () {
                                  // Navigator.pushNamed(context, '/otpPage',
                                  //     arguments: {});
                                  // checkUserLogin();
                                  // Navigator.pushNamed(context, '/dashboardPage',
                                  //     arguments: {});
                                  Utils.clearToasts(context);
                                  var tempFirstValue =
                                      _loginRequest.phoneNumber.trim();
                                  var tempSecondValue =
                                      _loginRequest.password.trim();
                                  if (tempFirstValue == '') {
                                    _showSnackBar("Please enter Mobile Number",
                                        context, false);
                                  }
                                  //  else if (tempSecondValue == '') {
                                  //   _showSnackBar("Please enter password",
                                  //       context, false);
                                  // }
                                  else {
                                    checkUserLogin(
                                        tempFirstValue, tempSecondValue);
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: screenWidth * 0.09,
                                      right: screenWidth * 0.09),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              getProportionateScreenWidth(10))),
                                      side: BorderSide(
                                          width: 1, color: appThemeColor),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: appThemeColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                getProportionateScreenWidth(
                                                    10))),
                                      ),
                                      alignment: Alignment.center,
                                      height: getProportionateScreenHeight(60),
                                      child: Text(
                                        "LOGIN",
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
                              SizedBox(height: 5),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signupPage');
                                },
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(
                                      right: screenWidth * 0.11),
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationThickness: 1.5,
                                        fontSize: 16,
                                        fontFamily: ffGMedium,
                                        color: appThemeColor),
                                  ),
                                ),
                              ),
                              SizedBox(height: 50),
                              // InkWell(
                              //   onTap: () async {
                              //     var url = Uri.parse(
                              //         "https://mahindralogistics.com/privacy-policy/");
                              //     try {
                              //       if (await canLaunchUrl(url)) {
                              //         Utils.openUrl(url);
                              //       } else {
                              //         _showSnackBar(
                              //             "Could not open URL in browser.",
                              //             context,
                              //             false);
                              //       }
                              //     } catch (e) {
                              //       _showSnackBar(
                              //           "Failed to open URL in browser.",
                              //           context,
                              //           false);
                              //     }
                              //   },
                              //   child: Container(
                              //     alignment: Alignment.center,
                              //     margin: EdgeInsets.only(
                              //         right: screenWidth * 0.11),
                              //     child: Text(
                              //       'Privacy Policy',
                              //       style: TextStyle(
                              //           decoration: TextDecoration.underline,
                              //           decorationThickness: 1.5,
                              //           fontSize: 16,
                              //           fontFamily: ffGMedium,
                              //           color: appThemeColor),
                              //     ),
                              //   ),
                              // ),
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
      )),
    );
  }
}
