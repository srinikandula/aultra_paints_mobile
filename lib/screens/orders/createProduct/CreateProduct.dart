import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../services/config.dart';
import '../../../services/error_handling.dart';
import '../../../utility/BottomButton.dart';
import '../../../utility/FooterButton.dart';
import '../../../utility/SingleParamHeader.dart';
import '../../../utility/size_config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateProduct extends StatefulWidget {
  const CreateProduct({Key? key}) : super(key: key);

  @override
  State<CreateProduct> createState() => _CreateProductState();
}

class _CreateProductState extends State<CreateProduct> {
  int? selected;

  var accesstoken;
  var USER_ID;
  var Company_ID;

  String stringResponse = '';
  Map mapResponse = {};

  var ewbNumber = '';
  var lrNumber = '';
  var invoiceNumber = '';
  var invoiceValue = '';

  var argumentData;

  DateTime? invoiceDate = DateTime.now();

  Map fetchedDetails = {};

  late TextEditingController _batchNumberController;
  late TextEditingController _brandController;
  late TextEditingController _productNameController;
  late TextEditingController _volumeController;
  late TextEditingController _quantityController;
  late TextEditingController _branchController;
  TextEditingController _expiryDateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedValidUptoDate = DateTime.now();

  var tripNumber;

  @override
  void initState() {
    fetchLocalStorageDate();
    super.initState();
    _batchNumberController = TextEditingController();
    _brandController = TextEditingController();
    _productNameController = TextEditingController();
    _volumeController = TextEditingController();
    _quantityController = TextEditingController();
    _branchController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of each controller when done
    _batchNumberController.dispose();
    _brandController.dispose();
    _productNameController.dispose();
    _volumeController.dispose();
    _quantityController.dispose();
    _branchController.dispose();
    _expiryDateController.dispose();
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

  void validateProductDetails() {
    if (_batchNumberController.text.isEmpty) {
      _showSnackBar("Please enter Batch Number", context, false);
    } else if (_branchController.text.isEmpty) {
      _showSnackBar("Please enter brand", context, false);
    } else if (_productNameController.text.isEmpty) {
      _showSnackBar("Please enter Product Name", context, false);
    } else if (_volumeController.text.isEmpty) {
      _showSnackBar("Please enter volume", context, false);
    } else if (_quantityController.text.isEmpty) {
      _showSnackBar("Please enter quantity", context, false);
    } else if (_branchController.text.isEmpty) {
      _showSnackBar("Please enter volume", context, false);
    } else if (_expiryDateController.text.isEmpty) {
      _showSnackBar("Please select expiration date", context, false);
    } else {
      addProductDetails();
    }
  }

  Future addProductDetails() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "batchNumber": _batchNumberController.text,
      "brand": _brandController.text,
      "productName": _productNameController.text,
      "volume": _volumeController.text,
      "quantity": _quantityController.text,
      "Branch": _branchController.text,
      // "expiryDate": _expiryDateController.text,
      "expiryDate": returnFormattedDate(),
    };
    var body = json.encode(map);

    print('add product body====>$body');
    response = await http.post(Uri.parse(BASE_URL + SAVE_INVOICE_DETAILS),
        headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken
        },
        body: body);
    var productResp = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      _showSnackBar(productResp['message'], context, true);
      Navigator.pop(context, true);
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, productResp['message'], false);
    }
  }

  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDateController.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(_expiryDateController.text)
          : _selectedValidUptoDate,
      // firstDate: _invoiceDateController.text.isNotEmpty
      //     ? DateFormat('dd-MM-yyyy').parse(_invoiceDateController.text)
      //     : DateTime(1990, 1, 1),
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null && picked != _selectedValidUptoDate) {
      setState(() {
        _selectedValidUptoDate = picked;
        _expiryDateController.text =
            DateFormat('dd-MM-yyyy').format(_selectedValidUptoDate);
      });
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
              'Create Product',
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
                        returnFormFeilds(),
                        FooterButton(
                            "Add Product",
                            'fullWidth',
                            context,
                            () => {
                                  Utils.clearToasts(context),
                                  validateProductDetails()
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
          //Batch Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Batch Number'),
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
                  keyboardType: TextInputType.text,
                  controller: _batchNumberController,
                  decoration: const InputDecoration(
                      hintText: 'Enter batch',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_batchNumberController.text != value) {
                        final cursorPosition = _batchNumberController.selection;
                        _batchNumberController.text = value;
                        _batchNumberController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //Brand Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Brand Name'),
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
                  keyboardType: TextInputType.text,
                  controller: _brandController,
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
                      if (_brandController.text != value) {
                        final cursorPosition = _brandController.selection;
                        _brandController.text = value;
                        _brandController.selection = cursorPosition;
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
                  keyboardType: TextInputType.number,
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
          //quantity
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
          //Branch
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Branch'),
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
                  controller: _branchController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Branch',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      if (_branchController.text != value) {
                        final cursorPosition = _branchController.selection;
                        _branchController.text = value;
                        _branchController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //ewb date valid upto
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Expiration Date'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: InkWell(
                  onTap: () {
                    _selectExpirationDate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDateController.text.isEmpty
                            ? 'Select Date'
                            : returnFormattedDate(),
                        style: TextStyle(
                          fontFamily: ffGSemiBold,
                          color: popUpListColor,
                          fontSize: 15.0,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 35,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  returnFormattedDate() {
    String text = _expiryDateController.text;

    RegExp regExp = RegExp(
        r'(\d{2}-\d{2}-\d{4})|(\d{4}-\d{2}-\d{2})(?:\s\d{2}:\d{2}:\d{2})?');

    RegExpMatch? match = regExp.firstMatch(text);

    if (match != null) {
      String extractedDate = match.group(0)!; // Extract the matched date part

      // Parse the date into a DateTime object
      DateTime? parsedDate;
      if (RegExp(r'\d{2}-\d{2}-\d{4}').hasMatch(extractedDate)) {
        // If the format is dd-MM-yyyy, parse it directly
        parsedDate = DateFormat('dd-MM-yyyy').parse(extractedDate);
      } else if (RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(extractedDate)) {
        // If the format is yyyy-MM-dd, parse it accordingly
        parsedDate = DateFormat('dd-MM-yyyy').parse(extractedDate);
      }

      // Format the date into dd-MM-yyyy
      if (parsedDate != null) {
        String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
        // print('Formatted date: $formattedDate');
        return formattedDate;
      } else {
        // print('Invalid date format');
        return 'Invalid Date';
      }
    } else {
      // print('No date found in the string');
      return 'Select Date';
    }
  }
}
