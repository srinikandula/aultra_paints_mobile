import 'dart:convert';

import 'package:aultra_paints_mobile/utility/FooterButton.dart';
import 'package:aultra_paints_mobile/utility/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/config.dart';
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
  late TextEditingController _userNewPassword;
  late TextEditingController _userConfirmPassword;
  late TextEditingController _userMobileNumber;

  @override
  void initState() {
    super.initState();
    _userName = TextEditingController();
    _userEmail = TextEditingController();
    _userNewPassword = TextEditingController();
    _userConfirmPassword = TextEditingController();
    _userMobileNumber = TextEditingController();
  }

  @override
  void dispose() {
    _userName.dispose();
    _userEmail.dispose();
    _userNewPassword.dispose();
    _userConfirmPassword.dispose();
    _userMobileNumber.dispose();
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

  postRegisterDetails() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "name": _userName.text,
      "email": _userEmail.text,
      "password": _userConfirmPassword.text,
      "mobile": _userMobileNumber.text
    };
    var body = json.encode(map);
    print('register body===>$body');
    response = await http.post(Uri.parse(BASE_URL + REGISTER_USER),
        headers: {"Content-Type": "application/json"}, body: body);
    // print('register statusCode====>${response.statusCode}');
    mapResponse = json.decode(response.body);
    // print('register resp====>${mapResponse}');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showSnackBar(mapResponse['message'], context, true, false);
      Navigator.pop(context, true);
    } else {
      _showSnackBar(mapResponse['message'], context, false, false);
      Navigator.pop(context);
    }
  }

  validateFeilds() {
    Utils.clearToasts(context);
    final nameRegex = RegExp(r"^[a-zA-Z\s]{3,}$");
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    final passwordRegex = RegExp(
        r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z0-9!@#$%^&*(),.?":{}|<>]{8,}$');
    final phoneNumberRegax = RegExp(r'^[0-9]{10}$');

    if (_userName.text.isEmpty || !nameRegex.hasMatch(_userName.text)) {
      _showSnackBar('Enter a valid name (only letters, min 3 characters)',
          context, false, true);
    }
    // else if (_userEmail.text.isEmpty ||
    //     !emailRegex.hasMatch(_userEmail.text)) {
    //   _showSnackBar('Enter a valid email', context, false, true);
    // }
    else if (_userMobileNumber.text.isEmpty ||
        !phoneNumberRegax.hasMatch(_userMobileNumber.text)) {
      _showSnackBar('Enter a valid Mobile Number', context, false, true);
    }
    //  else if (_userNewPassword.text.isEmpty) {
    //   _showSnackBar('Enter a valid new password', context, false, true);
    // } else if (_userConfirmPassword.text.isEmpty) {
    //   _showSnackBar('Enter a valid confirm password', context, false, true);
    // }
    // else if (_userNewPassword.text.isEmpty ||
    //     !passwordRegex.hasMatch(_userNewPassword.text)) {
    //   _showSnackBar('Enter a valid new password', context, false, true);
    // } else if (_userConfirmPassword.text.isEmpty ||
    //     !passwordRegex.hasMatch(_userConfirmPassword.text)) {
    //   _showSnackBar('Enter a valid confirm password', context, false, true);
    // }
    // else if (_userNewPassword.text != _userConfirmPassword.text) {
    //   _showSnackBar('Passwords are not matching', context, false, true);
    // }
    else {
      postRegisterDetails();
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
              'User\nRegistration',
              '',
              context,
              false,
              () => Navigator.pop(context, true),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: getScreenWidth(2),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: getScreenWidth(20),
                        vertical: getScreenHeight(10)),
                    child: Column(
                      children: [
                        returnFormFeilds(),
                        FooterButton(
                          "Register",
                          'fullWidth',
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
      height: screenHeight * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //user name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Name'),
              Container(
                margin: EdgeInsets.only(top: getScreenHeight(5)),
                padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(getScreenWidth(5)),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.text,
                  controller: _userName,
                  style: TextStyle(
                    fontSize: getScreenWidth(15),
                    color: Colors.black,
                    fontFamily: ffGMedium,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Enter Name',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: getScreenWidth(15),
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
          SizedBox(height: getScreenHeight(5)),
          //user email
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Utils.returnInvoiceRedStar('Email'),
          //     Container(
          //       margin: const EdgeInsets.only(top: 5),
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //       decoration: BoxDecoration(
          //         color: textinputBgColor,
          //         borderRadius: BorderRadius.circular(5.0),
          //       ),
          //       width: screenWidth * 0.9,
          //       child: TextFormField(
          //         onTapOutside: (event) {
          //           FocusManager.instance.primaryFocus?.unfocus();
          //         },
          //         autofocus: false,
          //         keyboardType: TextInputType.emailAddress,
          //         controller: _userEmail,
          //         decoration: const InputDecoration(
          //             hintText: 'Enter Email',
          //             hintStyle: TextStyle(
          //                 fontFamily: ffGMedium,
          //                 fontSize: 15.0,
          //                 color: Colors.grey),
          //             contentPadding: EdgeInsets.all(15),
          //             border: InputBorder.none),
          //         onChanged: (value) {
          //           setState(() {
          //             if (_userEmail.text != value) {
          //               final cursorPosition = _userEmail.selection;
          //               _userEmail.text = value;
          //               _userEmail.selection = cursorPosition;
          //             }
          //           });
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 5),
          //mobile number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Mobile Number'),
              Container(
                margin: EdgeInsets.only(top: getScreenHeight(5)),
                padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(getScreenWidth(5)),
                ),
                width: screenWidth * 0.9,
                child: TextFormField(
                  onTapOutside: (event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  autofocus: false,
                  keyboardType: TextInputType.phone,
                  controller: _userMobileNumber,
                  style: TextStyle(
                    fontSize: getScreenWidth(15),
                    color: Colors.black,
                    fontFamily: ffGMedium,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Enter Mobile Number',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: getScreenWidth(15),
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
          SizedBox(height: getScreenHeight(5)),
          // //user new password
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Utils.returnInvoiceRedStar('New Password'),
          //     Container(
          //       margin: const EdgeInsets.only(top: 5),
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //       decoration: BoxDecoration(
          //         color: textinputBgColor,
          //         borderRadius: BorderRadius.circular(5.0),
          //       ),
          //       width: screenWidth * 0.9,
          //       child: TextFormField(
          //         onTapOutside: (event) {
          //           FocusManager.instance.primaryFocus?.unfocus();
          //         },
          //         autofocus: false,
          //         keyboardType: TextInputType.text,
          //         controller: _userNewPassword,
          //         obscureText: !newPasswordVisible,
          //         decoration: InputDecoration(
          //             hintText: 'Enter new password',
          //             suffixIcon: Padding(
          //               padding: const EdgeInsets.only(right: 4),
          //               child: GestureDetector(
          //                 onTap: () {
          //                   setState(() {
          //                     newPasswordVisible = !newPasswordVisible;
          //                   });
          //                 },
          //                 child: Icon(
          //                   newPasswordVisible
          //                       ? Icons.visibility_rounded
          //                       : Icons.visibility_off_rounded,
          //                   color: appButtonColor,
          //                   size: 24,
          //                 ),
          //               ),
          //             ),
          //             hintStyle: const TextStyle(
          //                 fontFamily: ffGMedium,
          //                 fontSize: 15.0,
          //                 color: Colors.grey),
          //             contentPadding: const EdgeInsets.all(15),
          //             border: InputBorder.none),
          //         onChanged: (value) {
          //           setState(() {
          //             if (_userNewPassword.text != value) {
          //               final cursorPosition = _userNewPassword.selection;
          //               _userNewPassword.text = value;
          //               _userNewPassword.selection = cursorPosition;
          //             }
          //           });
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 5),
          // //user confirm password
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Utils.returnInvoiceRedStar('Confirm Password'),
          //     Container(
          //       margin: const EdgeInsets.only(top: 5),
          //       padding: const EdgeInsets.symmetric(vertical: 10),
          //       decoration: BoxDecoration(
          //         color: textinputBgColor,
          //         borderRadius: BorderRadius.circular(5.0),
          //       ),
          //       width: screenWidth * 0.9,
          //       child: TextFormField(
          //         onTapOutside: (event) {
          //           FocusManager.instance.primaryFocus?.unfocus();
          //         },
          //         autofocus: false,
          //         keyboardType: TextInputType.text,
          //         controller: _userConfirmPassword,
          //         obscureText: !confirmPasswordVisible,
          //         decoration: InputDecoration(
          //             hintText: 'Enter confirm password',
          //             suffixIcon: Padding(
          //               padding: const EdgeInsets.only(right: 4),
          //               child: GestureDetector(
          //                 onTap: () {
          //                   setState(() {
          //                     confirmPasswordVisible = !confirmPasswordVisible;
          //                   });
          //                 },
          //                 child: Icon(
          //                   confirmPasswordVisible
          //                       ? Icons.visibility_rounded
          //                       : Icons.visibility_off_rounded,
          //                   color: appButtonColor,
          //                   size: 24,
          //                 ),
          //               ),
          //             ),
          //             hintStyle: const TextStyle(
          //                 fontFamily: ffGMedium,
          //                 fontSize: 15.0,
          //                 color: Colors.grey),
          //             contentPadding: const EdgeInsets.all(15),
          //             border: InputBorder.none),
          //         onChanged: (value) {
          //           setState(() {
          //             if (_userConfirmPassword.text != value) {
          //               final cursorPosition = _userConfirmPassword.selection;
          //               _userConfirmPassword.text = value;
          //               _userConfirmPassword.selection = cursorPosition;
          //             }
          //           });
          //         },
          //       ),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 5),
        ],
      ),
    );
  }
}
