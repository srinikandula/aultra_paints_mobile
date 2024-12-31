import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/error_handling.dart';
import '../../utility/size_config.dart';
import '/utility/Colors.dart';
import '/utility/Fonts.dart';
import '/utility/Utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../services/config.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var accesstoken;
  var USER_ID;
  var USER_FULL_NAME;
  var USER_EMAIL;
  var USER_MOBILE_NUMBER;
  String USER_NAME = "";
  String USER_ROLE = "";
  String BACKEND_ROLE = "";

  var _selectedRadioButtonOption = 0;

  String stringResponse = '';

  var noVehiclePlaced = '0';
  var delivered = '0';
  var readyToPickup = '0';
  var inTransit = '0';
  var booked = '0';

  String roleCheck = "BA_LOGIN"; //DEALER_LOGIN,DRIVER_LOGIN, CONSIGNEE_LOGIN,

  String searchValue = '';
  var searchListData = [];

  TextEditingController _searchController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  var loggedUserRole;

  String pendingTitle = "PENDING ASSIGNMENT";
  String pendingSubTitle = "Vehicle, Driver to be assigned";
  String pendingStatus = "PENDING_ASSIGNMENT";

  String pickupTitle = "READY TO PICKUP";
  String pickupSubTitle = "Vehicle assigned, on the way to pickup";
  String pickupStatus = "READY_TO_PICKUP";

  String intransitTitle = "INTRANSIT";
  String intransitSubTitle = "Orders dispatched and on the way to destination";
  String intransitStatus = "INTRANSIT";

  String deliveredTitle = "DELIVERED";
  String deliveredSubTitle = "Orders delivered with ePOD";
  String deliveredStatus = "DELIVERED";

  String bookedTitle = "BOOKED";
  String bookedSubTitle = "Orders created, to be dispatched";
  String bookedStatus = "BOOKED";

  List dashboardArray = [];

  var dashBoardList = [
    // {"title": "PENDING", "description": "Pending Confirmation", "count": "0"},
    // {"title": "CONFIRMED", "description": "Orders Confirmed", "count": "0"},
    // {"title": "INTRANSIT", "description": "Orders Intransit", "count": "0"},
    // {"title": "DELIVERED", "description": "Orders Delivered", "count": "0"},
  ];

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          searchValue = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Map mapResponse = {};

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
    USER_EMAIL = prefs.getString('USER_EMAIL');
    USER_MOBILE_NUMBER = prefs.getString('USER_MOBILE_NUMBER');

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

    if (response.statusCode == 200) {
      Navigator.pop(context);
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];
      dashBoardList = [
        {
          "title": "Redeemed Points",
          "description": "Redeemed Points Confirmation",
          "count": apiResp['redeemablePoints']
        },
        {
          "title": "Earned Cash Reward",
          "description": "Earned Cash Reward Confirmation",
          "count": apiResp['cash']
        },
      ];
      setState(() {
        dashBoardList = dashBoardList;
      });
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
  }

  void logOut(context) async {
    clearStorage();
    // print('logout api check====');
    // Utils.returnScreenLoader(context);
    // http.Response response;
    // Map map = {
    //   "userid": USER_ID,
    // };
    // var body = json.encode(map);
    // response = await http.post(
    //   Uri.parse(BASE_URL + API_LOGOUT),
    //   headers: {"Content-Type": "application/json", "Authorization": accesstoken},
    //   body: body,
    // );
    // stringResponse = response.body;
    // mapResponse = json.decode(response.body);
    // if (response.statusCode == 200) {
    //   Navigator.pop(context);
    //   if (mapResponse["status"] == "success") {
    //     _showSnackBar(mapResponse['message'], context, true);
    //     clearStorage();
    //   } else {
    //     error_handling.errorValidation(
    //         context, response.statusCode, mapResponse['message'], false);
    //   }
    // } else {
    //   Navigator.pop(context);
    //   error_handling.errorValidation(
    //       context, response.statusCode, mapResponse['message'], false);
    // }
  }

  Future<bool> _onWillPop() async {
    // print('back button hitted');
    Utils.clearToasts(context);
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    // FocusNode _focusNode = FocusNode();
    // TextEditingController _searchController = TextEditingController();
    final double screenWidth = MediaQuery.of(context).size.width;
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: white,
        drawer: MyDrawer(
          accountName: USER_FULL_NAME.toString(),
          accountRole: USER_ID.toString(),
          backendRole: BACKEND_ROLE,
          accountEmail: USER_EMAIL.toString(),
          onLogout: () => {logOut(context)},
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 1,
                child: Center(
                    child: Container(
                        color: white,
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.07,
                                    left: MediaQuery.of(context).size.width *
                                        0.05,
                                    right: MediaQuery.of(context).size.width *
                                        0.05),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/app_logo.png',
                                            height: getScreenHeight(50),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            _scaffoldKey.currentState
                                                ?.openDrawer();
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: loginBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Image.asset(
                                                'assets/images/menu@3x.png',
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, '/qrScanner').then((result) {
                                              if (result == true) {
                                                getDashboardCounts();
                                                setState(() {

                                                });
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 30,
                                            decoration: BoxDecoration(
                                              color: loginBgColor,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Center(
                                                child: Icon(
                                                  FontAwesomeIcons.qrcode,
                                                  size: 22,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Container(
                              child: searchListData.length >= 2
                                  ? Container(
                                      child: ListView.builder(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        shrinkWrap: true,
                                        itemCount: searchListData.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildProductRow(
                                                  searchListData[index]
                                                          ['lrNumber']
                                                      .toString(),
                                                  loggedUserRole == 'DEALER'
                                                      ? searchValue
                                                      // searchListData[index]
                                                      //         ['vin']
                                                      //     .toString()
                                                      : searchListData[index]
                                                              ['lrStatus']
                                                          .toString(),
                                                  searchListData[index]),
                                              Container(
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 15),
                                                  child:
                                                      searchListData.length == 1
                                                          ? null
                                                          : Divider()),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Container(
                                          //   padding: EdgeInsets.only(left: 5),
                                          //   child: Text(
                                          //     loggedUserRole == 'DEALER'
                                          //         ? 'Search by LR Number, Invoice/DO Number and VIN Number.'
                                          //         : loggedUserRole == 'CUSTOMER'
                                          //             ? 'Search by LR Number, Trip Number and Indent Number.'
                                          //             : loggedUserRole ==
                                          //                         'DRIVER' ||
                                          //                     loggedUserRole ==
                                          //                         'BA'
                                          //                 ? 'Search by LR Number and Trip Number.'
                                          //                 : 'Search by LR Number, Invoice Number and DO Number.',
                                          //     style: TextStyle(
                                          //         fontSize: 13,
                                          //         fontFamily: ffGMediumItalic,
                                          //         color: hintTextColor),
                                          //   ),
                                          // ),
                                          // SizedBox(height: 16),
                                          Text(
                                            ' Dashboard',
                                            style: TextStyle(
                                              color: HeadingTextColor,
                                              fontSize: 14,
                                              fontFamily: ffGSemiBold,
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Container(
                                            // onRefresh: getDashboardCounts,
                                            color: whiteBgColor,
                                            child: dashBoardList.isEmpty
                                                ? Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.6,
                                                    child: ListView(
                                                      physics:
                                                          AlwaysScrollableScrollPhysics(), // Ensures scroll behavior
                                                      children: [],
                                                    ),
                                                  )
                                                : ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        NeverScrollableScrollPhysics(), // Ensures scrollability
                                                    padding: EdgeInsets.zero,
                                                    itemCount:
                                                        dashBoardList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var dashboardCard =
                                                          dashBoardList[index];
                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                            onTap: () {
                                                              // if (dashboardCard[
                                                              //         'count'] !=
                                                              //     '0') {
                                                              // Utils.clearToasts(
                                                              //     context);
                                                              // Navigator
                                                              //     .pushNamed(
                                                              //   context,
                                                              //   // '/orderDetails',
                                                              //   '/ordersList',
                                                              //   arguments: {
                                                              //     'argumentStatus':
                                                              //         dashboardCard[
                                                              //             'status'],
                                                              //   },
                                                              // ).then((result) {
                                                              //   if (result ==
                                                              //       true) {
                                                              //     // getDashboardCounts();
                                                              //     setState(() {
                                                              //       searchValue =
                                                              //           '';
                                                              //       searchListData =
                                                              //           [];
                                                              //       _searchController
                                                              //           .clear();
                                                              //     });
                                                              //   }
                                                              // });
                                                              // }
                                                            },
                                                            child:
                                                                _buildDashboardCard(
                                                              dashboardCard[
                                                                      'title']
                                                                  .toString(),
                                                              dashboardCard[
                                                                      'description']
                                                                  .toString(),
                                                              dashboardCard[
                                                                      'count']
                                                                  .toString(),
                                                              buttonTextBgColor,
                                                              buttonTextBgColor,
                                                              '',
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                          ),

                                          // Divider(),

                                          // InkWell(
                                          //   onTap: () async {
                                          //     SharedPreferences prefs =
                                          //         await SharedPreferences
                                          //             .getInstance();
                                          //     await prefs.setInt(
                                          //         'Selected_indentId', 00);
                                          //     await prefs.setBool(
                                          //         'Indent_Editing', true);
                                          //     await prefs.setBool(
                                          //         'fromDashboardScreen', true);

                                          //     Navigator.pushNamed(
                                          //             context, '/createOrders')
                                          //         .then((result) {
                                          //       setState(() {
                                          //         searchValue = '';
                                          //         searchListData = [];
                                          //         _searchController.clear();
                                          //       });
                                          //     });
                                          //   },
                                          //   child: _buildDashboardCard(
                                          //       'CREATE ORDER ',
                                          //       'A new order can be created in next screen',
                                          //       "#123",
                                          //       buttonTextBgColor,
                                          //       buttonTextBgColor,
                                          //       'indent_create'),
                                          // )
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ))),
              ),
            )),
      ),
    );
  }

  Widget _buildProductRow(String productName, String units, totalData) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () async {
        Utils.clearToasts(context);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('tripNumber', totalData['tripNumber']);
        await prefs.setString('tripId', totalData['tripId'].toString());
        Navigator.pushNamed(context, '/tripDetails', arguments: {
          "responseData": totalData,
          "lrNumber": totalData['lrNumber'],
          "fromScreen": 'dashBoard'
        }).then((result) {
          setState(() {
            searchValue = '';
            searchListData = [];
            _searchController.clear();
          });
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: Icon(
                  Icons.book,
                  size: 18,
                  color: backButtonCircleIconColor,
                )),
            Container(
              width: screenWidth * 0.5,
              child: Text(productName,
                  style: TextStyle(fontFamily: ffGMedium, fontSize: 16)),
            ),
            Text(units, style: TextStyle(fontFamily: ffGMedium, fontSize: 16)),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: backButtonCircleIconColor,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String subtitle, String count,
      Color bgColor, Color borderColor, String fromButton) {
    return Card(
      elevation: 0,
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(getProportionateScreenWidth(10)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
            top: getProportionateScreenHeight(getProportionateScreenWidth(20)),
            bottom:
                getProportionateScreenHeight(getProportionateScreenWidth(20)),
            left: getProportionateScreenWidth(getProportionateScreenWidth(14)),
            right: (fromButton == 'indent_create'
                ? getProportionateScreenWidth(30)
                : getProportionateScreenWidth(0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: fromButton == 'indent_create'
                  ? getProportionateScreenWidth(200)
                  : getProportionateScreenWidth(200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: getProportionateScreenWidth(16),
                        fontFamily: ffGSemiBold,
                        color: buttonBorderColor),
                  ),
                  SizedBox(height: getProportionateScreenWidth(8)),
                  Container(
                    width: fromButton == 'indent_create'
                        ? getProportionateScreenWidth(200)
                        : getProportionateScreenWidth(190),
                    child: Text(subtitle,
                        style: TextStyle(
                            fontSize: getProportionateScreenWidth(14),
                            height: 1,
                            fontFamily: ffGMediumItalic,
                            color: subHeadingTextColor)),
                  ),
                ],
              ),
            ),
            count == "#123"
                ? Container(
                    width: getProportionateScreenWidth(60),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: appThemeColor,
                      size: 50,
                    ),
                  )
                : Container(
                    width: getProportionateScreenWidth(120),
                    alignment: Alignment.center,
                    child: Text(
                      count,
                      style: TextStyle(
                          fontSize: 37,
                          color: appButtonColor,
                          fontFamily: ffGBold),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

void _navigateTo(BuildContext context, String routeName) {
  Utils.clearToasts(context);
  Navigator.pop(context);
  Navigator.pushNamed(context, routeName);
}

const TextStyle drawerItemStyle = TextStyle(
  color: drawerSubListColor,
  fontFamily: ffGMedium,
  fontSize: 16,
);

class MyDrawer extends StatelessWidget {
  final String accountName;
  final String accountRole;
  final String backendRole;
  final String accountEmail;
  final VoidCallback onLogout;

  MyDrawer({
    required this.accountName,
    required this.accountRole,
    required this.backendRole,
    required this.accountEmail,
    required this.onLogout,
  });
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.1, horizontal: 20),
          children: <Widget>[
            Text(
              accountName,
              style: TextStyle(
                color: drawerTitleColor,
                fontFamily: ffGBold,
                fontSize: 16,
              ),
            ),
            Text(
              // accountEmail,
              // accountRole,
              accountEmail,
              style: TextStyle(
                color: drawerTitleColor,
                fontFamily: ffGMedium,
                fontSize: 14,
              ),
            ),
            Divider(thickness: 1),
            SizedBox(
                height: 15), // Consistent spacing before the ListTile items
            Container(
              height: screenHeight * 0.7,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: appThemeColor,
                        fontFamily: ffGSemiBold,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  accountRole == 'CUSTOMER'
                      ? ListTile(
                          title: Text(
                            'My Indents',
                            style: drawerItemStyle,
                          ),
                          onTap: () {
                            _navigateTo(context, '/tripsList');
                          },
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
            // SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.2),
              child: Divider(thickness: 2),
            ),
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
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                      color: drawerSubListColor,
                      fontFamily: ffGMedium,
                      fontSize: 16,
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
