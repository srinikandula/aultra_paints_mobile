import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/config.dart';
import '../../../services/error_handling.dart';
import '../../../utility/FooterButton.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/size_config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateOrders extends StatefulWidget {
  const CreateOrders({Key? key}) : super(key: key);

  @override
  State<CreateOrders> createState() => _CreateOrdersState();
}

class _CreateOrdersState extends State<CreateOrders> {
  int? selected;

  var accesstoken;
  var USER_ID;
  var Company_ID;

  Map mapResponse = {};

  var ewbNumber = '';
  var lrNumber = '';
  var invoiceNumber = '';
  var invoiceValue = '';

  var argumentData;

  DateTime? invoiceDate = DateTime.now();

  Map fetchedDetails = {};

  late TextEditingController _brandNameController;
  late TextEditingController _productNameController;
  late TextEditingController _volumeController;
  late TextEditingController _quantityController;

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedValidUptoDate = DateTime.now();

  var tripNumber;

  @override
  void initState() {
    fetchLocalStorageDate();
    super.initState();
    _brandNameController = TextEditingController();
    _productNameController = TextEditingController();
    _volumeController = TextEditingController();
    _quantityController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of each controller when done
    _brandNameController.dispose();
    _productNameController.dispose();
    _volumeController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  fetchLocalStorageDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void validateCreateOrderDetails() {
    if (_brandNameController.text.isEmpty) {
      _showSnackBar("Please enter Brand Name", context, false);
    } else if (_productNameController.text.isEmpty) {
      _showSnackBar("Please enter Product Name", context, false);
    } else if (_volumeController.text.isEmpty) {
      _showSnackBar("Please enter Volume", context, false);
    } else if (_quantityController.text.isEmpty) {
      _showSnackBar("Please enter Quantity", context, false);
    } else {
      createOrder();
    }
  }

  Future createOrder() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "brand": _brandNameController.text,
      "productName": _productNameController.text,
      "volume": _volumeController.text,
      "quantity": _quantityController.text,
    };
    var body = json.encode(map);

    // print('create order body====>$body');
    response = await http.post(Uri.parse(BASE_URL + CREATE_ORDER),
        headers: {
          "Content-Type": "application/json",
          "Authorization": accesstoken
        },
        body: body);
    // print(
    //     'create order statusCode====>${response.statusCode}====>${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      var apiResp = json.decode(response.body);
      Navigator.pop(context);
      _showSnackBar(apiResp['message'], context, true);
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
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
              'Create Order',
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
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        Container(
                            height: getScreenHeight(600),
                            child: returnFormFeilds()),
                        FooterButton(
                            "CREATE",
                            'fullWidth',
                            context,
                            () => {
                                  Utils.clearToasts(context),
                                  validateCreateOrderDetails()
                                })
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

  Widget returnFormFeilds() {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      // height: screenHeight * 0.65,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5),
          //Brand
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Brand'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
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
                  keyboardType: defaultTargetPlatform == TargetPlatform.iOS
                      ? TextInputType.numberWithOptions(
                          decimal: true, signed: true)
                      : TextInputType.text,
                  controller: _brandNameController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Brand',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_brandNameController.text != value) {
                        final cursorPosition = _brandNameController.selection;
                        _brandNameController.text = value;
                        _brandNameController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //Product Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Product Name'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
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
                  keyboardType: defaultTargetPlatform == TargetPlatform.iOS
                      ? TextInputType.numberWithOptions(
                          decimal: true, signed: true)
                      : TextInputType.text,
                  controller: _productNameController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Product Name',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_productNameController.text != value) {
                        final cursorPosition = _productNameController.selection;
                        _productNameController.text = value;
                        _productNameController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/createProduct');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.add, color: appThemeColor),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      children: [
                        Text(
                          'Add Product',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: appThemeColor,
                              decoration: TextDecoration.underline,
                              decorationThickness: 1.5,
                              fontSize: 14,
                              fontFamily: ffGMedium),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 5),
          //Volume
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Volume'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
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
                  keyboardType: TextInputType.number,
                  controller: _volumeController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Volume',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  // initialValue: invoiceValue,
                  onChanged: (value) {
                    setState(() {
                      if (_volumeController.text != value) {
                        final cursorPosition = _volumeController.selection;
                        _volumeController.text = value;
                        _volumeController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //Quantity
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Quantity'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
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
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Quantity',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_quantityController.text != value) {
                        final cursorPosition = _quantityController.selection;
                        _quantityController.text = value;
                        _quantityController.selection = cursorPosition;
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
