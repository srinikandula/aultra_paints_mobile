import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenHeight = _mediaQueryData.size.height;
    screenWidth = _mediaQueryData.size.width;
    orientation = _mediaQueryData.orientation;
  }
}

double getProportionateScreenHeight(double inputHeight) {
  // Height
  double screenHeight = SizeConfig.screenHeight;
  return (inputHeight / 812.0) * screenHeight;
}

double getProportionateScreenWidth(double inputWidth) {
  // Width, Font
  double screenWidth = SizeConfig.screenWidth;
  return (inputWidth / 375.0) * screenWidth;
}

double getScreenHeight(double inputHeight) {
  // Height
  double screenHeight = SizeConfig.screenHeight;
  return (inputHeight / 812.0) * screenHeight;
}

double getScreenWidth(double inputWidth) {
  // Width, Font
  double screenWidth = SizeConfig.screenWidth;
  return (inputWidth / 375.0) * screenWidth;
}

// bool getTabletCheck() {
//   // Width, Font
//   double screenWidth = SizeConfig.screenWidth;
//   return screenWidth > 600 ? true : false;
// }

bool getTabletCheck() {
  double screenWidth = SizeConfig.screenWidth; // Screen width in dp
  double screenHeight = SizeConfig.screenHeight; // Screen height in dp
  double pixelRatio = window.devicePixelRatio; // Device pixel ratio (DPR)

  // 1. Basic Check: Screen width or height >= 600dp
  bool isTablet = (screenWidth >= 600) || (screenHeight >= 600);

  // 2. Add a check for larger tablets (for example, screens larger than 800 dp)
  if (isTablet) {
    if (screenWidth > 800) {
      return true; // Likely a larger tablet (Android tablet, iPad)
    }
  }

  // 3. Additional checks for iOS vs Android
  if (Platform.isAndroid) {
    // On Android, if it's a large device, return true for tablet
    if (screenWidth > 800) {
      return true; // Android tablet (large screen)
    }
  }

  if (Platform.isIOS) {
    // On iOS, we might want to adjust the threshold for certain devices.
    if (screenWidth >= 600) {
      return true; // iPad or large iPhone in landscape
    }
  }

  // Default: return false for phones
  return false;
}
