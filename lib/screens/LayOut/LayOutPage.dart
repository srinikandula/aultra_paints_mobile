import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../services/UserViewModel.dart';
import '../../services/WidgetScreens/DealerSearchDialog.dart';
import '../../services/WidgetScreens/TransferPointsDialog.dart';
import '../../services/config.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import '../../utility/size_config.dart';
import '../../providers/cart_provider.dart';

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

  Future<void> fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accesstoken') ?? '';
    USER_ID = prefs.getString('USER_ID') ?? '';
    USER_FULL_NAME = prefs.getString('userName') ?? '';
    USER_MOBILE_NUMBER = prefs.getString('USER_MOBILE_NUMBER') ?? '';
    USER_ACCOUNT_TYPE = prefs.getString('USER_ACCOUNT_TYPE') ?? '';

    // Only call getDashboardCounts if we have a valid user
    if (USER_ID != null && USER_ID.isNotEmpty) {
      getDashboardCounts();
    }
  }

  Future<void> getDashboardCounts() async {
    if (USER_ID == null || USER_ID.isEmpty) {
      print('No user ID available for dashboard counts');
      return;
    }
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
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: getScreenWidth(18)),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(fontSize: getScreenWidth(16)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.grey, fontSize: getScreenWidth(14))),
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
              child: Text('Delete',
                  style: TextStyle(fontSize: getScreenWidth(14))),
            ),
          ],
        );
      },
    );
  }

  Future<void> clearStorage() async {
    Utils.clearToasts(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the current user ID before clearing
    final userId = prefs.getString('USER_ID');
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Save cart data if we have a user ID
    if (userId != null && cartProvider.itemCount > 0) {
      print(
          'Saving cart for user before logout: $userId with ${cartProvider.itemCount} items');
      await cartProvider.saveCart();
      print('Cart saved successfully');
    }

    // Clear shared preferences
    await prefs.clear();

    // Set cart provider user ID to null to clear current cart
    await cartProvider.setUserId(null);
    print('Cart cleared after logout');

    Navigator.of(context).pushNamed('/splashPage');
  }

  Future<void> logOut(BuildContext context) async {
    // Save cart data before clearing storage
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('USER_ID');

    if (userId != null && cartProvider.itemCount > 0) {
      print('Saving cart for user during logout: $userId');
      await cartProvider.saveCart();
      print('Cart saved successfully');
    }

    // Clear storage and navigate to splash page
    await clearStorage();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double appBarHeight = screenHeight * 0.09; // 9% of screen height
    final userViewModel = Provider.of<UserViewModel>(context);

    SizeConfig().init(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
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
          padding: EdgeInsets.only(
              left: screenWidth * 0.05,
              right: screenWidth * 0.05,
              top: screenHeight * 0.02),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.bars,
                        size: screenHeight * 0.028,
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
                    // padding: const EdgeInsets.all(6.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.02,
                    ),
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.qrcode,
                        size: screenHeight * 0.028,
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **User Details Section (Stays at the Top)**
            Container(
              margin: EdgeInsets.only(
                  top: screenHeight * 0.06,
                  bottom: screenHeight * 0,
                  left: screenWidth * 0.04,
                  right: screenWidth * 0.04),
              // margin: EdgeInsets.symmetric(
              //     horizontal: screenWidth * 0.08,
              //     vertical: screenHeight * 0.01),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
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
                      fontSize: screenHeight * 0.028,
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
                      fontSize: screenHeight * 0.020,
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
                              fontSize: screenHeight * 0.016,
                            )),
                        Text(parentDealerName,
                            style: TextStyle(
                                color: const Color(0xFF3533CD),
                                fontFamily: ffGBold,
                                fontSize: screenHeight * 0.016,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.pencil,
                            size: screenHeight * 0.016,
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
                          fontSize: screenHeight * 0.022,
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
                            fontSize: screenHeight * 0.022,
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
                            fontSize: screenHeight * 0.022,
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
                    ListTile(
                      title: Text(
                        'Points Ledger',
                        style: TextStyle(
                          color: const Color(0xFF3533CD),
                          fontFamily: ffGSemiBold,
                          fontSize: screenHeight * 0.022,
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/pointsLedgerPage');
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
                          fontSize: screenHeight * 0.022,
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
                          fontSize: screenHeight * 0.022,
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
                    size: screenHeight * 0.08,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Text(
                    "Success",
                    style: TextStyle(
                      fontSize: screenHeight * 0.04,
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
