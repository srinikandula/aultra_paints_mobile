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
    {"title": "PENDING", "description": "Orders pending", "count": "100"},
    {"title": "BOOKED", "description": "Orders booked", "count": "50"},
    {"title": "INTRANSIT", "description": "Orders Intransit", "count": "60"},
    {"title": "DELIVERED", "description": "Orders Delivered", "count": "05"},
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

    print(
        'dashboard====>${accesstoken}=====>${USER_FULL_NAME}===>${USER_EMAIL}');

    // getDashboardCounts();
  }

  clearStorage() async {
    Utils.clearToasts(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushNamed('/splashPage');
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
    //   headers: {"Content-Type": "application/json", "accesstoken": accesstoken},
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

  Future getDashboardCounts() async {
    Utils.returnDashboardScreenLoader(context);
    // Loader.showLoader(context);
    http.Response response;
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "accesstoken": accesstoken,
      "authorization": accesstoken
    };
    response = await http.get(Uri.parse(BASE_URL + GET_DASHBOARD_COUNTS),
        headers: headers);
    // print('headers======>${headers}');
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    if (response.statusCode == 200) {
      Navigator.pop(context);
      // Loader.hideLoader(context);
      if (mapResponse["status"] == "success") {
        var parsedResponse = mapResponse['data'];
        // print('dashboard respStarus====>$parsedResponse');
        noVehiclePlaced = parsedResponse['noVehiclePlaced'] != null
            ? parsedResponse['noVehiclePlaced'].toString()
            : '0';
        readyToPickup = parsedResponse['readyToPickup'] != null
            ? parsedResponse['readyToPickup'].toString()
            : '0';
        inTransit = parsedResponse['inTransit'] != null
            ? parsedResponse['inTransit'].toString()
            : '0';
        delivered = parsedResponse['delivered'] != null
            ? parsedResponse['delivered'].toString()
            : '0';
        booked = parsedResponse['booked'] != null
            ? parsedResponse['booked'].toString()
            : '0';

        var tempPendingObject = {
          'title': pendingTitle,
          'subtitle': pendingSubTitle,
          'count': noVehiclePlaced,
          'status': pendingStatus
        };
        var tempPickupObject = {
          'title': pickupTitle,
          'subtitle': pickupSubTitle,
          'count': readyToPickup,
          'status': pickupStatus
        };
        var tempBookedObject = {
          'title': bookedTitle,
          'subtitle': bookedSubTitle,
          'count': booked,
          'status': bookedStatus
        };
        var tempIntransitObject = {
          'title': intransitTitle,
          'subtitle': intransitSubTitle,
          'count': inTransit,
          'status': intransitStatus
        };
        var tempDeliveredObject = {
          'title': deliveredTitle,
          'subtitle': deliveredSubTitle,
          'count': delivered,
          'status': deliveredStatus
        };

        var finalArray = [];

        if (parsedResponse['noVehiclePlaced'] != null) {
          finalArray.add(tempPendingObject);
        }
        if (parsedResponse['booked'] != null) {
          finalArray.add(tempBookedObject);
        }
        if (parsedResponse['readyToPickup'] != null) {
          finalArray.add(tempPickupObject);
        }
        if (parsedResponse['inTransit'] != null) {
          finalArray.add(tempIntransitObject);
        }
        if (parsedResponse['delivered'] != null) {
          finalArray.add(tempDeliveredObject);
        }

        setState(() {
          dashboardArray = finalArray;
        });
      } else {
        setState(() {
          dashboardArray = [];
        });
        error_handling.errorValidation(
            context, response.statusCode, mapResponse['message'], false);
      }
    } else {
      setState(() {
        dashboardArray = [];
      });
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, mapResponse['message'], false);
    }
  }

  Future searchData() async {
    Utils.returnScreenLoader(context);
    http.Response response;
    Map map = {"vinOrLrOrInvoiceNo": searchValue};
    var body = json.encode(map);
    print('search body=======>${body}=======${BASE_URL + DASHBOARD_SEARCH}');
    response = await http.post(Uri.parse(BASE_URL + DASHBOARD_SEARCH),
        headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken
        },
        body: body);
    stringResponse = response.body;
    mapResponse = json.decode(response.body);
    // print('dash seaarch===>$mapResponse');
    if (response.statusCode == 200) {
      Navigator.pop(context);
      if (mapResponse["status"] == "success") {
        setState(() {
          searchListData = mapResponse['data'];
        });
        // print('search resp====>$searchListData');
        if (searchListData.length == 1) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'tripNumber', searchListData[0]['tripNumber'].toString());
          await prefs.setString(
              'tripId', searchListData[0]['tripId'].toString());
          Navigator.pushNamed(context, '/tripDetails', arguments: {
            "responseData": searchListData[0],
            "lrNumber": searchListData[0]['lrNumber'],
            "fromScreen": 'dashBoard'
          }).then((result) {
            setState(() {
              searchValue = '';
              searchListData = [];
              _searchController.clear();
            });
          });
        }
      } else {
        error_handling.errorValidation(
            context, response.statusCode, 'No Data found..', false);
      }
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, mapResponse['message'], false);
    }
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: white,
      barrierColor: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (
        BuildContext context,
      ) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Container(
            padding: EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select from below options',
                  style: TextStyle(
                    fontSize: 17,
                    fontFamily: ffGMedium,
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.only(top: 5),
                      backgroundColor: buttonTextBgColor,
                      // primary: buttonTextBgColor,
                      // onPrimary: Colors.red,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setInt('Selected_indentId', 00);
                      await prefs.setBool('Indent_Editing', true);
                      await prefs.setBool('fromDashboardScreen', true);
                      // Navigator.pushNamed(context, '/tripCreation',
                      //     arguments: {}).then((_) {
                      //   setState(() {
                      //     // _selectedRadioButtonOption = 1;
                      //   });
                      // });
                      Navigator.pushNamed(context, '/creationFirstScreen')
                          .then((result) {
                        setState(() {
                          searchValue = '';
                          searchListData = [];
                          _searchController.clear();
                        });
                      });
                    },
                    child: ListTile(
                      leading: Radio<int>(
                        activeColor: _selectedRadioButtonOption == 1
                            ? appButtonColor
                            : chatFromUserColor,
                        value: 1,
                        groupValue: _selectedRadioButtonOption,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedRadioButtonOption = 1;
                          });
                        },
                      ),
                      title: Text('Create Indent',
                          style: TextStyle(
                            fontFamily: ffGSemiBold,
                            color: popUpListColor,
                            fontSize: 20.0,
                          )),
                      contentPadding: EdgeInsets.zero,
                    )),
                SizedBox(height: 3.0),
                // ElevatedButton(
                //   style: ElevatedButton.styleFrom(
                //     padding: EdgeInsets.only(top: 5),
                //     primary: buttonTextBgColor,
                //     onPrimary: Colors.red,
                //   ),
                //   onPressed: () {
                //     Navigator.pop(context);
                //     Navigator.pushNamed(context, '/tripsList', arguments: {})
                //         .then((_) {
                //       setState(() {
                //         _selectedRadioButtonOption = 2;
                //       });
                //     });
                //   },
                //   child: ListTile(
                //     leading: Radio<int>(
                //       activeColor: _selectedRadioButtonOption == 2
                //           ? appButtonColor
                //           : chatFromUserColor,
                //       value: 2,
                //       groupValue: _selectedRadioButtonOption,
                //       onChanged: (int? value) {
                //         setState(() {
                //           _selectedRadioButtonOption = 2;
                //         });
                //       },
                //     ),
                //     title: Text('Create LR',
                //         style: TextStyle(
                //           fontFamily: ffGSemiBold,
                //           color: popUpListColor,
                //           fontSize: 20.0,
                //         )),
                //     contentPadding: EdgeInsets.zero,
                //   ),
                // ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel',
                      style: TextStyle(
                        fontFamily: ffGMedium,
                        color: buttonBorderColor,
                        fontSize: 16.0,
                      )),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white, // White background color
                    // primary: white, // White background color
                    side: BorderSide(
                        color: buttonBorderColor), // Red border color
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    // FocusNode _focusNode = FocusNode();
    // TextEditingController _searchController = TextEditingController();
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
                height: MediaQuery.of(context).size.height * 1.02,
                child: Center(
                    child: Container(
                        color: white,
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.1,
                                    left: MediaQuery.of(context).size.width *
                                        0.05,
                                    right: MediaQuery.of(context).size.width *
                                        0.05),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        _scaffoldKey.currentState?.openDrawer();
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
                                          padding: const EdgeInsets.all(4.0),
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
                                            context, '/qrScanner');
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
                                          padding: const EdgeInsets.all(6.0),
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
                                )),
                            //dashboard search
                            // Container(
                            //   padding: EdgeInsets.symmetric(horizontal: 10),
                            //   margin: EdgeInsets.only(
                            //       top: MediaQuery.of(context).size.width * 0.08,
                            //       left:
                            //           MediaQuery.of(context).size.width * 0.03,
                            //       right:
                            //           MediaQuery.of(context).size.width * 0.03),
                            //   decoration: BoxDecoration(
                            //       borderRadius: BorderRadius.circular(10),
                            //       border: Border.all(
                            //           width: 0,
                            //           color: white,
                            //           style: BorderStyle.solid)),
                            //   child: Container(
                            //     color: Color.fromRGBO(248, 250, 251, 1),
                            //     child: Row(
                            //       // mainAxisAlignment:
                            //       //     MainAxisAlignment.spaceAround,
                            //       children: [
                            //         Container(
                            //           margin:
                            //               EdgeInsets.symmetric(horizontal: 10),
                            //           width: MediaQuery.of(context).size.width *
                            //               0.05,
                            //           height:
                            //               MediaQuery.of(context).size.width *
                            //                   0.05,
                            //           decoration: const BoxDecoration(
                            //               image: DecorationImage(
                            //                   image: AssetImage(
                            //                       'assets/images/search.png'),
                            //                   fit: BoxFit.fill)),
                            //         ),
                            //         Container(
                            //           width: MediaQuery.of(context).size.width *
                            //               0.63,
                            //           child: TextFormField(
                            //             onTapOutside: (event) {
                            //               FocusManager.instance.primaryFocus
                            //                   ?.unfocus();
                            //             },
                            //             controller: _searchController,
                            //             focusNode: _focusNode,
                            //             decoration: const InputDecoration(
                            //                 hintText: 'Search',
                            //                 hintStyle: TextStyle(
                            //                     fontFamily: ffGMedium,
                            //                     fontSize: 14.0,
                            //                     color: searchHintTextColor),
                            //                 contentPadding:
                            //                     EdgeInsets.symmetric(
                            //                   vertical: 15,
                            //                 ),
                            //                 border: InputBorder.none),
                            //             onChanged: (value) {
                            //               // if (value.length >= 8) {
                            //               setState(() {
                            //                 searchValue = value;
                            //                 searchListData = [];
                            //               });
                            //               // }
                            //             },
                            //           ),
                            //         ),
                            //         Container(
                            //           child: searchValue.length >= 1
                            //               ? InkWell(
                            //                   onTap: () {
                            //                     setState(() {
                            //                       Utils.clearToasts(context);
                            //                       searchData();
                            //                     });
                            //                   },
                            //                   child: Container(
                            //                     padding: EdgeInsets.symmetric(
                            //                         horizontal: 5, vertical: 5),
                            //                     decoration: const BoxDecoration(
                            //                       color: Colors.blue,
                            //                       borderRadius:
                            //                           BorderRadius.all(
                            //                               Radius.circular(10)),
                            //                     ),
                            //                     child: const Text(
                            //                       "Search",
                            //                       style: TextStyle(
                            //                           fontFamily: ffGSemiBold,
                            //                           fontSize: 12.0,
                            //                           color: whiteBgColor),
                            //                     ),
                            //                   ),
                            //                 )
                            //               : null,
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
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
                                          SizedBox(height: 16),
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
                                                              if (dashboardCard[
                                                                      'count'] !=
                                                                  '0') {
                                                                Utils.clearToasts(
                                                                    context);
                                                                Navigator
                                                                    .pushNamed(
                                                                  context,
                                                                  '/orderDetails',
                                                                  arguments: {
                                                                    'argumentStatus':
                                                                        dashboardCard[
                                                                            'status'],
                                                                  },
                                                                ).then(
                                                                    (result) {
                                                                  if (result ==
                                                                      true) {
                                                                    // getDashboardCounts();
                                                                    setState(
                                                                        () {
                                                                      searchValue =
                                                                          '';
                                                                      searchListData =
                                                                          [];
                                                                      _searchController
                                                                          .clear();
                                                                    });
                                                                  }
                                                                });
                                                              }
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

                                          Divider(),

                                          InkWell(
                                            onTap: () async {
                                              SharedPreferences prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setInt(
                                                  'Selected_indentId', 00);
                                              await prefs.setBool(
                                                  'Indent_Editing', true);
                                              await prefs.setBool(
                                                  'fromDashboardScreen', true);

                                              Navigator.pushNamed(
                                                      context, '/createOrders')
                                                  .then((result) {
                                                setState(() {
                                                  searchValue = '';
                                                  searchListData = [];
                                                  _searchController.clear();
                                                });
                                              });
                                            },
                                            child: _buildDashboardCard(
                                                'CREATE ORDER ',
                                                'A new order can be created in next screen',
                                                "#123",
                                                buttonTextBgColor,
                                                buttonTextBgColor,
                                                'indent_create'),
                                          )
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        ))),
              ),
            )),
        //   floatingActionButton: Stack(
        //     children: [
        //       // Padding(
        //       //   padding: const EdgeInsets.only(left: 50),
        //       //   child: Align(
        //       //     alignment: Alignment.bottomLeft,
        //       //     child: ElevatedButton(
        //       //       onPressed: () {
        //       //         _showBottomSheet(context);
        //       //       },
        //       //       child: Icon(
        //       //         Icons.add,
        //       //         color: floatingIconButtonColor,
        //       //         size: 40,
        //       //       ),
        //       //       style: ElevatedButton.styleFrom(
        //       //         backgroundColor: floatingIconButtonBgColor,
        //       //         shape: CircleBorder(),
        //       //         padding: EdgeInsets.all(10),
        //       //       ),
        //       //     ),
        //       //   ),
        //       // ),
        //       Align(
        //         alignment: Alignment.bottomRight,
        //         child: ElevatedButton(
        //           onPressed: () {},
        //           child: Text(
        //             'SOS',
        //             style: TextStyle(
        //                 color: appButtonColor,
        //                 fontSize: 16,
        //                 fontFamily: ffGSemiBold),
        //           ),
        //           style: ElevatedButton.styleFrom(
        //             backgroundColor: floatingButtonBgColor,
        //             shape: CircleBorder(),
        //             padding: EdgeInsets.all(18),
        //             side: BorderSide(
        //               width: 3.0,
        //               color: appButtonColor,
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
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
