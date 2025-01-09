import 'dart:async';
import 'dart:convert';

import 'package:aultra_paints_mobile/utility/FooterButton.dart';
import 'package:aultra_paints_mobile/utility/size_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/config.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/Utils.dart';
import '../../../utility/validations.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';

import 'package:http/http.dart' as http;

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
    loggedUserPhoneNumber = prefs.getString('USER_MOBILE_NUMBER');
    setState(() {
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
    Map map = {"mobile": loggedUserPhoneNumber, "otp": otpCodes};
    var body = json.encode(map);
    print('otp body===>${body}');
    response = await http.post(Uri.parse(BASE_URL + POST_VERIFY_LOGIN_OTP),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    print(
        'otp stringResponse ==== $stringResponse =====>${response.statusCode}');
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('otp resp ==== $mapResponse');
      Navigator.pop(context);
      _showSnackBar(
          mapResponse['message'], context, mapResponse["status"] == "success");
      if (mapResponse["status"] == "success") {
        var userData = mapResponse['data'];
        onSuccess(userData);
      }
    } else {
      _showSnackBar(mapResponse['message'], context, false);
      Navigator.pop(context);
    }
  }

  onSuccess(userData) async {
    print('userdata====>${userData}');
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tempToken = "Bearer" + ' ' + userData['token'];
    await prefs.setString('accessToken', tempToken);
    await prefs.setString('USER_FULL_NAME', userData['fullName']);
    await prefs.setString('USER_ID', userData['id']);
    await prefs.setString('USER_EMAIL', userData['email']);
    await prefs.setString('USER_MOBILE_NUMBER', userData['mobile']);

    Navigator.pushNamed(context, '/dashboardPage', arguments: {});
  }

  Widget returnOTPfields() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 20),
      width: getScreenWidth(300),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          return SizedBox(
            width: getScreenWidth(43),
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
                fontSize: getScreenWidth(24),
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
    Map map = {"mobile": loggedUserPhoneNumber};
    var body = json.encode(map);
    // print('resend body===>$body');
    response = await http.post(Uri.parse(BASE_URL + POST_SEND_LOGIN_OTP),
        headers: {"Content-Type": "application/json"}, body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      // print('otp resp ==== $mapResponse');
      clearOTPFields();
      Navigator.pop(context);
      _showSnackBar(mapResponse['message'], context, true);
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: whiteBgColor,
        body: Column(
          children: [
            SingleParamHeader(
              'OTP',
              '',
              context,
              false,
              () => Navigator.pop(context, true),
            ),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 2,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    margin: EdgeInsets.only(top: getScreenHeight(100)),
                    child: Column(
                      children: [
                        returnOTPsetup(),
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

  returnOTPsetup() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
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
              left: getScreenWidth(35), right: getScreenWidth(25)),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter OTP received on your mobile number. ',
              style: TextStyle(
                fontFamily: ffGRegular,
                color: loginSubHeadingColor,
                fontSize: getScreenWidth(17),
              ),
            ),
          ),
        ),
        returnOTPfields(),
        SizedBox(height: getScreenHeight(10)),
        InkWell(
          onTap: !isOTPButtonEnabled
              ? null
              : () {
                  Utils.clearToasts(context);
                  resendOTP();
                },
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: screenWidth * 0.11),
            child: Text(
              isOTPButtonEnabled
                  ? 'Resend OTP'
                  : 'Resend OTP in $resendDelay s',
              style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationThickness: 1.5,
                  fontSize: getScreenHeight(14),
                  fontFamily: ffGMedium,
                  color:
                      isOTPButtonEnabled ? appThemeColor : drawerSubListColor),
            ),
          ),
        ),
        FooterButton(
            'Next',
            '',
            context,
            () => {
                  Utils.clearToasts(context),
                  if (verificationCode != null)
                    {
                      if (verificationCode.length == 6)
                        {
                          if (onlyNumberRegex.hasMatch(verificationCode))
                            {onVerifyOTP(verificationCode)}
                          else
                            {
                              _showSnackBar(
                                  "Please enter only numbers", context, false)
                            }
                        }
                      else
                        {
                          _showSnackBar(
                              "Please enter 6 digit OTP", context, false)
                        }
                    }
                  else
                    {_showSnackBar("Please enter OTP", context, false)}
                }),
      ],
    );
  }
}
