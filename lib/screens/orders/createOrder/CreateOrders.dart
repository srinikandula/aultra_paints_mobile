import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../services/config.dart';
import '../../../services/error_handling.dart';
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

  String stringResponse = '';
  Map mapResponse = {};

  var ewbNumber = '';
  var lrNumber = '';
  var invoiceNumber = '';
  var invoiceValue = '';

  var argumentData;

  DateTime? invoiceDate = DateTime.now();

  Map fetchedDetails = {};

  late TextEditingController _ewbNumberController;
  late TextEditingController _lrNumberController;
  late TextEditingController _invoiceNumberController;
  late TextEditingController _invoiceValueController;
  TextEditingController _invoiceDateController = TextEditingController();
  TextEditingController _ewbExpirationDateController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  DateTime _selectedValidUptoDate = DateTime.now();

  var tripNumber;

  @override
  void initState() {
    fetchLocalStorageDate();
    super.initState();
    _ewbNumberController = TextEditingController();
    _lrNumberController = TextEditingController();
    _invoiceNumberController = TextEditingController();
    _invoiceValueController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose of each controller when done
    _ewbNumberController.dispose();
    _lrNumberController.dispose();
    _invoiceNumberController.dispose();
    _invoiceValueController.dispose();
    _invoiceDateController.dispose();
    _ewbExpirationDateController.dispose();
    super.dispose();
  }

  fetchLocalStorageDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // accesstoken = prefs.getString('accessToken');
    // USER_ID = prefs.getInt('USER_ID');
    // Company_ID = prefs.getInt('Company_ID');
    // tripNumber = prefs.getString('tripNumber');
    // argumentData = ModalRoute.of(context)!.settings.arguments;
    // print('details argumentData====>$argumentData');
    setState(() {
      argumentData;
      // tripNumber;
      // _lrNumberController.text = argumentData['lrNumber'];
      // if (argumentData['pageSelection'] == 'SCANNED_FLOW') {
      //   _ewbNumberController.text = argumentData['ewbNumber'];
      //   getEWBdetails(argumentData['ewbNumber'], argumentData['lrNumber']);
      // }
    });
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future getEWBdetails(ewbNumber, lrNumber) async {
    Utils.returnScreenLoader(context);
    http.Response response;
    var endPoint = GET_INVOICE_DETAILS +
        ewbNumber +
        '&lrNumber=' +
        // '109057636';
        lrNumber;
    ;
    // print('=======${BASE_URL + endPoint}');
    response = await http.get(Uri.parse(BASE_URL + endPoint), headers: {
      "Content-Type": "application/json",
      "accesstoken": accesstoken
    });
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    // print('get details api resp====>${mapResponse}');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if (mapResponse["status"] == "success") {
        setState(() {
          fetchedDetails = mapResponse['data'];
          _invoiceNumberController =
              TextEditingController(text: fetchedDetails['documentNumber']);
          _invoiceValueController = TextEditingController(
              text: fetchedDetails['documentValue'].toString());
          // _lrNumberController = TextEditingController(
          //     text: fetchedDetails['lrNumber'].toString());
          _invoiceDateController =
              TextEditingController(text: fetchedDetails['documentDate']);
          _ewbExpirationDateController =
              TextEditingController(text: fetchedDetails['ewayBillValidUpto']);
        });
      } else {
        setState(() {
          fetchedDetails = [] as Map;
        });
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, mapResponse['message'], false);
    }
  }

  void validateInvoiceDetails() {
    if (_ewbNumberController.text.isEmpty) {
      _showSnackBar("Please enter EWB Number", context, false);
    } else if (_invoiceNumberController.text.isEmpty) {
      _showSnackBar("Please enter invoice Number", context, false);
    } else if (_invoiceValueController.text.isEmpty) {
      _showSnackBar("Please enter invoice value", context, false);
    } else if (_invoiceDateController.text.isEmpty) {
      _showSnackBar("Please select invoice Date", context, false);
    } else if (_ewbExpirationDateController.text.isEmpty) {
      _showSnackBar("Please select expiration date", context, false);
    } else {
      saveInvoiceDetails();
    }
  }

  Future saveInvoiceDetails() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {
      "tripNumber": tripNumber.toString(),
      "lrNumber": _lrNumberController.text,
      "invoiceNumber": _invoiceNumberController.text,
      "invoiceDate": _invoiceDateController.text,
      "invoiceValue": _invoiceValueController.text,
      "ewayBillNumber": _ewbNumberController.text,
      // "ewayBillValidUpto": _ewbExpirationDateController.text,
      "ewayBillValidUpto": returnFormattedDate(),
      // "ewayBillValidUpto": DateFormat('dd-MM-yyyy').format(
      //     DateFormat('dd-MM-yyyy').parse(fetchedDetails['ewayBillValidUpto'])),
      "productDetails": fetchedDetails['productDetails']
    };
    var body = json.encode(map);

    print('invoice body====>$body');
    response = await http.post(Uri.parse(BASE_URL + SAVE_INVOICE_DETAILS),
        headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken
        },
        body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if (mapResponse["status"] == "success") {
        _showSnackBar(mapResponse['message'], context, true);
        Navigator.pushNamed(context, '/dashboardPage');
      } else {
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, mapResponse['message'], false);
    }
  }

  Future<void> _selectInvoiceDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDateController.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(_invoiceDateController.text)
          : _selectedDate,
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _invoiceDateController.text =
            DateFormat('dd-MM-yyyy').format(_selectedDate);
      });
    }
  }

  Future<void> _selectEwbExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ewbExpirationDateController.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(_ewbExpirationDateController.text)
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
        _ewbExpirationDateController.text =
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
                      children: [returnFormFeilds(), returnBottomButton()],
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
          //Delivery Order Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('LR Number'),
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
                  enabled: false,
                  autofocus: false,
                  controller: _lrNumberController,
                  decoration: const InputDecoration(
                      hintText: 'Enter LR No.',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  // initialValue: lrNumber,
                  onChanged: (value) {
                    lrNumber = value;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //Invoice Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Invoice Number'),
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
                  controller: _invoiceNumberController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Invoice Number',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  // initialValue: invoiceNumber,
                  onChanged: (value) {
                    setState(() {
                      if (_invoiceNumberController.text != value) {
                        final cursorPosition =
                            _invoiceNumberController.selection;
                        _invoiceNumberController.text = value;
                        _invoiceNumberController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //Invoice Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Invoice Value'),
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
                      : TextInputType.number,
                  controller: _invoiceValueController,
                  decoration: const InputDecoration(
                      hintText: 'Enter Invoice Value',
                      hintStyle: TextStyle(
                          fontFamily: ffGMedium,
                          fontSize: 15.0,
                          color: Colors.grey),
                      contentPadding: EdgeInsets.all(15),
                      border: InputBorder.none),
                  // initialValue: invoiceValue,
                  onChanged: (value) {
                    setState(() {
                      if (_invoiceValueController.text != value) {
                        final cursorPosition =
                            _invoiceValueController.selection;
                        _invoiceValueController.text = value;
                        _invoiceValueController.selection = cursorPosition;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          //invoice date selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('Invoice Date'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: InkWell(
                  onTap: () {
                    _selectInvoiceDate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // invoiceDate != null
                        //     ? '${DateFormat('dd-MM-yyyy').format(invoiceDate!)}'
                        //     : 'DD-MM-YYYY',
                        _invoiceDateController.text.isEmpty
                            ? 'Select Date'
                            : '${_invoiceDateController.text}',
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
          //ewb date valid upto
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Utils.returnInvoiceRedStar('E-Way Bill Valid Upto'),
              Container(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                decoration: BoxDecoration(
                  color: textinputBgColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
                width: screenWidth * 0.9,
                child: InkWell(
                  onTap: () {
                    _selectEwbExpirationDate(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _ewbExpirationDateController.text.isEmpty
                            ? 'Select Date'
                            // : '${_ewbExpirationDateController.text}',
                            // : DateFormat('dd-MM-yyyy').format(DateTime.tryParse(
                            //     _ewbExpirationDateController.text)),
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
          // Product Details Section
          Container(
              child: fetchedDetails['productDetails'] == null
                  ? const SizedBox.shrink()
                  : _buildProductDetails(fetchedDetails['productDetails'])),
        ],
      ),
    );
  }

  Widget _buildProductDetails(productArray) {
    return Card(
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTileTheme(
          data: const ExpansionTileThemeData(
            backgroundColor: whiteBgColor,
            collapsedBackgroundColor: whiteBgColor,
            iconColor: Colors.black,
            collapsedIconColor: Colors.grey,
          ),
          child: ExpansionTile(
            title: Text('Product Details',
                style: TextStyle(
                    fontFamily: ffGBold,
                    fontSize: 16,
                    color: HeadingTextColor)),
            children: [
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: buttonTextBgColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    _buildProductRow(fetchedDetails['descriptionTitle'],
                        fetchedDetails['countTitle'], 'title'),
                    Container(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: productArray.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProductRow(
                                  productArray[index]['productName'],
                                  productArray[index]['qty'].toString(),
                                  'subItems'),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  child: productArray.length == 1
                                      ? SizedBox.shrink()
                                      : Divider()),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(String productName, String units, String value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: screenWidth * 0.6,
            child: Text(productName,
                style: value == 'title'
                    ? TextStyle(
                        fontFamily: ffGBold,
                        fontSize: getScreenWidth(12),
                        color: color99999A)
                    : TextStyle(
                        color: black,
                        fontFamily: ffGMedium,
                        fontSize: getScreenWidth(14))),
          ),
          SizedBox(
            width: screenWidth * 0.15,
            child: Text(units,
                style: value == 'title'
                    ? TextStyle(
                        fontFamily: ffGBold,
                        fontSize: getProportionateScreenWidth(12),
                        color: color99999A)
                    : TextStyle(
                        color: black,
                        fontFamily: ffGMedium,
                        fontSize: getScreenWidth(14))),
          ),
        ],
      ),
    );
  }

  returnFormattedDate() {
//     String? dateStr = _ewbExpirationDateController.text; // Get the date string

// // Try to parse the date string to DateTime
//     DateTime? parsedDate = DateTime.tryParse(dateStr);

// // Check if the parsing was successful
//     if (parsedDate != null) {
//       // Format the DateTime to the desired format
//       String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
//       print(
//           'formattedDate=====>$formattedDate'); // Use the formatted date string as needed
//       return formattedDate;
//     } else {
//       // Handle the case where the date string could not be parsed
//       print('Invalid date format');
//       return 'Invlaid Date';
//     }

//     String text = _ewbExpirationDateController.text; // Input text

//     print('text kdkdk====>$text');

// // Regular expression to match only the date part in the dd-MM-yyyy format
//     // RegExp regExp = RegExp(r'(\d{2})-(\d{2})-(\d{4})');
//     RegExp regExp = RegExp(
//         r'(\d{2}-\d{2}-\d{4})|(\d{4}-\d{2}-\d{2})(?:\s\d{2}:\d{2}:\d{2})?');

// // Try to match the date in the string
//     RegExpMatch? match = regExp.firstMatch(text);

//     if (match != null) {
//       String extractedDate =
//           match.group(0)!; // Extract the full matched date (dd-MM-yyyy)
//       print('Extracted date: $extractedDate');
//       return extractedDate;
//     } else {
//       print('No date found in the string');
//       return 'PRaveen checking';
//     }

    String text = _ewbExpirationDateController.text;

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

  Widget returnBottomButton() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Utils.clearToasts(context);
        validateInvoiceDetails();
      },
      child: Container(
        margin: EdgeInsets.only(
            top: screenHeight * 0.02,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01),
        child: Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            side: BorderSide(width: 1, color: appThemeColor),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: appThemeColor,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            alignment: Alignment.center,
            height: screenHeight * 0.07,
            child: const Text(
              "Confirm",
              style: TextStyle(
                fontFamily: ffGSemiBold,
                fontSize: 18.0,
                color: buttonTextWhiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
