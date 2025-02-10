import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utility/Utils.dart';
import '../config.dart';
import '../error_handling.dart';

class TransferPointsDialog extends StatefulWidget {
  final String accountId;
  final String accountName;
  final VoidCallback onTransferComplete;

  const TransferPointsDialog({
    Key? key,
    required this.accountId,
    required this.accountName,
    required this.onTransferComplete,
  }) : super(key: key);
  @override
  _TransferPointsDialogState createState() => _TransferPointsDialogState();
}

class _TransferPointsDialogState extends State<TransferPointsDialog> {
  var accesstoken;
<<<<<<< HEAD
  TextEditingController pointsController = TextEditingController();
  bool pointEnterErr = false;
  TextEditingController otpController = TextEditingController();
  bool otpSent = false;  // To track OTP state
  String rewardBalance = "0";  // Fetch from API if needed
=======
>>>>>>> origin/DPdev
  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();
  }
  fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
<<<<<<< HEAD
    await getDashboardDetails();
  }

=======
    getDashboardDetails();
  }

  TextEditingController pointsController = TextEditingController();
  bool pointEnterErr = false;
  TextEditingController otpController = TextEditingController();
  bool otpSent = false;  // To track OTP state
  String rewardBalance = "0";  // Fetch from API if needed

>>>>>>> origin/DPdev
  Future getDashboardDetails() async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_DETAILS + widget.accountId;

    response = await http.get(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": accesstoken
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];
<<<<<<< HEAD

      setState(() {  // Update the UI when data is fetched
        rewardBalance = apiResp['rewardPoints'].toString();
      });
=======
      rewardBalance = apiResp['rewardPoints'].toString();
>>>>>>> origin/DPdev
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(context, response.statusCode, response.body, false);
    }
  }

<<<<<<< HEAD

=======
>>>>>>> origin/DPdev
  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> transferPoints() async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + TRANSFER_TO_DEALER;
    var tempBody = json.encode({
      "rewardPoints": int.parse(pointsController.text)
    });
    response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        "Authorization": accesstoken
      },
      body: tempBody,
    );
    if (response.statusCode == 200) {
      Navigator.pop(context);
      var tempResp = json.decode(response.body);
<<<<<<< HEAD
      Navigator.pop(context, true);
      widget.onTransferComplete();
=======
      print('${tempResp}');
      print(tempResp);

      Navigator.pop(context, true);
      widget.onTransferComplete();
      _showSnackBar("Details saved successfully.", context, true);
>>>>>>> origin/DPdev
    } else {
      Navigator.pop(context);
      final tempResp = json.decode(response.body);
      error_handling.errorValidation(context, response.statusCode, tempResp['message'], false);
    }
  }

  void sendOTP() async {
    // Call Send OTP API

  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;

    // Determine the widest text width dynamically
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: "Reward Point Balance:", // Longest text for width calculation
        style: TextStyle(fontSize: unitHeightValue * 0.02),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    final double labelWidth = textPainter.width + 20; // Ensure padding for text
    const double rowHeight = 50; // Fixed row height for uniformity

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFF7AD),
              Color(0xFFFFA9F9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Transfer Points",
                  style: TextStyle(
                    fontSize: unitHeightValue * 0.025,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3533CD),
                  ),
                ),
                const Divider(thickness: 1),

                /// Table with uniform height and width
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      /// Row 1: Reward Point Balance
                      Container(
                        height: rowHeight, // Fixed row height
<<<<<<< HEAD
                        decoration: const BoxDecoration(
=======
                        decoration: BoxDecoration(
>>>>>>> origin/DPdev
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 1),
                          ),
                        ),
                        // padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            /// First Cell: Label (Fixed Width)
                            Container(
                              width: labelWidth,
                              alignment: Alignment.center,
                              child: Text(
                                "Reward Point Balance:",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: unitHeightValue * 0.02, color: const Color(0xFF3533CD),),
                              ),
                            ),

                            /// Second Cell: Balance
                            Expanded(
                              child: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
<<<<<<< HEAD
                                decoration: const BoxDecoration(
=======
                                decoration: BoxDecoration(
>>>>>>> origin/DPdev
                                  border: Border(
                                    left: BorderSide(color: Colors.black, width: 1),
                                  ),
                                ),
                                child: Text(
                                  rewardBalance,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: unitHeightValue * 0.03,
                                    color: const Color(0xFF3533CD),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Row 2: Transfer Points Input
                      Container(
                        height: rowHeight, // Fixed row height
                        // padding: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            /// First Cell: Label (Fixed Width)
                            Container(
                              width: labelWidth,
                              alignment: Alignment.center,
                              child: Text(
                                "Transfer Points:",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3533CD), fontSize: unitHeightValue * 0.02,),
                              ),
                            ),

                            /// Second Cell: Input Field
                            Expanded(
                              child: Container(
                                height: double.infinity,
                                alignment: Alignment.center,
<<<<<<< HEAD
                                decoration: const BoxDecoration(
=======
                                decoration: BoxDecoration(
>>>>>>> origin/DPdev
                                  border: Border(
                                    left: BorderSide(color: Colors.black, width: 1),
                                  ),
                                ),
                                child: TextField(
                                  controller: pointsController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: unitHeightValue * 0.02,
                                    color: const Color(0xFF3533CD),
                                    fontWeight: FontWeight.bold
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none, // Avoid double borders
                                    hintText: "Enter",
                                  ),
                                  enabled: !otpSent,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      int? points = int.tryParse(value);
                                      if (points != null) {
                                        if (points <= 0) {
                                          pointsController.clear();
                                          pointEnterErr = true;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Points must be greater than 0"))
                                          );
                                        } else if (points > int.parse(rewardBalance)) {
                                          pointsController.clear();
                                          pointEnterErr = true;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Points cannot exceed balance of $rewardBalance"))
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Row 3: Error Message
                      if (pointEnterErr)
                        Container(
                          height: 30,
<<<<<<< HEAD
                          decoration: const BoxDecoration(
=======
                          decoration: BoxDecoration(
>>>>>>> origin/DPdev
                            border: Border(
                              top: BorderSide(color: Colors.black, width: 1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "Please enter points to transfer",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: unitHeightValue * 0.018,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
<<<<<<< HEAD
                const SizedBox(height: 20),
=======
                SizedBox(height: 20),
>>>>>>> origin/DPdev

                if (!otpSent)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF000000),
                            Color(0xFF3533CD),
                          ],
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (pointsController.text.isEmpty) {
                            pointEnterErr = true;
                            ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
                              const SnackBar(content: Text("Please enter points to transfer"))
                            );
=======
                              SnackBar(content: Text("Please enter points to transfer"))
                            );
                            print('${pointEnterErr}================================');
>>>>>>> origin/DPdev
                            return;
                          }
                          pointEnterErr = false;
                          // sendOTP();
                          transferPoints();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text("Transfer",
                          style: TextStyle(
                            fontSize: unitHeightValue * 0.02,
                            color: Colors.white,
                            fontWeight: FontWeight.w300
                          ),
                        ),
                      ),
                    ),
                  ),

                // if (otpSent) ...[
                //   TextField(
                //     controller: otpController,
                //     keyboardType: TextInputType.number,
                //     maxLength: 6,
                //     textAlign: TextAlign.center,
                //     decoration: const InputDecoration(
                //       labelText: "Enter OTP",
                //       border: OutlineInputBorder(),
                //     ),
                //   ),
                //   SizedBox(height: 10),
                //   ElevatedButton(
                //     onPressed: verifyOTP,
                //     child: const Text("Confirm"),
                //   ),
                // ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
