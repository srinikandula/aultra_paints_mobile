import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import 'package:http/http.dart' as http;

import '../../../services/config.dart';
import '../../utility/size_config.dart';
import '../ProductDetailsScreen.dart';

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

  var dashBoardList = [
    {"title": "Reward Points ", "count": '0'},
  ];

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

    final Color primaryColor = Color(0xFF6A1B9A); // Deep Purple
  final Color secondaryColor = Color(0xFFE91E63); // Pink
  final Color accentColor = Color(0xFFFFC107); // Amber

  // Font families
  static const String regular = 'Roboto';
  static const String medium = 'Roboto';
  static const String bold = 'Roboto';

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

    getDashboardDetails();
  }

  clearStorage() async {
    Utils.clearToasts(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.of(context).pushNamed('/splashPage');
  }

  Future getDashboardDetails() async {
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
          "title": "Reward Points ",
          "count": apiResp['rewardPoints'].toString()
        },
      ];

      accountType = USER_ACCOUNT_TYPE;
      parentDealerCode = apiResp['parentDealerCode'] ?? '';
      if (parentDealerCode.isEmpty && accountType == 'Painter') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'userParentDealerName', userParentDealerName.toString());
        await prefs.setString('parentDealerCode', parentDealerCode.toString());
        Navigator.pushNamed(context, '/painterPopUpPage', arguments: {})
            .then((result) {
          if (result == true) {
            getDashboardDetails();
            // getProductOffers('first');
            setState(() {});
          }
        });
        setState(() {
          dashBoardList;
          accountType;
          parentDealerCode;
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
    } else {
      Navigator.pop(context);
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
      body: json.encode({'page': currentPage, 'limit': 100}),
    );
    final responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      // List<dynamic> newOffers = responseData;
      // print('responseData====>${responseData}');
      setState(() {
        productOffers = responseData['data'];
        // currentPage++;
        // productOffers.addAll(newOffers);
        // if (newOffers.length < 4) {
        //   hasMore = false; // No more data to load
        // }
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
    // PageController _pageController = PageController(viewportFraction: 0.5);

    // // Timer to auto-scroll the PageView
    // Timer.periodic(Duration(seconds: 2), (Timer timer) {
    //   if (_pageController.hasClients && productOffers.isNotEmpty) {
    //     int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
    //     if (nextPage >= productOffers.length) {
    //       nextPage = 0; // Loop back to the first item
    //     }
    //     _pageController.animateToPage(
    //       nextPage,
    //       duration: Duration(milliseconds: 500),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });

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
                returnNameRewards(),
                // returnProductsScroll(),
                returnNewProductsScroll(),
                // returnRewardsScroll()
              ],
            ),
          )),
        ));
  }

  returnNameRewards() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    return Container(
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
          Row(children: [
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
          ])
        ],
      ),
    );
  }

  returnNewProductsScroll() {
    return Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await getDashboardDetails();
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ongoing Offers',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: bold,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: getScreenHeight(300),
                          child: productOffers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No offers available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: regular,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: productOffers.length,
                                  itemBuilder: (context, index) {
                                    final offer = productOffers[index];
                                    return Container(
                                      width: 220,
                                      margin: EdgeInsets.only(right: 16),
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                primaryColor.withOpacity(0.05),
                                                secondaryColor.withOpacity(0.05),
                                              ],
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                // width: screenWidth * 0.38,
                                                height: getScreenHeight(180),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.vertical(
                                                      top: Radius.circular(getScreenWidth(20)),
                                                    ),
                                                    child: FadeInImage.assetNetwork(
                                                      placeholder: 'assets/images/app_file_icon.png',
                                                      image: offer['productOfferImageUrl'] ?? '',
                                                      fit: BoxFit.cover,
                                                      imageErrorBuilder: (context, error, stackTrace) {
                                                        return Image.asset(
                                                          'assets/images/app_file_icon.png',
                                                          fit: BoxFit.cover,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      offer['productOfferDescription'] ?? '',
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: medium,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    SizedBox(height: 8),
                                                    // if (offer['productPrice'] != null)
                                                     
                                                      Container(
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: accentColor.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Text(
                                                          // 'Price: ₹${offer['productPrice']}',
                                                          'Price: ₹ 980',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontFamily: bold,
                                                            color: primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
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
                        SizedBox(height: 24),
                        Text(
                          'Reward Schemes',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: bold,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: rewardSchemes.isEmpty
                              ? Center(
                                  child: Text(
                                    'No reward schemes available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                      fontFamily: regular,
                                    ),
                                  ),
                                )
                              : PageView.builder(
                                  controller: _pageController,
                                  itemCount: rewardSchemes.length,
                                  itemBuilder: (context, index) {
                                    final scheme = rewardSchemes[index];
                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            primaryColor.withOpacity(0.1),
                                            secondaryColor.withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              scheme['rewardSchemeImageUrl'] ?? '',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.card_giftcard,
                                                    size: 48,
                                                    color: Colors.grey[400],
                                                  ),
                                                );
                                              },
                                            ),
                                            // Add a subtle gradient overlay for better text visibility if needed
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.3),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        if (isLoading)
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
  }

  returnProductsScroll() {
    PageController _pageController = PageController(viewportFraction: 0.5);

    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_pageController.hasClients && productOffers.isNotEmpty) {
        int nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= productOffers.length) {
          nextPage = 0;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
          padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
          child: Text(
            'Ongoing Offers',
            style: TextStyle(
              decorationThickness: 1.5,
              fontSize: unitHeightValue * 0.03,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3533CD),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: screenHeight * 0.31, //0.29 old
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: productOffers.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < productOffers.length) {
                  final offer = productOffers[index];
                  return GestureDetector(
                    onTap: () {
                      returnShowModalBottomSheet(offer);
                    },
                    child: Container(
                      width: screenWidth * 0.35,
                      margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.028,
                          vertical: screenHeight * 0.01),
                      padding: EdgeInsets.only(top: getScreenHeight(4)),
                      decoration: BoxDecoration(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            // width: screenWidth * 0.38,
                            height: screenHeight * 0.18,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(getScreenWidth(20))),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/app_file_icon.png',
                                image: offer['productOfferImageUrl'] ?? '',
                                fit: BoxFit.cover,
                                imageErrorBuilder:
                                    (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/app_file_icon.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          offer['productPrice'] != null
                              ? Text(
                                  'Price: ${offer['productPrice']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: unitHeightValue * 0.014,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox.shrink(),
                          Container(
                            width: screenWidth,
                            margin: EdgeInsets.only(
                                left: screenWidth * 0.018,
                                right: screenWidth * 0.018,
                                // top: screenHeight * 0.01,
                                bottom: screenHeight * 0.01),
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
                                  offer['productOfferDescription'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: unitHeightValue * 0.014,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ), 
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  returnShowModalBottomSheet(offer) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: screenHeight * 0.7,
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
              SizedBox(
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Icon(
                          Icons.clear_sharp,
                          color: const Color(0xFF7A0180),
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                // Allows scrolling inside the modal
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(getScreenWidth(20))),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/app_file_icon.png',
                          image: offer['productOfferImageUrl'] ?? '',
                          height: screenHeight * 0.5,
                          // width: screenWidth * 0.8,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/app_file_icon.png',
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      // Image.network(
                      //   offer['productOfferImageUrl'] ?? '',
                      //   height: screenHeight * 0.38,
                      //   width: screenWidth * 0.8,
                      //   fit: BoxFit.cover,
                      //   errorBuilder: (context, error, stackTrace) =>
                      //   const Icon(Icons.image),
                      // ),
                      const SizedBox(height: 20),
                      Container(
                        width: screenWidth,
                        // height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          color: const Color(0x33800180),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.05),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: screenWidth * 0.05,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.01,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   offer['productOfferTitle'] ?? '',
                            //   style: TextStyle(
                            //     fontSize: screenHeight * 0.024,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            // const SizedBox(height: 15),
                            Text(
                              offer['productOfferDescription'] ?? '',
                              style: TextStyle(
                                fontSize: screenHeight * 0.018,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  returnRewardsScroll() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: getScreenWidth(16)),
          padding: EdgeInsets.symmetric(vertical: getScreenHeight(10)),
          child: Text(
            'Reward Schemes',
            style: TextStyle(
              decorationThickness: 1.5,
              fontSize: unitHeightValue * 0.03,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3533CD),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: screenHeight * 0.28,
          child: rewardSchemes.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: rewardSchemes.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final item = rewardSchemes[index];
                    double scale = 0.9;
                    if (_currentPage != null) {
                      scale = index == _currentPage!.round() ? 1.0 : 0.9;
                    }

                    return GestureDetector(
                      onTap: () {
                        RewardSchemeDetails(item);
                      },
                      child: Transform.scale(
                        scale: scale,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(getScreenWidth(20)),
                              color: const Color(0x33800180),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.28,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/images/app_file_icon.png',
                                      image: item['rewardSchemeImageUrl'] ?? '',
                                      fit: BoxFit.cover,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/app_file_icon.png',
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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  RewardSchemeDetails(item) async {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          width: screenWidth,
          height: screenHeight * 0.7,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.02,
                        ),
                        child: Icon(
                          Icons.clear_sharp,
                          color: const Color(0xFF7A0180),
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  ClipRRect(
                    // borderRadius: const BorderRadius.vertical(
                    //   top: Radius.circular(20),
                    // ),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/app_file_icon.png',
                      image: item['rewardSchemeImageUrl'] ?? '',
                      // height: screenHeight * 0.45,
                      // width: screenWidth,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/app_file_icon.png',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  // Positioned(
                  //   top: 0,
                  //   right: 0,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.clear_sharp,
                  //         color: Color(0xFF7A0180)),
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
