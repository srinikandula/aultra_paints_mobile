import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utility/Utils.dart';
import '../authentication/login/LoginPage.dart';
import '../dashboard/DashboardPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    callTimer();
    certificateCheck();
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  callTimer() {
    Timer(const Duration(seconds: 1), () => onNavigate());
  }

  onNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authtoken = prefs.getString('accessToken');

    if (authtoken != null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DashboardPage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  Future<HttpClient> createHttpClientWithCertificate() async {
    SecurityContext context = SecurityContext.defaultContext;
    try {
      // final certData =
      //     await rootBundle.load('assets/certificate/STAR_mlldev_com.crt'); //dev
      final certData = await rootBundle
          .load('assets/certificate/AultraPaints_b20bd50c61d9d911.crt'); //QA
      context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
    } catch (e) {
      print("Error loading certificate: $e");
      throw Exception("Failed to load certificate");
    }
    return HttpClient(context: context)
      ..badCertificateCallback = (cert, host, port) => false;
  }

  Future<void> certificateCheck() async {
    try {
      HttpClient client = await createHttpClientWithCertificate();

      final request =
          await client.getUrl(Uri.parse('https://api.aultrapaints.com'));

      final response = await request.close();

      if (response.statusCode == 200) {
        callTimer();
      } else {
        if (!mounted) return; // Ensure the widget is still mounted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        // _showSnackBar('Certification verification failed', context, false);
      }
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted
      _showSnackBar('An error occurred: $e', context, false);
    }
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
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/app_logo.png'),
                              fit: BoxFit.fitWidth)),
                    ),
                  ],
                )),
              ),
            )));
  }
}
