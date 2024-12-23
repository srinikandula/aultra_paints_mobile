import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/config.dart';
import '../../../utility/Utils.dart';
import '../../../utility/size_config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';

import '../../../model/request/LoginRequest.dart';
import 'package:http/http.dart' as http;

class MyHttpoverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

//void main() => runApp(MyApp());
void main() {
  HttpOverrides.global = new MyHttpoverrides();
  runApp(PasswordPage());
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({Key? key}) : super(key: key);

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int? selected = 1;
  final LoginRequest _loginRequest = LoginRequest();

  late var names = [];
  late var totalList = [];
  late var searchData = [];

  var stringResponse = '';
  Map mapResponse = {};

  var loggedUserName;
  var loggedUserRole;
  var loggedUserPhoneNumber;
  bool passwordVisible = false;
  FocusNode inputNode = FocusNode();

  @override
  void initState() {
    fetchArguments();
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      openKeyboard();
    });
  }

  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  onBackPressed() {
    Utils.clearToasts(context);
    Navigator.pop(context, true);
  }

  fetchArguments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    loggedUserName = prefs.getString('loggedUserName');
    loggedUserRole = prefs.getString('loggedUserRole');
    setState(() {
      loggedUserName;
      loggedUserRole;
    });
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  postLoginDetails(passwordValue) async {
    Utils.returnScreenLoader(context);
    http.Response response;
    //  Map map = {
    //   "password": passwordValue,
    //   "userName": loggedUserName,
    //   "userType": loggedUserRole,
    //   "phoneNumber": ""
    // };
    // var body = json.encode(map);
    // print('login password body===>$body');
    // response = await http.post(
    //     Uri.parse(BASE_URL + AUTHENTICATE_LOGIN_USER_SSO),
    //     headers: {"Content-Type": "application/json"},
    //     body: body);

    Map map = {
      "password": passwordValue,
      "username": loggedUserName,
      "userType": loggedUserRole,
      "phoneNumber": ""
    };
    var body = json.encode(map);
    print('login password body===>$body');
    response = await http.post(Uri.parse(BASE_URL + POST_LOGIN_DETAILS),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      print('login resp ==== $mapResponse');

      Navigator.pop(context);
      // _showSnackBar(
      //     mapResponse['message'], context, mapResponse["status"] == "success");
      if (mapResponse["status"] == "success") {
        var userData = mapResponse['data'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', userData['accessToken']);
        await prefs.setString('USER_NAME', userData['USER_NAME']);
        await prefs.setInt('USER_ID', userData['USER_ID']);
        await prefs.setString('BACKEND_ROLE', userData['roles'][0]);
        await prefs.setInt('Company_ID', userData['Company_ID']);
        FocusScope.of(context).unfocus();
        Navigator.pushNamed(context, '/dashboardPage', arguments: {});
      } else {
        _showSnackBar(mapResponse['message'], context, false);
      }
    } else {
      _showSnackBar(mapResponse['message'], context, false);
      Navigator.pop(context);
    }
  }

  void _toggleObscured() {
    setState(() {
      passwordVisible = !passwordVisible;
      // if (textFieldFocusNode.hasPrimaryFocus) return; // If focus is on text field, dont unfocus
      // textFieldFocusNode.canRequestFocus = false;     // Prevents focus if tap on eye
    });
  }

  Future<bool> _onWillPop() async {
    onBackPressed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onWillPop,
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
                                      'assets/images/app_logo.png',
                                      height: getProportionateScreenHeight(40),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 40, right: 100),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'Login with your provided credentials',
                                    style: TextStyle(
                                      fontFamily: ffGRegular,
                                      color: loginSubHeadingColor,
                                      fontSize: 17.0,
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
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    width: 1,
                                    color: border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: TextField(
                                  autofocus: true,
                                  focusNode: inputNode,
                                  obscureText: !passwordVisible,
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  },
                                  keyboardType: defaultTargetPlatform ==
                                          TargetPlatform.iOS
                                      ? const TextInputType.numberWithOptions(
                                          decimal: true, signed: true)
                                      : TextInputType.text,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Password',
                                    suffixIcon: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                      child: GestureDetector(
                                        onTap: _toggleObscured,
                                        child: Icon(
                                          passwordVisible
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: appButtonColor,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    labelStyle: const TextStyle(
                                      fontFamily: ffGSemiBold,
                                      fontSize: 20.0,
                                      color: textInputPlaceholderColor,
                                    ),
                                    contentPadding: EdgeInsets.all(15),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    _loginRequest.password = value;
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Utils.clearToasts(context);
                                  var tempValue = _loginRequest.password;
                                  if (tempValue == '') {
                                    _showSnackBar("Please enter password",
                                        context, false);
                                  } else {
                                    postLoginDetails(tempValue);
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
