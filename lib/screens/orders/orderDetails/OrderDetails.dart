import 'dart:convert';

import 'package:aultra_paints_mobile/utility/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/config.dart';
import '../../../services/error_handling.dart';
import '../../../utility/FooterButton.dart';
import '../../../utility/SingleParamHeader.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderDetails extends StatefulWidget {
  const OrderDetails({Key? key}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  int? selected;

  String? accessToken;
  dynamic orderDetails;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchLocalStorageData();
    });
  }

  Future<void> fetchLocalStorageData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString('accessToken');

      final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
      if (arguments != null && arguments.containsKey('orderDetails')) {
        final orderId = arguments['orderDetails']['_id'];
        await getOrderById(orderId);
      }
    } catch (e) {
      _showSnackBar('Failed to fetch data', context, false);
    }
  }

  void _showSnackBar(String message, BuildContext context, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      duration: Utils.returnStatusToastDuration(isSuccess),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getOrderById(String orderId) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL$GET_ORDER_BY_ID$orderId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": accessToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final apiResp = json.decode(response.body);
        setState(() {
          orderDetails = apiResp['data'];
        });
      } else {
        error_handling.errorValidation(
          context,
          response.statusCode,
          response.body,
          false,
        );
      }
    } catch (e) {
      _showSnackBar('Failed to fetch order details', context, false);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void onBackPressed() {
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
              'Order Details',
              '',
              context,
              false,
              () => Navigator.pop(context, true),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : orderDetails != null
                      ? SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                height: getScreenHeight(600),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                        'Brand', orderDetails['brand'] ?? ''),
                                    _buildInfoRow(
                                        'Volume',
                                        orderDetails['volume']?.toString() ??
                                            ''),
                                    _buildInfoRow('Product Name',
                                        orderDetails['productName'] ?? ''),
                                    _buildInfoRow(
                                        'Quantity',
                                        orderDetails['quantity']?.toString() ??
                                            ''),
                                  ],
                                ),
                              ),
                              // FooterButton(
                              //     "POST",
                              //     'download',
                              //     context,
                              //     () => {
                              //           Utils.clearToasts(context),
                              //         })
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'No order details available.',
                            style: TextStyle(color: labelTextColor),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.9,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: labelTextColor,
              fontFamily: ffGSemiBold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: labelValueTextColor,
              fontFamily: ffGSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
