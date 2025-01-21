import 'dart:io';

import 'package:aultra_paints_mobile/screens/LayOut/LayOutPage.dart';
import 'package:aultra_paints_mobile/screens/dashboard/DashboardNewPage.dart';

import '/screens/authentication/otp/OtpPage.dart';
import 'screens/orders/createOrder/CreateOrders.dart';
import 'screens/orders/createProduct/CreateProduct.dart';
import 'screens/orders/orderDetails/OrderDetails.dart';
import 'screens/orders/ordersList/OrdersList.dart';
import 'screens/orders/qrScanner/QrScanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '/utility/CustomAnimation.dart';
import 'package:provider/provider.dart';

import '/screens/authentication/login/LoginPage.dart';
import '/screens/authentication/login/LoginViewModel.dart';
import 'screens/splash/SplashPage.dart';
import '/screens/dashboard/DashboardPage.dart';
import '/screens/authentication/signup/SignupPage.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginViewModel>(
        create: (context) => LoginViewModel(),
      ),
    ],
    child: MyApp(),
  ));
  configLoading();
}

class MyApp extends StatefulWidget {
  @override
  State createState() {
    return MyAppState();
  }
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCube
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      // title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
      ),
      home: const SplashPage(),
      // home: const DashboardPage(),
      builder: EasyLoading.init(),
      routes: {
        "/otpPage": (context) => const OtpPage(),
        // "/dashboardPage": (context) => const DashboardPage(),
        "/dashboardPage": (context) => LayoutPage(child: DashboardNewPage())
        // '/': (context) => LayoutPage(child: DashboardNewPage(), title: 'Home'),
        // '/profile': (context) => LayoutPage(child: ProfilePage(), title: 'Profile'),
        // '/settings': (context) => LayoutPage(child: SettingsPage(), title: 'Settings'),
      },
      // routes: {
      //   "/splashPage": (context) => const SplashPage(),
      //   "/loginPage": (context) => const LoginPage(),
      //   // "/dashboardPage": (context) => const DashboardPage(),
      //   "/dashboardPage": (context) => const DashboardNewPage(),
      //   "/createOrders": (context) => const CreateOrders(),
      //   "/qrScanner": (context) => const QrScanner(),
      //   "/orderDetails": (context) => const OrderDetails(),
      //   "/createProduct": (context) => const CreateProduct(),
      //   "/ordersList": (context) => const OrdersList(),
      //   "/signupPage": (context) => const SignupPage(),
      //   "/otpPage": (context) => const OtpPage(),
      // },
    );
  }
}
