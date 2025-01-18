import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utility/Utils.dart';
import '../LayOut/LayOutPage.dart';
import '../authentication/login/LoginPage.dart';
import '../dashboard/DashboardNewPage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  @override
  void dispose() {
    _navigationTimer.cancel(); // Ensure timer is cleared to avoid memory leaks
    super.dispose();
  }

  void _initializeSplash() async {
    _startNavigationTimer();
    // await certificateCheck();
  }

  void _showSnackBar(String message, BuildContext context, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: Utils.returnStatusToastDuration(isSuccess),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 2), () => onNavigate());
  }

  Future<void> onNavigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var authToken = prefs.getString('accessToken');

    if (!mounted) return;

    if (authToken != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardNewPage(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  Future<HttpClient> createHttpClientWithCertificate() async {
    SecurityContext context = SecurityContext.defaultContext;
    try {
      final certData = await rootBundle.load(
          'assets/certificate/AultraPaints_b20bd50c61d9d911.crt'); // QA Certificate
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
        _startNavigationTimer();
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('An error occurred: $e', context, false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
            height: MediaQuery.of(context).size.height,
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
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
