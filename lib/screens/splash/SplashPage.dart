import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utility/Utils.dart';
import '../../utility/check_internet.dart';
import '../../utility/logger.dart';
import '../authentication/login/LoginPage.dart';
import '../dashboard/DashboardPage.dart';
import 'package:http/http.dart' as http;

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String stringResponse = '';
  Map mapResponse = {};
  late var names = [];
  late var totalList = [];
  late var searchData = [];
  int logStep = 0;
  int finishStep = 0;
  int statusCode = 0;
  // String msg = "0";
  // String error = "1.0.0";

  // final LoginRequest _loginRequest = LoginRequest();

  //msafetest@gmail.com
  //1234

  @override
  void initState() {
    super.initState();
    // certificateCheck();


    onCallTimer();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // //   checkToken();
    //   apicall();
    // });

  }

  // Future<void> apicall() async {
  //   bool isConnected = await CheckInternet.isInternet();
  //   if (!isConnected) {
  //     _showSnackBar("No internet connection. Please try again.", context, false);
  //     return;
  //   }
  //
  //   // Loader.showLoader(context);
  //   http.Response response;
  //   var apiURL = "https://logifreightapp.mahindralogistics.com/api/login/authenticateUsers";
  //
  //   try {
  //     error = "1.0.1";
  //     // _showSnackBar("API Call Start", context, false);
  //
  //     Map map = {
  //       "username": "admin",
  //       "password": "123"
  //     };
  //     var body = json.encode(map);
  //
  //     response = await http.post(Uri.parse(apiURL), headers: {
  //       "Content-Type": "application/json"}, body: body
  //     ).timeout(const Duration(seconds: 15));
  //
  //     error = "API Call End ${response.body}";
  //     // _showSnackBar("API Call End", context, false);
  //
  //     var apiResp = json.decode(response.body);
  //
  //     error = "1.0.2";
  //     // _showSnackBar("API Call Decode", context, false);
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       // Loader.hideLoader(context);
  //       Logger.showLogging(response.body);
  //       if(response.body.length>32) {
  //         msg = "1-${response.body.substring(0, 31)}}---";
  //       }
  //       onCallTimer();
  //     } else {
  //       // Loader.hideLoader(context);
  //       msg = "2-${response.body}}---";
  //       msg = "2";
  //     }
  //   } on TimeoutException catch (e) {
  //     // Loader.hideLoader(context);
  //     msg = "3";
  //     print('timne out checking');
  //     // Handles Timeout failures
  //     error = 'Timeout Error: ${e.message} ${e.toString()}';
  //     print('Timeout Error: ${e.message} ${e.toString()}');
  //   } on SocketException catch (e) {
  //     // Handles SSL/TLS issues like certificate validation failures
  //     msg = "4";
  //     error = 'SocketException: SSL/TLS Error: ${e.message} ${e.toString()}';
  //     print('SocketException: SSL/TLS Error: ${e.message} ${e.toString()}');
  //   } on HandshakeException catch (e) {
  //     // This can be triggered for SSL handshake failures
  //     msg = "5";
  //     error = 'HandshakeException: SSL Handshake error: ${e.message} ${e.toString()}';
  //     print('HandshakeException: SSL Handshake error: ${e.message} ${e.toString()}');
  //   } catch (e) {
  //     // Handles other types of errors
  //     msg = "6";
  //     print('Unexpected error: $e ${e.toString()}');
  //     error = 'Unexpected error: $e ${e.toString()}';
  //   }
  //
  //   setState(() {
  //
  //   });
  // }

  Future<void> apicall() async {
    bool isConnected = await CheckInternet.isInternet();
    if (!isConnected) {
      _showSnackBar("No internet connection. Please try again.", context, false);
      return;
    }

    // Loader.showLoader(context);
    http.Response response;
    var apiURL = "https://safetyapi.mahindralogistics.com/api/v1/user/getDepartment?topic_id=24";

    try {
      // error = "1.0.1";
      // _showSnackBar("API Call Start", context, false);

      response = await http.get(Uri.parse(apiURL), headers: {
        "Content-Type": "application/json"
      }).timeout(const Duration(seconds: 15));

      // error = "API Call End ${response.body}";
      // _showSnackBar("API Call End", context, false);

      var apiResp = json.decode(response.body);

      // error = "1.0.2";
      // _showSnackBar("API Call Decode", context, false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Loader.hideLoader(context);
        Logger.showLogging(response.body);
        // msg = "1-${response.body.substring(0, 15)}}---";
        onCallTimer();
      } else {
        // Loader.hideLoader(context);
        // msg = "2-${response.body.substring(0, 15)}}---";
        // msg = "2";
      }
    } on TimeoutException catch (e) {
      // Loader.hideLoader(context);
      // msg = "3";
      print('timne out checking');
      // Handles Timeout failures
      // error = 'Timeout Error: ${e.message} ${e.toString()}';
      print('Timeout Error: ${e.message} ${e.toString()}');
    } on SocketException catch (e) {
      // Handles SSL/TLS issues like certificate validation failures
      // msg = "4";
      // error = 'SocketException: SSL/TLS Error: ${e.message} ${e.toString()}';
      print('SocketException: SSL/TLS Error: ${e.message} ${e.toString()}');
    } on HandshakeException catch (e) {
      // This can be triggered for SSL handshake failures
      // msg = "5";
      // error = 'HandshakeException: SSL Handshake error: ${e.message} ${e.toString()}';
      print('HandshakeException: SSL Handshake error: ${e.message} ${e.toString()}');
    } catch (e) {
      // Handles other types of errors
      // msg = "6";
      print('Unexpected error: $e ${e.toString()}');
      // error = 'Unexpected error: $e ${e.toString()}';
    }

    setState(() {

    });
  }

  checkToken() async {
    certificateCheck();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var authtoken = prefs.getString('accessToken');
    // // print('authtoken check====>$authtoken');
    // if (authtoken != null) {
    //   certificateCheck();
    //   // Timer(
    //   //     const Duration(milliseconds: 500),
    //   //     () => Navigator.pushReplacement(context,
    //   //         MaterialPageRoute(builder: (context) => const DashboardPage())));
    //   // Navigator.pushReplacement(context,
    //   //     MaterialPageRoute(builder: (context) => const DashboardPage()));
    //   // MaterialPageRoute(builder: (context) => const UlipInspection()));
    // } else {
    //   Navigator.pushReplacement(
    //       context, MaterialPageRoute(builder: (context) => const LoginPage()));
    // }
  }

  Future<HttpClient> createHttpClientWithCertificate() async {
    SecurityContext context = SecurityContext.defaultContext;
    // SecurityContext context = SecurityContext(withTrustedRoots: false);
    try {
      // Load the certificate
      // final certData =
      //     await rootBundle.load('assets/certificate/STAR_mlldev_com.crt'); //dev
      final certData =
          await rootBundle.load('assets/certificate/STAR_mllqa_com.crt'); //QA
      context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
    } catch (e) {
      print("Error loading certificate: $e");
      // Handle error
    }
    HttpClient client = HttpClient(context: context);
    return client;
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future certificateCheck() async {
    _showSnackBar("STEP--1", context, true);
    updateLog(1);
    HttpClient client = await createHttpClientWithCertificate();

    _showSnackBar("STEP--2", context, true);
    updateLog(2);
    final request =
        await client.getUrl(Uri.parse('https://dealerportal.mllqa.com'));

    _showSnackBar("STEP--3", context, true);
    updateLog(3);
    final response = await request.close();

    _showSnackBar("STEP--4", context, true);
    updateLog(4);
    if (response.statusCode == 200) {
      _showSnackBar("STEP--5", context, true);
      updateLog(5);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      var authtoken = prefs.getString('accessToken');
      _showSnackBar("STEP--6", context, true);
      updateLog(6);

      if (authtoken != null) {
        _showSnackBar("STEP--7", context, true);
        updateLog(7);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const DashboardPage()));
      } else {
        _showSnackBar("STEP--8", context, true);
        updateLog(8);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    } else {
      _showSnackBar("STEP--9", context, true);
      updateLog(9);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
      print('certification check failed');
      // _showSnackBar('certification check failed', context, false);
    }
    _showSnackBar("STEP--10", context, true);
    updateFinishStep(10);
    updateStatusCode(response.statusCode);
  }

  onCallTimer() {
    Timer(const Duration(seconds: 3), () => onNavigate());
  }

  onNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authtoken = prefs.getString('accessToken');

    if (authtoken != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DashboardPage()));
    } else {
      // Loader.msg = '$msg';
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  updateLog(value) {
    setState(() {
      logStep = value;
    });
  }

  updateFinishStep(value) {
    setState(() {
      finishStep = value;
    });
  }

  updateStatusCode(value) {
    setState(() {
      statusCode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 1,
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //       'Error Code : ${logStep.toString()} : ${finishStep.toString()} : ${statusCode.toString()}',
                    //     style: const TextStyle(
                    //         decorationThickness: 1.5,
                    //         fontSize: 16,
                    //         fontFamily: ffGMedium,
                    //         color: appThemeColor),
                    //   ),
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/logiFreight_logo.png'),
                              fit: BoxFit.fitWidth)),
                    ),
                    // Container(
                    //   alignment: Alignment.center,
                    //   child: Text(
                    //     error,
                    //     style: TextStyle(
                    //         decorationThickness: 1.5,
                    //         fontSize: 11,
                    //         fontFamily: ffGMedium,
                    //         color: appThemeColor),
                    //   ),
                    // ),
                  ],
                )),
              ),
            )));
  }
}
