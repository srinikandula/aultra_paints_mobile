import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/validations.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  int? selected;

  var accesstoken;
  var USER_ID;
  var Company_ID;

  var ewbNumber;

  var argumentData;
  bool allowScanner = true;

  var scannedValue;

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();
  }

  fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    USER_ID = prefs.getInt('USER_ID');
    Company_ID = prefs.getInt('Company_ID');
    argumentData = ModalRoute.of(context)!.settings.arguments;
    // print('argumentData====>$argumentData');
    setState(() {
      argumentData;
    });
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            SingleParamHeader('Order Details', '', context, false,
                () => Navigator.pop(context, true)),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
