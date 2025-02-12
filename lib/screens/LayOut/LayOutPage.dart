import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/UserViewModel.dart';
import '../../services/WidgetScreens/DealerSearchDialog.dart';
import '../../services/WidgetScreens/TransferPointsDialog.dart';
import '../../services/config.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
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
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_DETAILS + USER_ID;

    response = await http.get(Uri.parse(apiUrl), headers: {
      "Content-Type": "application/json",
      "Authorization": accesstoken
    });

    // Navigator.pop(context); // Close the loader

    if (response.statusCode == 200) {
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];

      setState(() {
        accountType = USER_ACCOUNT_TYPE;
        parentDealerCode = apiResp['parentDealerCode'] ?? '';
        if (parentDealerCode.isNotEmpty && accountType == 'Painter') {
          getUserDealer(parentDealerCode);
        }
      });
    } else {
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
  }

  Future getUserDealer(dynamic dealer) async {
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

  void logOut(context) async {
    clearStorage();
  }

  Future deleteUserAccount() async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + DELETE_USER_ACCOUNT + USER_ID;

    // print('delete apiturl====>${apiUrl}');

    response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accesstoken
      },
      body: jsonEncode({}),
    );

    // print('error====>${response.body}======>${response.statusCode}');

    if (response.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pop(context);
      _showSnackBar('Account deleted successfully.', context, true);
      clearStorage();
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
  }

  void showAccountDeletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  // backgroundColor: Colors.red,
                  ),
              onPressed: () {
                // Add your account deletion logic here
                // Navigator.of(context).pop();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Account deleted successfully.'),
                //   ),
                // );
                deleteUserAccount();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    double appBarHeight = screenHeight * 0.09; // 15% of screen height

    final userViewModel = Provider.of<UserViewModel>(context);

    SizeConfig().init(context);

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
                      height: getScreenWidth(50),
                    ),
                    Image.asset(
                      'assets/images/app_name.png',
                      height: getScreenWidth(30),
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
        onAccountDelete: () => {showAccountDeletionDialog(context)},
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
  late final String parentDealerCode;
  late final String parentDealerName;
  final VoidCallback onAccountDelete;

  MyDrawer({
    required this.accountName,
    required this.accountId,
    required this.accountMobile,
    required this.accountType,
    required this.onLogout,
    required this.parentDealerCode,
    required this.parentDealerName,
    required this.onAccountDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = screenHeight * 0.01;

    return Drawer(
      width: screenWidth * 0.7,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: white,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFFFF7AD),
              Color(0xFFFFA9F9),
            ],
          ),
        ),
        child: Column(
          children: [
            // **User Details Section (Stays at the Top)**
            Container(
              margin: EdgeInsets.only(
                  top: screenHeight * 0.06,
                  bottom: screenHeight * 0,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08),
              // margin: EdgeInsets.symmetric(
              //     horizontal: screenWidth * 0.08,
              //     vertical: screenHeight * 0.01),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountName,
                    style: TextStyle(
                      color: accountType == 'Painter'
                          ? const Color(0xFF3498db)
                          : accountType == 'Dealer'
                              ? const Color(0xFF2ecc71)
                              : accountType == 'Contractor'
                                  ? const Color(0xFFe67e22)
                                  : accountType == 'SuperUser'
                                      ? const Color(0xFFe74c3c)
                                      : const Color(0xFF3533CD),
                      fontFamily: ffGBold,
                      fontSize: unitHeightValue * 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    accountMobile,
                    style: TextStyle(
                      color: accountType == 'Painter'
                          ? const Color(0xFF3498db)
                          : accountType == 'Dealer'
                              ? const Color(0xFF2ecc71)
                              : accountType == 'Contractor'
                                  ? const Color(0xFFe67e22)
                                  : accountType == 'SuperUser'
                                      ? const Color(0xFFe74c3c)
                                      : const Color(0xFF3533CD),
                      fontFamily: ffGMedium,
                      fontSize: unitHeightValue * 1.8,
                    ),
                  ),
                  if (accountType == 'Painter')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('My Dealer ',
                            style: TextStyle(
                              color: const Color(0xFF3533CD),
                              fontFamily: ffGMedium,
                              fontSize: unitHeightValue * 1.8,
                            )),
                        Text(parentDealerName,
                            style: TextStyle(
                                color: const Color(0xFF3533CD),
                                fontFamily: ffGBold,
                                fontSize: unitHeightValue * 1.8,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.pencil,
                            size: unitHeightValue * 1.8,
                            color: const Color(0xFF3533CD),
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return DealerSearchDialog(
                                  onDealerSelected:
                                      (String dealerCode, String dealerName) {
                                    parentDealerCode = dealerCode;
                                    parentDealerName = dealerName;
                                  },
                                  onDealerComplete: () {
                                    Navigator.pushNamed(
                                        context, '/dashboardPage');
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),

            Divider(thickness: 1),

            // **Scrollable Menu Section**
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Home',
                        style: TextStyle(
                          color: const Color(0xFF3533CD),
                          fontFamily: ffGSemiBold,
                          fontSize: unitHeightValue * 2.8,
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
                            fontSize: unitHeightValue * 2.8,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, '/painters');
                        },
                      ),
                    if (accountType == 'Painter')
                      ListTile(
                        title: Text(
                          'Transfer Points',
                          style: TextStyle(
                            color: const Color(0xFF3533CD),
                            fontFamily: ffGSemiBold,
                            fontSize: unitHeightValue * 2.8,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TransferPointsDialog(
                                accountId: accountId,
                                accountName: accountName,
                                onTransferComplete: () async {
                                  showSuccessPopup(context);
                                },
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // **Fixed Bottom Buttons**
            Column(
              children: [
                Divider(thickness: 1),
                InkWell(
                  onTap: () {
                    onAccountDelete();
                  },
                  child: ListTile(
                    title: Center(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: const Color(0xFF3533CD),
                          fontFamily: ffGMedium,
                          fontSize: unitHeightValue * 2.8,
                        ),
                      ),
                    ),
                  ),
                ),
                Divider(thickness: 1),
                InkWell(
                  onTap: () {
                    onLogout();
                  },
                  child: ListTile(
                    title: Center(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          color: const Color(0xFF3533CD),
                          fontFamily: ffGMedium,
                          fontSize: unitHeightValue * 2.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showSuccessPopup(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierDismissible: true, // Allows closing the popup by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context); // Close the popup
            Navigator.pushNamed(
                context, '/dashboardPage'); // Call callback function
            return true; // Allow dismissal
          },
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Container(
              padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.05,
                  horizontal: screenWidth * 0.05),
              width: screenWidth * 0.6,
              height: screenHeight * 0.28,
              decoration: BoxDecoration(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_outlined,
                    color: Colors.green,
                    size: unitHeightValue * 0.08,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    "Success",
                    style: TextStyle(
                      fontSize: unitHeightValue * 0.04,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF3533CD),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      Navigator.pushNamed(
          context, '/dashboardPage'); // Ensure callback is always called
    });
  }
}
