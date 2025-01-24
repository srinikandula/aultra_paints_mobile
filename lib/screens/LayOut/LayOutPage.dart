import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/UserViewModel.dart';
import '../../services/config.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import '../../utility/loader.dart';
import '../../utility/size_config.dart';

import 'package:http/http.dart' as http;

class LayoutPage extends StatefulWidget {
  final Widget child; // Page content

  const LayoutPage({Key? key, required this.child}) : super(key: key);

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void updateParentDealerCode(String newCode) {
    setState(() {
      USER_PARENT_DEALER_CODE = newCode;
    });
  }

  var accesstoken;
  var USER_ID;
  var USER_FULL_NAME;
  var USER_MOBILE_NUMBER;
  var USER_ACCOUNT_TYPE;
  var USER_PARENT_DEALER_CODE;
  var userParentDealerMobile;
  var userParentDealerName;

  var dashBoardList = [];
  var accountType = '';
  var parentDealerCode = '';
  var parentDealerName = '';

  late final String accountName;
  late final String accountMobile;

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();
  }

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));

    // Find the Scaffold in the Widget tree and use it to show a SnackBar!
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    USER_FULL_NAME = prefs.getString('USER_FULL_NAME');
    USER_ID = prefs.getString('USER_ID');
    USER_MOBILE_NUMBER = prefs.getString('USER_MOBILE_NUMBER');
    USER_ACCOUNT_TYPE = prefs.getString('USER_ACCOUNT_TYPE');

    getDashboardCounts();
  }

  clearStorage() async {
    Utils.clearToasts(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushNamed('/splashPage');
  }

  Future getDashboardCounts() async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_DETAILS + USER_ID;

    response = await http.get(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": accesstoken
    });

    Navigator.pop(context); // Close the loader

    if (response.statusCode == 200) {
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];
      dashBoardList = [
        {"title": "Rewards ", "count": apiResp['cash']},
      ];
      setState(() {
        dashBoardList = dashBoardList;
        accountType = USER_ACCOUNT_TYPE;
        parentDealerCode = apiResp['parentDealerCode'] ?? '';
        if (parentDealerCode.isNotEmpty && accountType == 'Painter') {
          getUserDealer(parentDealerCode);
        } else if (parentDealerCode.isEmpty && accountType == 'Painter') {
          // showPopupForDealerCode(context, {'dealerCode': parentDealerCode, 'dealerName': userParentDealerName});
        }
        // if (parentDealerCode.isNotEmpty) {
        //   getUserDealer(parentDealerCode);
        // }
      });
    } else {
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
  }

  Future getUserDealer(dynamic dealer) async {
    print('${dealer}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_DEALER + dealer.trim();

    response = await http.get(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": accesstoken
    });

    Navigator.pop(context); // Close the loader
    if (response.statusCode == 200) {
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];
      setState(() {
        parentDealerCode = apiResp['dealerCode'] ?? '';
        parentDealerName = apiResp['name'] ?? '';
      });
    } else {
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
  }

  Future saveDealerDetails(String dealerCode, String otp) async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + VERIFY_OTP_UPDATE_USER;

    try {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": accesstoken
        },
        body: json.encode({
          'dealerCode': dealerCode,
          'otp': otp,
          'mobile': userParentDealerMobile,
          'painterMobile': USER_MOBILE_NUMBER
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (['', null, 0, false]
            .contains(responseData?["data"]?['parentDealerCode'])) {
          throw Exception(responseData["message"] ?? "Failed to save details.");
        } else {
          print(
              '${responseData['data']?['parentDealerCode']}=================??????????????????????/');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('USER_PARENT_DEALER_CODE',
              responseData['data']?['parentDealerCode'] ?? '');
          userViewModel
              .setParentDealerCode(responseData['data']?['parentDealerCode']);
          return true;
        }
      } else {
        throw Exception(
            "Failed to save details. Status code: ${response.statusCode}");
      }
    } catch (error) {
      print("Error saving dealer details: $error");
      throw Exception("An error occurred while saving dealer details.");
    }
  }

  Future fetchOtp(String dealerCode) async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_PARENT_DEALER_CODE_DETAILS;
    try {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": accesstoken
        },
        body: json.encode({'dealerCode': dealerCode.trim()}),
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Assume the API returns {"success": true/false, "message": "..."}
        if (['', null, 0, false].contains(responseData["data"]['dealerCode'])) {
          throw Exception(responseData["message"] ?? "Failed to fetch OTP.");
        } else {
          userParentDealerMobile = responseData["data"]['mobile'];
          userParentDealerName = responseData["data"]['name'];
          return true;
        }
      } else {
        print(response.statusCode == 400);
        if (response.statusCode == 400) {
          // throw Exception("Failed to fetch Dealer Code. Status code");
          Loader.hideLoader(context);
          final responseData = json.decode(response.body);
          print(responseData['message']);
          _showSnackBar(
            "${responseData['message']}.",
            context,
            false,
          );
          return false;
        } else {
          throw Exception(
              "Failed to fetch OTP. Status code: ${response.statusCode}");
        }
      }
    } catch (error) {
      print("Error fetching OTP: $error");
      Navigator.pop(context);
      throw Exception("An error occurred while requesting OTP.");
    }
  }

  void logOut(context) async {
    clearStorage();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09; // 15% of screen height

    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: white,
            // borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFF7AD),
                Color(0xFFFFA9F9),
              ],
            ),
          ),
          // padding: EdgeInsets.symmetric(
          //   horizontal: screenWidth * 0.05,
          //   vertical: screenHeight * 0.04,
          // ),
          padding: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.03),
          // padding: EdgeInsets.only(
          //     left: getScreenWidth(10),
          //     right: getScreenWidth(10),
          //     top: getScreenHeight(40)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.bars,
                        size: unitHeightValue * .028,
                        // color: Colors.white,
                        color: appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/app_file_icon.png',
                      height: getScreenHeight(50),
                    ),
                    Image.asset(
                      'assets/images/app_name.png',
                      height: getScreenHeight(30),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/qrScanner').then((result) {
                    if (result == true) {
                      getDashboardCounts();
                      setState(() {});
                    }
                  });
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.qrcode,
                        size: unitHeightValue * .028,
                        // color: Colors.white,
                        color: appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: widget.child,
      drawer: MyDrawer(
        accountName: USER_FULL_NAME.toString(),
        accountId: USER_ID.toString(),
        accountMobile: USER_MOBILE_NUMBER.toString(),
        accountType: USER_ACCOUNT_TYPE.toString(),
        parentDealerCode: parentDealerCode != ''
            ? parentDealerCode
            : userViewModel.parentDealerCode,
        parentDealerName: parentDealerName,
        onLogout: () => {logOut(context)},
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  final String accountName;
  final String accountId;
  final String accountMobile;
  final String accountType;
  final VoidCallback onLogout;
  final String parentDealerCode;
  final String parentDealerName;

  MyDrawer(
      {required this.accountName,
      required this.accountId,
      required this.accountMobile,
      required this.accountType,
      required this.onLogout,
      required this.parentDealerCode,
      required this.parentDealerName});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    return Drawer(
      // width: getScreenWidth(getTabletCheck() ? 200 : 260),
      width: screenWidth * 0.7,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: white,
          // borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFF7AD),
              Color(0xFFFFA9F9),
            ],
          ),
        ),
        child: ListView(
          // padding: EdgeInsets.symmetric(vertical: screenHeight * 0.05, horizontal: 0),
          padding: EdgeInsets.only(top: screenHeight * 0.05),
          children: <Widget>[
            Container(
              // height: screenHeight * 0.1,
              margin: EdgeInsets.symmetric(
                  horizontal: getScreenWidth(20),
                  vertical: getScreenHeight(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: TextStyle(
                      color: const Color(0xFF3533CD),
                      fontFamily: ffGBold,
                      fontSize: unitHeightValue * 0.03,
                    ),
                  ),
                  Text(accountType,
                      style: TextStyle(
                        color: const Color(0xFF3533CD),
                        fontFamily: ffGMedium,
                        fontSize: unitHeightValue * 0.018,
                      )),
                  Text(accountMobile,
                      style: TextStyle(
                        color: const Color(0xFF3533CD),
                        fontFamily: ffGMedium,
                        fontSize: unitHeightValue * 0.018,
                      )),
                  if (accountType == 'Painter')
                    Container(
                      // height: screenHeight * 0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('Dealer Name ',
                              style: TextStyle(
                                color: const Color(0xFF3533CD),
                                fontFamily: ffGMedium,
                                fontSize: unitHeightValue * 0.018,
                              )),
                          Text(parentDealerName,
                              style: TextStyle(
                                  color: const Color(0xFF3533CD),
                                  fontFamily: ffGBold,
                                  fontSize: unitHeightValue * 0.018,
                                  fontWeight: FontWeight.bold)),
                          // Icon(FontAwesomeIcons.circl, size: 10, color: drawerSubListColor,),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Text(accountMobile, style: TextStyle(color: drawerTitleColor, fontFamily: ffGMedium, fontSize: 14,),),
            Divider(thickness: 1),
            // SizedBox(height: 15), // Consistent spacing before the ListTile items
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0,
              ),
              height: screenHeight * 0.71,
              // margin: EdgeInsets.symmetric(
              //     horizontal: getScreenWidth(30), vertical: getScreenWidth(10)),
              // height: getScreenHeight(getTabletCheck() ? 400 : 530),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: const Color(0xFF3533CD),
                        fontFamily: ffGSemiBold,
                        fontSize: unitHeightValue * 0.028,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/dashboardPage');
                    },
                  ),
                  if (accountType == 'Dealer')
                    ListTile(
                      title: Text(
                        'My Partners',
                        style: TextStyle(
                          color: const Color(0xFF3533CD),
                          fontFamily: ffGSemiBold,
                          fontSize: unitHeightValue * 0.028,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/painters');
                      },
                    ),
                ],
              ),
            ),
            Divider(thickness: 1),
            InkWell(
              onTap: () {
                // Navigator.pop(context);
                onLogout();
              },
              child: ListTile(
                title: Center(
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: const Color(0xFF3533CD),
                      fontFamily: ffGMedium,
                      fontSize: unitHeightValue * 0.028,
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
}
