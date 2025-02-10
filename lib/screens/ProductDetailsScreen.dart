import 'package:flutter/material.dart';

import '../utility/SingleParamHeader.dart';
import '../utility/Utils.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> productOffer;

  ProductDetailScreen({required this.productOffer});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  void onBackPressed() {
    Utils.clearToasts(context);
    Navigator.pushNamed(context, '/dashboardPage', arguments: {});
  }

  Future<bool> _onWillPop() async {
    onBackPressed();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            // appBar: AppBar(title: Text(widget.productOffer['productOfferTitle'])),
            body: Container(
                height: screenHeight, // 100% height
                width: screenWidth, // 100% width
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFFFFF7AD),
                      Color(0xFFFFA9F9),
                    ],
                  ),
                ),
                child: Column(children: [
                  // SingleParamHeader(productOffer['productOfferTitle'], '', context, false, () => Navigator.pop(context, true)),
                  SizedBox(
                    width: screenWidth,
                    child: Row(children: [
                      InkWell(
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          margin: EdgeInsets.only(
                              top: screenHeight * 0.06,
                              bottom: screenHeight * 0.03,
                              left: screenWidth * 0.05,
                              right: screenWidth * 0.05),
                          // margin: EdgeInsets.symmetric(
                          //   horizontal: screenWidth * 0.06,
                          //   vertical: screenHeight * 0.02,
                          // ),
                          child: Icon(
                            Icons.keyboard_double_arrow_left_sharp,
                            color: Color(0xFF7A0180),
                            size: screenWidth * 0.08,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          // decoration: BoxDecoration(
                          //   color: const Color(0x33800180),
                          //   borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          //   boxShadow: [
                          //     BoxShadow(
                          //       color: Colors.grey.withOpacity(0.1),
                          //       spreadRadius: 2,
                          //       blurRadius: screenWidth * 0.05,
                          //       offset: const Offset(0, 3),
                          //     ),
                          //   ],
                          // ),
                          // padding: EdgeInsets.symmetric(
                          //     horizontal: screenWidth * 0.04,
                          //     vertical: screenHeight * 0.02),
                          child: Image.network(
                            widget.productOffer['productOfferImageUrl'] ?? '',
                            height: screenHeight * 0.4,
                            width: screenWidth * 0.8,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.image),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.01),
                          child: Row(children: [
                            Flexible(
                              child: Text(
                                widget.productOffer['productOfferTitle'],
                                style: TextStyle(
                                    fontSize: unitHeightValue * 0.024,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ]),
                        ),
                        // SizedBox(height: 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.08,
                              vertical: screenHeight * 0.01),
                          child: Row(children: [
                            Flexible(
                              child: Text(
                                widget.productOffer[
                                        'productOfferDescription'] ??
                                    '',
                                style: TextStyle(
                                    fontSize: unitHeightValue * 0.018),
                              ),
                            )
                          ]),
                        )
                      ],
                    ),
                  )
                ]))));
  }
}
