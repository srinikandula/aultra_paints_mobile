import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Logger {
  static showLogging(var log) {
    debugPrint('#####LOGI FREIGHT##### :: $log', wrapWidth: 1024);
  }

  static apiLogging(Map map, var url, http.Response response) {
    // Logger.showLogging("\nUrl is :::: $url \nBody Parameter is :::: $map \nResponse is :::: ${response.body}");
  }

  static apiLoggingMap(Map map, var url, Response response) {
    // Logger.showLogging("\nUrl is :::: $url \nBody Parameter is :::: $map \nResponse is :::: ${response.toString()}");
  }
}
