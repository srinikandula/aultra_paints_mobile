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
        }

        getProductOffers('first');

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
          context, response.body, response.body, false);
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
          context, response.body, response.body, false);
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
          context, response.body, response.body, false);
    }
  }

  Future getProductOffers(String hitType) async {
    if (hitType == 'first') {
      getRewardSchemes();
    }
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
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
        // Navigator.pop(context);
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
      } else if (response.statusCode == 404) {
        return false;
      } else {
        // Navigator.pop(context);
        error_handling.errorValidation(
            context, response.body, response.body, false);
      }
    } catch (error) {
      // final errorData = json.decode(error);
      Navigator.pop(context);
      error_handling.errorValidation(context, error, error, false);
    }
  }

  Future getRewardSchemes() async {
    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_REWARDS_SCHEMES;

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
      // print('======> ${responseData}');
      rewardSchemes = responseData;
      return true;
    } else {
      // Navigator.pop(context);
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
    // Navigator.pop(context);
    // error_handling.errorValidation(context, response, response, false);
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
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
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

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cardWidth = screenWidth * 0.9; // 80% of the screen width
    double cardHeight = 270; // Fixed height for the cards
    // double cardHeight = screenHeight * 0.9;
    double rewardCardHeight =
        screenHeight * 0.9; // 80% of theFixed height for the cards

    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white54,
          key: _scaffoldKey,
          body: SingleChildScrollView(
            // Add SingleChildScrollView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // decoration: BoxDecoration(
                  //   // color: appBarColor, // Background color
                  //   color: Colors.white, // Background color
                  //   borderRadius: BorderRadius.circular(20), // Rounded corners
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.grey.withOpacity(0.1),
                  //       spreadRadius: 3,
                  //       blurRadius: 5,
                  //       offset: const Offset(0, 3), // Shadow position
                  //     ),
                  //   ],
                  //   // border: Border.all(color: Colors.black, width: 1),
                  // ),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  padding: const EdgeInsets.only(bottom: 5, top: 10),
                  child: Text(
                    'Welcome, ${USER_FULL_NAME}',
                    style: TextStyle(
                      fontSize: getScreenWidth(26),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                //Product offer scroll
                Container(
                  margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
                  padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
                  child: Text(
                    'Product Offers',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                        fontSize: getScreenWidth(16),
                        fontWeight: FontWeight.bold,
                        color: appThemeColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Horizontal Reward Schemes List
                SizedBox(
                  height: getScreenHeight(
                      270), // Set the height for the horizontal list
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: getScreenWidth(8)),
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
                            width: getScreenWidth(150), // Width of each item
                            margin: EdgeInsets.only(
                                left: getScreenWidth(4),
                                right: getScreenWidth(4),
                                bottom: getScreenHeight(10)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(getScreenWidth(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: getScreenWidth(5),
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Reward Image
                                Container(
                                  height: getScreenWidth(160),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getScreenWidth(8),
                                      vertical: getScreenHeight(6)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                            getScreenWidth(10))),
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: getScreenWidth(2),
                                      vertical: getScreenHeight(2)),
                                  child: Column(
                                    children: [
                                      Text(
                                        offer['productOfferTitle'],
                                        maxLines: 2,
                                        overflow: TextOverflow
                                            .ellipsis, // Title of the reward
                                        style: TextStyle(
                                          fontSize: getScreenWidth(14),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: getScreenHeight(1)),
                                      Text(
                                        offer[
                                            'productOfferDescription'], // Description of the reward
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: getScreenWidth(12),
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
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

                //reward points count
                Container(
                  margin: EdgeInsets.symmetric(horizontal: getScreenWidth(10)),
                  child: dashBoardList.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.6,
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
                          itemCount: dashBoardList.length,
                          itemBuilder: (context, index) {
                            var dashboardCard = dashBoardList[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: _buildDashboardCard(
                                    dashboardCard['title'].toString(),
                                    dashboardCard['count'].toString(),
                                    white,
                                    buttonTextBgColor,
                                    '',
                                  ),
                                ),
                                SizedBox(height: getScreenHeight(5)),
                              ],
                            );
                          },
                        ),
                ),
                //rewards scroll
                Container(
                  margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
                  child: Text(
                    'Reward Schemes',
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 1.5,
                        fontSize: getScreenWidth(18),
                        fontWeight: FontWeight.bold,
                        color: appThemeColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: cardHeight,
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
                              scale =
                                  index == _currentPage!.round() ? 1.0 : 0.9;
                            }
                            return Transform.scale(
                              scale: scale, // Slightly shrink side cards
                              child: Align(
                                alignment: Alignment
                                    .topCenter, // Align cards to the top
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: getScreenHeight(8)),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        getScreenWidth(10)),
                                    color: Colors.white,
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
                                        width: getScreenWidth(250),
                                        height: getScreenWidth(220),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getScreenWidth(10),
                                            vertical: getScreenHeight(10)),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/app_file_icon.png', // Placeholder image
                                            image:
                                                item['rewardSchemeImageUrl'] ??
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
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ));
  }

  void showPopupForDealerCode(
      BuildContext context, Map<String, dynamic> response) {
    print('======dealer code===>${!response['dealerCode'].isEmpty}');
    final
        // showPopupForDealerCode(context, {'dealerCode': parentDealerCode, 'dealerName': userParentDealerName});

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
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 10,
                child: Container(
                  width: 400,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dealer Details",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: TextField(
                          controller: dealerCodeController,
                          keyboardType: TextInputType.text,
                          onTapOutside: (event) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Enter Dealer Code',
                            labelStyle: TextStyle(
                              fontFamily: 'Medium',
                              fontSize: 18.0,
                              color: Colors.grey,
                            ),
                            contentPadding: EdgeInsets.all(15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      !isOtpVisible
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                SizedBox(height: 20),
                                Text("Enter OTP",
                                    style: TextStyle(fontSize: 16)),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    return SizedBox(
                                      width: 40,
                                      child: TextField(
                                        controller: otpControllers[index],
                                        maxLength: 1,
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          counterText: "",
                                          border: OutlineInputBorder(),
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
                                SizedBox(height: 10),
                                Text(
                                    'The 6-digit OTP was sent to the ${userParentDealerName}. OTP expiry time is 10 minutes.',
                                    style: TextStyle(fontSize: 15)),
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
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
                              child: Text("Get OTP",
                                  style: TextStyle(
                                      fontSize: getScreenWidth(18),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blueAccent)),
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
                              child: Text("Save",
                                  style: TextStyle(
                                      fontSize: getScreenWidth(18),
                                      fontWeight: FontWeight.w900,
                                      color: Colors.blueAccent)),
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
                    fontSize: getScreenWidth(24),
                    fontWeight: FontWeight.bold,
                    color: appThemeColor),
                textAlign: TextAlign.center,
              ),
              Text(
                count,
                style: TextStyle(
                    fontSize: getScreenWidth(24),
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }
}
