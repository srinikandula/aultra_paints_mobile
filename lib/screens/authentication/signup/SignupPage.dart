import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/config.dart';
import '../../../utility/BottomButton.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/Utils.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';

import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int? selected = 1;

  late var names = [];
  late var totalList = [];
  late var searchData = [];

  Map mapResponse = {};

  bool passwordVisible = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  FocusNode inputNode = FocusNode();

  late TextEditingController _userName;
  late TextEditingController _userEmail;
  late TextEditingController _userMobileNumber;
  late TextEditingController _userNewPassword;
  late TextEditingController _userConfirmPassword;

  @override
  void initState() {
    super.initState();
    _userName = TextEditingController();
    _userEmail = TextEditingController();
    _userMobileNumber = TextEditingController();
    _userNewPassword = TextEditingController();
    _userConfirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _userName.dispose();
    _userEmail.dispose();
    _userMobileNumber.dispose();
    _userNewPassword.dispose();
    _userConfirmPassword.dispose();
    super.dispose();
  }

  void _showSnackBar(
      String message, BuildContext context, ColorCheck, screenValidation) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: screenValidation
            ? Duration(milliseconds: 800)
            : Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  postSignupDetails() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "name": _userName.text,
      "email": _userEmail.text,
      "mobileNumber": _userMobileNumber.text,
      "password": _userConfirmPassword.text
    };
    var body = json.encode(map);
    // print('signup body===>$body');
    response = await http.post(Uri.parse(BASE_URL + SIGNUP_USER),
        headers: {"Content-Type": "application/json"}, body: body);
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      // print('signup resp ==== $mapResponse');
      Navigator.pop(context);
      _showSnackBar(mapResponse['message'], context,
          mapResponse["status"] == "success", false);
      if (mapResponse["status"] == "success") {
        Navigator.pop(context, true);
      } else {
        _showSnackBar(mapResponse['message'], context, false, false);
      }
    } else {
      returnError(mapResponse['message']);
    }
  }

  returnError(errorMessage) {
    _showSnackBar(errorMessage, context, false, false);
    Navigator.pop(context);
  }

  validateFeilds() {
    Utils.clearToasts(context);
    final nameRegex = RegExp(r"^[a-zA-Z\s]{3,}$");
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    final mobileRegex = RegExp(r"^\d{10}$");
    final passwordRegex = RegExp(
        r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z0-9!@#$%^&*(),.?":{}|<>]{8,}$');

    if (_userName.text.isEmpty || !nameRegex.hasMatch(_userName.text)) {
      _showSnackBar('Enter a valid name (only letters, min 3 characters)',
          context, false, true);
    } else if (_userEmail.text.isEmpty ||
        !emailRegex.hasMatch(_userEmail.text)) {
      _showSnackBar('Enter a valid email', context, false, true);
    } else if (_userMobileNumber.text.isEmpty ||
        !mobileRegex.hasMatch(_userMobileNumber.text)) {
      _showSnackBar(
          'Enter a valid 10-digit mobile number', context, false, true);
    } else if (_userNewPassword.text.isEmpty ||
        !passwordRegex.hasMatch(_userNewPassword.text)) {
      _showSnackBar('Enter a valid new password', context, false, true);
    } else if (_userConfirmPassword.text.isEmpty ||
        !passwordRegex.hasMatch(_userConfirmPassword.text)) {
      _showSnackBar('Enter a valid confirm password', context, false, true);
    } else if (_userNewPassword.text != _userConfirmPassword.text) {
      _showSnackBar('Passwords are not matching', context, false, true);
    } else {
      postSignupDetails();
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
            SingleParamHeader(
              'Register',
              '',
              context,true,
              () => Navigator.pop(context, true),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 2,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        returnFormFeilds(),
                        BottomButton(
                          "Register",
                          context,
                          () => validateFeilds(),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != _userConfirmPassword.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  Widget returnFormFeilds() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //user name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Name'),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _userName,
                  decoration: const InputDecoration(
                      hintText: 'Enter Name',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_userName.text != value) {
                        final cursorPosition = _userEmail.selection;
                        _userName.text = value;
                        _userName.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Email'),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.emailAddress,
                  controller: _userEmail,
                  decoration: const InputDecoration(
                      hintText: 'Enter Email',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_userEmail.text != value) {
                        final cursorPosition = _userEmail.selection;
                        _userEmail.text = value;
                        _userEmail.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //user mobile number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Mobile Number'),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  controller: _userMobileNumber,
                  decoration: const InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_userMobileNumber.text != value) {
                        final cursorPosition = _userMobileNumber.selection;
                        _userMobileNumber.text = value;
                        _userMobileNumber.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //user new password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('New Password'),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _userNewPassword,
                  obscureText: !newPasswordVisible,
                  decoration: InputDecoration(
                      hintText: 'Enter new password',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              newPasswordVisible = !newPasswordVisible;
                            });
                          },
                          child: Icon(
                            newPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: appButtonColor,
                            size: 24,
                          ),
                        ),
                      ),
                      hintStyle: const TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: const EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_userNewPassword.text != value) {
                        final cursorPosition = _userNewPassword.selection;
                        _userNewPassword.text = value;
                        _userNewPassword.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //user confirm password
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Confirm Password'),
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _userConfirmPassword,
                  obscureText: !confirmPasswordVisible,
                  decoration: InputDecoration(
                      hintText: 'Enter confirm password',
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              confirmPasswordVisible = !confirmPasswordVisible;
                            });
                          },
                          child: Icon(
                            confirmPasswordVisible
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded,
                            color: appButtonColor,
                            size: 24,
                          ),
                        ),
                      ),
                      hintStyle: const TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: const EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_userConfirmPassword.text != value) {
                        final cursorPosition = _userConfirmPassword.selection;
                        _userConfirmPassword.text = value;
                        _userConfirmPassword.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }
}
