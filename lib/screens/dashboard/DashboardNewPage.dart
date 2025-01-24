import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/UserViewModel.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import 'package:http/http.dart' as http;

import '../../../services/config.dart';
import '../../utility/loader.dart';
import '../../utility/size_config.dart';

class DashboardNewPage extends StatefulWidget {
  const DashboardNewPage({
    Key? key,
  }) : super(key: key);

  _DashboardNewPageState createState() => _DashboardNewPageState();
}

class _DashboardNewPageState extends State<DashboardNewPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  var accesstoken;
  var USER_ID;
  var USER_FULL_NAME;
  var USER_EMAIL;
  var USER_MOBILE_NUMBER;
  var USER_ACCOUNT_TYPE;
  var USER_PARENT_DEALER_CODE;
  var userParentDealerMobile;
  var userParentDealerName;

  var dashBoardList = [];

  // var productOffers = [];
  List<dynamic> productOffers = []; // Store product offers
  int currentPage = 1; // Current page for API pagination
  bool isLoading = false; // Whether more data is being fetched
  bool hasMore = true; // Check if more data is available
  ScrollController _scrollController = ScrollController();

  bool saveOtpButtonLoader = false;

  var rewardSchemes = [];

  var accountType = '';
  var parentDealerCode = '';

  final PageController _pageController = PageController();
  double? _currentPage;

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          _currentPage = _pageController.page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    USER_EMAIL = prefs.getString('USER_EMAIL');
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

    if (response.statusCode == 200) {
      Navigator.pop(context);
      var tempResp = json.decode(response.body);
      var apiResp = tempResp['data'];
      dashBoardList = [
        {"title": "Reward Points ", "count": apiResp['cash']},
      ];
      setState(() {
        dashBoardList = dashBoardList;
        accountType = USER_ACCOUNT_TYPE;
        parentDealerCode = apiResp['parentDealerCode'] ?? '';
        if (parentDealerCode.isEmpty && accountType == 'Painter') {
          showPopupForDealerCode(context, {
            'dealerCode': parentDealerCode,
            'dealerName': userParentDealerName
          });
        } else {
          getProductOffers('first');
        }

        //  getRewardSchemes();

        _scrollController.addListener(() {
          if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent &&
              !isLoading &&
              hasMore) {
            getProductOffers(''); // Load more data when scrolled to bottom
          }
        });
      });
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
    }
  }

  Future fetchOtp(String dealerCode) async {
    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_PARENT_DEALER_CODE_DETAILS;
    var tempBody = json.encode({'dealerCode': dealerCode.trim()});

    response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accesstoken
      },
      body: tempBody,
    );
    print(
        'tempBody====>${tempBody}====>${response.statusCode}====>${response.body}');
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
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
    }
  }

  Future saveDealerDetails(String dealerCode, String otp) async {
    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + VERIFY_OTP_UPDATE_USER;
    var tempBody = json.encode({
      'dealerCode': dealerCode,
      'otp': otp,
      'mobile': userParentDealerMobile,
      'painterMobile': USER_MOBILE_NUMBER
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
      // Navigator.pop(context);
      var tempResp = json.decode(response.body);

      setState(() => saveOtpButtonLoader = false);
      getDashboardCounts();
      Navigator.pop(context, true);
      _showSnackBar("Details saved successfully.", context, true);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('USER_PARENT_DEALER_CODE',
          tempResp['data']?['parentDealerCode'] ?? '');
      // userViewModel
      //     .setParentDealerCode(responseData['data']?['parentDealerCode']);
      // getRewardSchemes();
      // getProductOffers('first');
    } else {
      setState(() => saveOtpButtonLoader = false);
      // Navigator.pop(context);
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
    }
  }

  Future getProductOffers(String hitType) async {
    if (hitType == 'first') {
      getRewardSchemes();
    }
    if (isLoading) return;
    setState(() => isLoading = true);

    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_PRODUCT_OFFERS;
    print(apiUrl);
    response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accesstoken
      },
      body: json.encode({'page': currentPage, 'limit': 4}),
    );
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      List<dynamic> newOffers = responseData;
      setState(() {
        currentPage++;
        productOffers.addAll(newOffers);
        if (newOffers.length < 4) {
          hasMore = false; // No more data to load
        }
      });
      setState(() => isLoading = false);
      return true;
    } else {
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
    }
  }

  Future getRewardSchemes() async {
    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_REWARDS_SCHEMES;
    print(apiUrl);

    response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accesstoken
      },
      // body: json.encode({'dealerCode': dealerCode}),
    );
    if (response.statusCode == 200) {
      // Navigator.pop(context);
      final responseData = json.decode(response.body);

      setState(() {
        rewardSchemes = responseData;
      });
    } else {
      error_handling.errorValidation(
          context, response.statusCode, response.body, false);
    }
  }

  void logOut(context) async {
    clearStorage();
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
    PageController _pageController = PageController(viewportFraction: 0.6);

    // Timer to auto-scroll the PageView
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients && rewardSchemes.isNotEmpty) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= rewardSchemes.length) {
          nextPage = 0; // Loop back to the first item
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    double cardWidth = screenWidth * 0.9; // 80% of the screen width
    // Fixed height for the cards

    double cardHeight = getTabletCheck() ? 300 : 270;

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          // backgroundColor: Colors.white54,
          key: _scaffoldKey,
          body: SingleChildScrollView(
            // Add SingleChildScrollView
            child: Container(
              height: screenHeight,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0,
                      vertical: screenHeight * 0,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: screenHeight * 0.02,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x33800180),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${USER_FULL_NAME}',
                          style: TextStyle(
                            color: const Color(0xFF3533CD),
                            fontSize: unitHeightValue * 0.024,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            Text(
                              '${dashBoardList[0]['title']}',
                              style: TextStyle(
                                color: const Color(0xFF3533CD),
                                fontSize: unitHeightValue * 0.024,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              // margin: EdgeInsets.only(left: 10),
                              margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02,
                                vertical: screenHeight * 0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                '${dashBoardList[0]['count']}',
                                style: TextStyle(
                                  color: const Color(0xFF3533CD),
                                  fontSize: unitHeightValue * 0.024,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ]
                        )
                      ],
                    ),
                  ),
                  //rewards scroll
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
                    padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
                    child: Text(
                      'Reward Schemes',
                      style: TextStyle(
                        // decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                        fontSize: unitHeightValue * 0.03,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3533CD),),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.28,
                    child: rewardSchemes.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : PageView.builder(
                      controller: _pageController,
                      itemCount: rewardSchemes.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final item = rewardSchemes[index];
                        // Make sure _currentPage is initialized before using it
                        double scale = 0.9; // Default scale for side cards
                        if (_currentPage != null) {
                          scale = index == _currentPage!.round() ? 1.0 : 0.9;
                        }
                        return Transform.scale(
                          scale: scale, // Slightly shrink side cards
                          child: Align(
                            alignment: Alignment
                                .topCenter, // Align cards to the top
                            child: Container(
                              // margin: EdgeInsets.symmetric(
                              //     vertical: getScreenHeight(8)),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(getScreenWidth(20)),
                                // color: Colors.white,
                                color: const Color(0x33800180),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    // width: getScreenWidth(
                                    //     getTabletCheck() ? 100 : 250),
                                    // height: getScreenWidth(
                                    //     getTabletCheck() ? 100 : 250),
                                    height: screenHeight * 0.28,

                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: 'assets/images/app_file_icon.png', // Placeholder image
                                        image: item['rewardSchemeImageUrl'] ?? '', // Network image URL
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/app_file_icon.png', // Fallback image
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  //Product offer scroll
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
                    padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
                    child: Text(
                      'Ongoing Offers',
                      style: TextStyle(
                          // decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                          fontSize: unitHeightValue * 0.03,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF3533CD),),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // Horizontal Reward Schemes List
                  SizedBox(
                    // height: screenHeight * 0.32,
                    height: screenHeight * 0.28,
                    // width: screenWidth * 0.5,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0),
                      child: ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        itemCount: productOffers.length +
                            (hasMore
                                ? 1
                                : 0), // Show loading indicator if more data is available
                        itemBuilder: (context, index) {
                          if (index < productOffers.length) {
                            final offer = productOffers[index];
                            return Container(
                              width: screenWidth * 0.35,
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.028,
                                  vertical: screenHeight * 0.01),
                              decoration: BoxDecoration(
                                // color: Colors.white,
                                color: const Color(0x33800180),
                                borderRadius: BorderRadius.circular(getScreenWidth(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: getScreenWidth(5),
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Reward Image
                                  SizedBox(
                                    width: screenWidth * 0.35,
                                    height: screenWidth * 0.35,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(getScreenWidth(20))),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            'assets/images/app_file_icon.png', // Placeholder image
                                        image: offer['productOfferImageUrl'] ??
                                            '', // Network image URL
                                        fit: BoxFit.cover,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/app_file_icon.png', // Fallback image
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.018,
                                        vertical: screenHeight * 0.01),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.03,
                                        vertical: screenHeight * 0.01),
                                    decoration: BoxDecoration(
                                      color: const Color(0x33800180),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          offer['productOfferTitle'],
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis, // Title of the reward
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: unitHeightValue * 0.014,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        // SizedBox(height: getScreenHeight(1)),
                                        // Text(
                                        //   offer[
                                        //       'productOfferDescription'], // Description of the reward
                                        //   maxLines: 1,
                                        //   overflow: TextOverflow.ellipsis,
                                        //   style: TextStyle(
                                        //     fontSize: getScreenWidth(
                                        //         getTabletCheck() ? 10 : 12),
                                        //     color: Colors.grey[700],
                                        //   ),
                                        //   textAlign: TextAlign.center,
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Show a loading spinner at the bottom
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(getScreenWidth(8)),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          ),
        ));
  }

  void showPopupForDealerCode(BuildContext context, Map<String, dynamic> response) {
    print('======dealer code===>${!response['dealerCode'].isEmpty}');
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double unitHeightValue = MediaQuery.of(context).size.height;
        // Controller for the input fields
        TextEditingController dealerCodeController = TextEditingController();
    List<TextEditingController> otpControllers =
        List.generate(6, (index) => TextEditingController());

    bool isOtpVisible = false;
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by clicking outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return WillPopScope(
              onWillPop: () async => false, // Disable the back button
              child: Dialog(
                elevation: 10,
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
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.015,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dealer Code",
                        style: TextStyle(
                          color: const Color(0xFF7A0180),
                          fontSize: unitHeightValue * 0.018,
                          fontWeight: FontWeight.bold),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: white,
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
                        child: SizedBox(
                          height: screenHeight * 0.06,
                          child: TextField(
                            // keyboardType: TextInputType.number,
                            controller: dealerCodeController,
                            keyboardType: TextInputType.text,
                            onTapOutside: (event) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            style: TextStyle(
                              fontSize: getScreenWidth(18),
                              color: Colors.white,
                              fontFamily: ffGMedium,
                            ),
                            decoration: InputDecoration(
                              // labelText: '',
                              labelStyle: TextStyle(
                                fontFamily: ffGMedium,
                                fontSize: getScreenWidth(18),
                                color: textInputPlaceholderColor,
                              ),
                              hintText: 'Enter Dealer Code', // Placeholder text
                              hintStyle: TextStyle(
                                fontSize: unitHeightValue * 0.02,
                                color: textInputPlaceholderColor.withOpacity(0.7),
                                fontFamily: ffGMedium,
                              ),
                              floatingLabelBehavior: FloatingLabelBehavior.auto, // Default behavior
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.1,
                                vertical: screenHeight * 0.02,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10), // Optional border
                                borderSide: BorderSide.none,
                              ),
                              filled: true, // Optional for a filled background
                              fillColor: Colors.grey.withOpacity(0.1), // Optional background color
                            ),
                            // onChanged: (value) {
                            //   _loginRequest.phoneNumber = value.trim();
                            // },
                          ),
                        ),
                      ),
                      !isOtpVisible
                          ? SizedBox.shrink()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(height: getScreenHeight(20)),
                                Row(
                                  children: [
                                    Text(
                                      "Dealer Code",
                                      style: TextStyle(
                                          color: const Color(0xFF7A0180),
                                          fontSize: unitHeightValue * 0.018,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ]
                                ),
                                Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    return Container(
                                      width: getScreenWidth(40),
                                      decoration: BoxDecoration(
                                        color: white,
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
                                      child: TextField(
                                        controller: otpControllers[index],
                                        maxLength: 1,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: getScreenWidth(
                                              getTabletCheck() ? 12 : 18),
                                          color: Colors.white,
                                          fontFamily: ffGMedium,
                                        ),
                                        decoration: InputDecoration(
                                          fillColor: Colors.transparent, // Let the Container's background show
                                          counterText: "", // Hide the counter text (default "0/1")
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20), // Optional border
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                        ),
                                        onChanged: (value) {
                                          if (value.isNotEmpty && index < 5) {
                                            FocusScope.of(context).nextFocus();
                                          } else if (value.isEmpty &&
                                              index > 0) {
                                            FocusScope.of(context)
                                                .previousFocus();
                                          }
                                        },
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: getScreenHeight(10)),
                                Text(
                                    'The 6-digit OTP was sent to the ${userParentDealerName}. OTP expiry time is 10 minutes.',
                                    style: TextStyle(
                                        color: const Color(0xFF7A0180),
                                        fontSize: getScreenWidth(
                                            getTabletCheck() ? 12 : 15))),
                                StreamBuilder<int>(
                                  stream: Stream.periodic(Duration(seconds: 1),
                                      (i) => 600 - i - 1).take(600),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final remainingSeconds = snapshot.data!;
                                      final minutes = remainingSeconds ~/ 60;
                                      final seconds = remainingSeconds % 60;
                                      return Text(
                                        'Time remaining: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                            color: const Color(0xFF7A0180),
                                            fontSize: getScreenWidth(
                                                getTabletCheck() ? 12 : 15),
                                            fontWeight: FontWeight.bold),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                      SizedBox(height: getScreenHeight(20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!response['dealerCode'].isEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"),
                            ),
                          if (!isOtpVisible)
                            TextButton(
                              onPressed: () async {
                                if (dealerCodeController.text.isEmpty) {
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(content: Text("Please enter Dealer Code."),),
                                  // );
                                  error_handling.errorValidation(context, '',
                                      'Please enter Dealer Code.', false);
                                  return;
                                }

                                setState(() => isLoading = true);

                                bool success =
                                    await fetchOtp(dealerCodeController.text);
                                if (success) {
                                  setState(() {
                                    isOtpVisible = true;
                                    isLoading = false;
                                    Navigator.pop(context);
                                  });
                                } else {
                                  setState(() {
                                    isOtpVisible = false;
                                    isLoading = false;
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.01,
                                ),
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
                                alignment: Alignment.center,
                                height: screenHeight * 0.06,
                                child: Text(
                                  "Get OTP",
                                  style: TextStyle(
                                      fontSize: unitHeightValue * 0.02,
                                      color: Colors.white, fontWeight: FontWeight.w300
                                  ),
                                ),
                              ),
                            ),
                          if (isOtpVisible)
                            TextButton(
                              onPressed: () async {
                                String otp =
                                    otpControllers.map((e) => e.text).join();
                                if (otp.length == 6) {
                                  saveDealerDetails(
                                      dealerCodeController.text, otp);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please enter a valid 6-digit OTP.")),
                                  );
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.1,
                                  vertical: screenHeight * 0.01,
                                ),
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
                                alignment: Alignment.center,
                                height: screenHeight * 0.06,
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      fontSize: unitHeightValue * 0.02,
                                      color: Colors.white, fontWeight: FontWeight.w300
                                  ),
                                ),
                              ),
                            //   child: Text("OK",
                            //       style: TextStyle(
                            //           fontSize: unitHeightValue * 0.02,
                            //           fontWeight: FontWeight.w500,
                            //         color: const Color(0xFF7A0180),)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDashboardCard(String title, String count, Color bgColor,
      Color borderColor, String fromButton) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
        child: InkWell(
          onTap: () {},
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${title} ',
                style: TextStyle(
                    fontSize: getScreenWidth(getTabletCheck() ? 18 : 24),
                    fontWeight: FontWeight.bold,
                    color: appThemeColor),
                textAlign: TextAlign.center,
              ),
              Text(
                count,
                style: TextStyle(
                    fontSize: getScreenWidth(getTabletCheck() ? 18 : 24),
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }
}
