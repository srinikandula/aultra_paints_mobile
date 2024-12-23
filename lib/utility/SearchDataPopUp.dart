import 'dart:convert';
import 'dart:ffi';
import '/services/error_handling.dart';
import '/utility/size_config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/request/SearchDataHandling.dart';
import '../services/config.dart';
import 'Colors.dart';
import 'Fonts.dart';
import 'package:http/http.dart' as http;
import 'Utils.dart';

var accesstoken;
var USER_ID;
var Company_ID;

String stringResponse = '';
Map mapResponse = {};

List customerListResponse = [];
List apiResponse = [];

Map<String, dynamic> returnSearchSelected = {};

String TitleText = '';
String searchRequestType = '';
bool showCancelButton = false;

late var searchFromListData = [];
late var searchFromTotalListData = [];
late var tempSearchListData = [];
String customerId = '';

class SearchDataPopUp {
  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future getListBySearch(String searchValue, StateSetter setState,
      String searchCheck, BuildContext context) async {
    http.Response response;
    var endPoint;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesstoken = prefs.getString('accessToken');
    USER_ID = prefs.getInt('USER_ID');
    Company_ID = prefs.getInt('Company_ID');
    Map map = {};

    if (searchRequestType == 'customer_search') {
      endPoint = GET_CUSTOMERS_LIST_BY_SEARCH;
      map = {'customerCode': searchValue};
    } else if (searchRequestType == 'consignor_search') {
      endPoint = GET_CONSIGNOR_LIST_BY_SEARCH;
      map = {'consignorCode': searchValue, 'customerId': customerId};
    } else if (searchRequestType == 'consignee_search') {
      endPoint = GET_CONSIGNEE_LIST_BY_SEARCH;
      map = {'consigneeCode': searchValue, 'customerId': customerId};
    } else if (searchRequestType == 'product_search') {
      endPoint = GET_PRODUCT_LIST_BY_SEARCH;
      map = {'productName': searchValue, 'customerId': customerId};
    } else if (searchRequestType == 'vehicle_details_search') {
      endPoint = GET_VEHICLES_LIST + searchValue;
    } else if (searchRequestType == 'driver_details_search') {
      endPoint = GET_DRIVERS_LIST + searchValue;
    } else if (searchRequestType == 'gps_device_search' ||
        searchRequestType == 'new_gps_device_search') {
      endPoint = GET_GPS_DEVICES_LIST + searchValue;
    } else if (searchRequestType == 'serviceType_search') {
      endPoint = GET_SERVICES_LIST;
    } else if (searchRequestType == 'vehicleType_search') {
      endPoint = GET_VEHICLE_TYPES_LIST;
    }
    var apiURL = BASE_URL + endPoint;
    var tempBody = json.encode(map);
    // print(
    //     'searchCheck===>$searchCheck===searchRequestType===>$searchRequestType===apiURL===>$apiURL');

    if (searchCheck == 'primarySearch') {
      // Utils.returnScreenLoader(context);
      if (searchRequestType == 'customer_search' ||
          searchRequestType == 'consignor_search' ||
          searchRequestType == 'consignee_search' ||
          searchRequestType == 'product_search' ||
          searchRequestType == 'serviceType_search' ||
          searchRequestType == 'vehicleType_search') {
        response = await http.post(Uri.parse(apiURL),
            headers: {
              "Content-Type": "application/json",
              "accesstoken": accesstoken
            },
            body: tempBody);
      } else {
        response = await http.get(Uri.parse(apiURL), headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken
        });
      }
      stringResponse = response.body;
      mapResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pop(context);
        if (mapResponse["status"] == "success") {
          setState(() {
            customerListResponse = mapResponse['data'];
            apiResponse = mapResponse['data'];
            searchFromListData = mapResponse['data'];
            searchFromTotalListData = mapResponse['data'];
          });
        } else {
          Navigator.pop(context);
        }
      } else if (response.statusCode == 401) {
        Navigator.pop(context);
        error_handling.clearStorage(context);
      } else {
        Navigator.pop(context);
      }
    } else {
      if (searchRequestType == 'customer_search' ||
          searchRequestType == 'consignor_search' ||
          searchRequestType == 'consignee_search' ||
          searchRequestType == 'product_search' ||
          searchRequestType == 'serviceType_search' ||
          searchRequestType == 'vehicleType_search') {
        response = await http.post(Uri.parse(apiURL),
            headers: {
              "Content-Type": "application/json",
              "accesstoken": accesstoken
            },
            body: tempBody);
      } else {
        response = await http.get(Uri.parse(apiURL), headers: {
          "Content-Type": "application/json",
          "accesstoken": accesstoken
        });
      }
      stringResponse = response.body;
      mapResponse = json.decode(response.body);
      if (response.statusCode == 200) {
        if (mapResponse["status"] == "success") {
          setState(() {
            customerListResponse = mapResponse['data'];
            apiResponse = mapResponse['data'];
            searchFromListData = mapResponse['data'];
            searchFromTotalListData = mapResponse['data'];
          });
        }
      } else if (response.statusCode == 401) {
        error_handling.clearStorage(context);
      } else {
        setState(() {
          customerListResponse = [];
          apiResponse = [];
          searchFromListData = [];
          searchFromTotalListData = [];
        });
      }
    }
  }

  static Future<SearchDataHandling?> showPopupData(
      BuildContext context,
      String tag,
      StateSetter setState,
      String titleTag,
      String tempCustomerId,
      bool tempShowCancelButton) async {
    // print('showCancelButton====>$tempShowCancelButton');

    setState(() {
      searchRequestType = tag;
      TitleText = titleTag;
      customerId = tempCustomerId.toString();
      showCancelButton = tempShowCancelButton;
    });
    await SearchDataPopUp()
        .getListBySearch("", setState, 'primarySearch', context);

    return SearchDataPopUp().returnSearchData(context, showCancelButton);
  }

  //customer_search
  //vehicle_details_search
  //driver_details_search
  //gps_device_search

  returnDisplayText(tempValue) {
    // print('tempValue====>${tempValue}');
    if (searchRequestType == 'customer_search') {
      return '${tempValue['customerName'] ?? '--'} (${tempValue['customerCode'] ?? '--'})';
    } else if (searchRequestType == 'serviceType_search') {
      return '${tempValue['serviceType'] ?? '--'}';
    } else if (searchRequestType == 'vehicleType_search') {
      return '${tempValue['vehicleType'] ?? '--'}';
    } else if (searchRequestType == 'consignor_search') {
      return '${tempValue['consignorCompanyName'] ?? '--'} (${tempValue['consignorCode'] ?? '--'})';
    } else if (searchRequestType == 'consignee_search') {
      return '${tempValue['consigneeCompanyName'] ?? '--'} (${tempValue['consigneeCode'] ?? '--'})';
    } else if (searchRequestType == 'product_search') {
      return '${tempValue['productName'] ?? '--'} (${tempValue['productId']?.toString() ?? '--'})';
    } else if (searchRequestType == 'vehicle_details_search') {
      return '${tempValue['vehicleNo'] ?? '--'} (${tempValue['vehicleType'] ?? '--'})';
    } else if (searchRequestType == 'driver_details_search') {
      return '${tempValue['driverName'] ?? '--'} (${tempValue['driverMobileNo']?.toString() ?? '--'})';
    } else if (searchRequestType == 'gps_device_search' ||
        searchRequestType == 'new_gps_device_search') {
      return '${tempValue['gpsDisplayName'] ?? '--'}';
    }
  }

  Future<SearchDataHandling?> returnSearchData(
      BuildContext context, showCancelButton) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    FocusNode _focusNode = FocusNode();
    TextEditingController _searchController = TextEditingController();

    return showModalBottomSheet<SearchDataHandling>(
      context: context,
      backgroundColor: whiteBgColor,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async {
              return showCancelButton ? false : true;
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height:
                  _focusNode.hasFocus ? screenHeight * 0.8 : screenHeight * 0.4,
              child: Container(
                padding: EdgeInsets.all(5),
                color: whiteBgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // color: appThemeColor,
                          width: getScreenWidth(300),
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            TitleText,
                            style: const TextStyle(
                              fontFamily: ffGSemiBold,
                              color: popUpListColor,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showCancelButton,
                          child: InkWell(
                            onTap: () {
                              tempCloseDetails(context, setState);
                            },
                            child: Container(
                                margin: EdgeInsets.only(right: 15),
                                padding: EdgeInsets.all(getScreenWidth(6)),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius:
                                      BorderRadius.circular(getScreenWidth(50)),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: getScreenWidth(20),
                                  color: backButtonCircleIconColor,
                                )),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03, vertical: 5),
                        decoration: BoxDecoration(
                          color: textinputBgColor,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: whiteBgColor),
                              margin:
                                  EdgeInsets.only(left: 15, right: 15, top: 10),
                              child: TextFormField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  focusColor: labelColor,
                                  hintText: 'Type here ..',
                                  hintStyle: TextStyle(
                                    fontFamily: ffGSemiBold,
                                    fontSize: 15.0,
                                    color: labelTextColor,
                                  ),
                                  contentPadding: EdgeInsets.all(20),
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  if (searchRequestType ==
                                      'vehicleType_search') {
                                    tempSearchListData = searchFromTotalListData
                                        .where((row) => (row["vehicleType"]
                                            .toLowerCase()
                                            .contains(value.toLowerCase())))
                                        .toList();
                                    setState(() {
                                      customerListResponse = tempSearchListData;
                                    });
                                  } else if (searchRequestType ==
                                      'serviceType_search') {
                                    tempSearchListData = searchFromTotalListData
                                        .where((row) => (row["serviceType"]
                                            .toLowerCase()
                                            .contains(value.toLowerCase())))
                                        .toList();
                                    setState(() {
                                      customerListResponse = tempSearchListData;
                                    });
                                  } else {
                                    if (value.length >= 3) {
                                      SearchDataPopUp().getListBySearch(value,
                                          setState, 'secondarySearch', context);
                                    } else if (value.length == 0) {
                                      SearchDataPopUp().getListBySearch("",
                                          setState, 'secondarySearch', context);
                                    }
                                  }
                                },
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: customerListResponse == null ||
                                      customerListResponse.isEmpty
                                  ? Container(
                                      child: Text(
                                        'No data found',
                                        style: TextStyle(
                                          fontFamily: ffGMedium,
                                          fontSize: 15.0,
                                          color: Colors
                                              .grey, // Adjust color as needed
                                        ),
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: Column(
                                        children:
                                            customerListResponse.map((value) {
                                          return ListTile(
                                            onTap: () {
                                              savePrimaryDetails(
                                                  context, setState, value);
                                            },
                                            title: Text(
                                              returnDisplayText(value),
                                              style: const TextStyle(
                                                fontFamily: ffGMedium,
                                                fontSize: 15.0,
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void savePrimaryDetails(
      BuildContext context, StateSetter setState, Map<dynamic, dynamic> value) {
    // print('save reached===');
    returnSearchSelected = value.cast<String, dynamic>();

    Navigator.pop(
        context, SearchDataHandling(selectedSearchData: returnSearchSelected));
    // Navigator.pop(context);
  }

  void tempCloseDetails(BuildContext context, StateSetter setState) {
    // print('temp save reached===');
    Navigator.pop(context, SearchDataHandling(selectedSearchData: {}));
  }
}
