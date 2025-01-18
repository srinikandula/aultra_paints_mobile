import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import 'package:http/http.dart' as http;

import '../../../services/config.dart';
import '../../utility/loader.dart';
import '../../utility/size_config.dart';
import '../orders/qrScanner/QrScanner.dart';

class DashboardNewPage extends StatefulWidget {
  final Widget? child; // Make child optional

  const DashboardNewPage({Key? key, this.child}) : super(key: key);

  @override
  _DashboardNewPageState createState() => _DashboardNewPageState();
}

class _DashboardNewPageState extends State<DashboardNewPage> {
  final _formKey = GlobalKey<FormState>();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  var rewardSchemes = [];

  var accountType = '';
  var parentDealerCode = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    fetchLocalStorageData();
    super.initState();
    _pageController = PageController(viewportFraction: 0.6);
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_pageController.hasClients && rewardSchemes.isNotEmpty) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= rewardSchemes.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
        {"title": "Rewards ", "count": apiResp['cash']},
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
        getRewardSchemes();
        getProductOffers();

        _scrollController.addListener(() {
          if (_scrollController.position.pixels ==
                  _scrollController.position.maxScrollExtent &&
              !isLoading &&
              hasMore) {
            getProductOffers(); // Load more data when scrolled to bottom
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
    try {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": accesstoken
        },
        body: json.encode({'dealerCode': dealerCode}),
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

  Future saveDealerDetails(String dealerCode, String otp) async {
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

  Future getProductOffers() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      Utils.clearToasts(context);
      Utils.returnScreenLoader(context);
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
        Navigator.pop(context);
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
        Navigator.pop(context);
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
    Utils.returnScreenLoader(context);
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
      Navigator.pop(context);
      final responseData = json.decode(response.body);
      // print('======> ${responseData}');
      rewardSchemes = responseData;
      return true;
    } else {
      Navigator.pop(context);
      error_handling.errorValidation(
          context, response.body, response.body, false);
    }
    Navigator.pop(context);
    error_handling.errorValidation(context, response, response, false);
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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: _buildDrawer(),
        appBar: _buildAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeMessage(),
              _buildSectionTitle('Product Offers'),
              _buildProductOffers(),
              _buildSectionTitle('Current Schemes'),
              _buildCurrentSchemes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return MyDrawer(
      accountName: USER_FULL_NAME.toString(),
      accountId: USER_ID.toString(),
      accountMobile: USER_MOBILE_NUMBER.toString(),
      accountType: USER_ACCOUNT_TYPE.toString(),
      onLogout: () => logOut(context),
    );
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QrScanner(), // The screen where QR scanner is implemented
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.13),
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.05,
          left: MediaQuery.of(context).size.width * 0.05,
          right: MediaQuery.of(context).size.width * 0.05,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: _buildIconContainer('assets/images/menu@3x.png'),
            ),
            InkWell(
              onTap: () => _openQRScanner(),
              child: _buildIconContainer(
                null,
                icon: FontAwesomeIcons.qrcode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(String? imagePath, {IconData? icon}) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: loginBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 22, color: Colors.black)
              : Image.asset(imagePath!, fit: BoxFit.fill),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Welcome back, ${USER_FULL_NAME}',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: appThemeColor),
      ),
    );
  }

  Widget _buildProductOffers() {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: productOffers.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < productOffers.length) {
            final offer = productOffers[index];
            return _buildOfferCard(offer);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
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
        children: [
          // Offer Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/app_logo_load.png',
              image: offer['productOfferImageUrl'] ?? '',
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/app_logo_load.png',
                    fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              offer['productOfferTitle'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSchemes() {
    return SizedBox(
      height: 270,
      child: rewardSchemes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: rewardSchemes.length,
              itemBuilder: (context, index) {
                final scheme = rewardSchemes[index];
                return _buildRewardCard(scheme);
              },
            ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> scheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/images/app_logo_load.png',
          image: scheme['rewardSchemeImageUrl'] ?? '',
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset('assets/images/app_logo_load.png',
                fit: BoxFit.cover);
          },
        ),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String count, Color bgColor,
      Color borderColor, String fromButton) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0),
        child: InkWell(
          onTap: () {},
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${title} ',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: appThemeColor),
                textAlign: TextAlign.center,
              ),
              Text(
                count,
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }

  void showPopupForDealerCode(
      BuildContext context, Map<String, dynamic> response) {
    print('${!response['dealerCode'].isEmpty}=========>');
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
                      if (isOtpVisible) ...[
                        SizedBox(height: 20),
                        Text("Enter OTP", style: TextStyle(fontSize: 16)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  } else if (value.isEmpty && index > 0) {
                                    FocusScope.of(context).previousFocus();
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
                          stream: Stream.periodic(
                                  Duration(seconds: 1), (i) => 600 - i - 1)
                              .take(600),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final remainingSeconds = snapshot.data!;
                              final minutes = remainingSeconds ~/ 60;
                              final seconds = remainingSeconds % 60;
                              return Text(
                                'Time remaining: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ],
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Please enter Dealer Code."),
                                    ),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
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
                                } catch (error) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : Text("Get OTP"),
                            ),
                          if (isOtpVisible)
                            TextButton(
                              onPressed: () async {
                                String otp =
                                    otpControllers.map((e) => e.text).join();
                                if (otp.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "Please enter a valid 6-digit OTP.")),
                                  );
                                  return;
                                }

                                setState(() => isLoading = true);

                                try {
                                  bool saveSuccess = await saveDealerDetails(
                                    dealerCodeController.text,
                                    otp,
                                  );
                                  if (saveSuccess) {
                                    setState(() => isLoading = false);
                                    getDashboardCounts();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Details saved successfully.")),
                                    );
                                    Navigator.pop(context, true);
                                    Navigator.pop(context, true);
                                  }
                                } catch (error) {
                                  setState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                                }
                              },
                              child: isLoading
                                  ? CircularProgressIndicator()
                                  : Text("Save"),
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
}

class MyDrawer extends StatelessWidget {
  final String accountName;
  final String accountId;
  final String accountMobile;
  final String accountType;
  final VoidCallback onLogout;

  MyDrawer({
    required this.accountName,
    required this.accountId,
    required this.accountMobile,
    required this.accountType,
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
            topRight: Radius.circular(0),
            bottomRight: Radius.circular(0),
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
                fontSize: 24,
              ),
            ),
            Text(
              accountMobile,
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
                        fontSize: 22,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  if (accountType == 'Dealer')
                    ListTile(
                      title: Text(
                        'Painters',
                        style: TextStyle(
                          color: appThemeColor,
                          fontFamily: ffGSemiBold,
                          fontSize: 22,
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
                      decorationThickness: 1.5,
                      color: drawerSubListColor,
                      fontFamily: ffGMedium,
                      fontSize: 22,
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
