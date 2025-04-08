import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/Utils.dart';
import '../../services/config.dart';
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

  Future<void> fetchLocalStorageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Wait for auth to be initialized
    if (!authProvider.isInitialized) {
      await authProvider.initialize();
    }

    USER_ID = prefs.getString('USER_ID') ?? '';
    USER_FULL_NAME = prefs.getString('USER_FULL_NAME') ?? '';
    USER_EMAIL = prefs.getString('USER_EMAIL') ?? '';
    USER_MOBILE_NUMBER = prefs.getString('USER_MOBILE_NUMBER') ?? '';
    USER_ACCOUNT_TYPE = prefs.getString('USER_ACCOUNT_TYPE') ?? '';

    if (USER_ID != null && USER_ID.isNotEmpty) {
      await Provider.of<CartProvider>(context, listen: false)
          .setUserId(USER_ID);
    }

    if (authProvider.isAuthenticated && USER_ID != null && USER_ID.isNotEmpty) {
      getDashboardDetails();
    }
  }

  Future<void> getDashboardDetails() async {
    if (USER_ID == null || USER_ID.isEmpty) {
      print('Missing user ID for dashboard details');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      print('User not authenticated');
      return;
    }

    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_USER_DETAILS + USER_ID;

    try {
      response =
          await http.get(Uri.parse(apiUrl), headers: authProvider.authHeaders);

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
          await prefs.setString(
              'parentDealerCode', parentDealerCode.toString());
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
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        Navigator.pop(context);
        // Clear auth and redirect to login
        await authProvider.clearAuth();
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        Navigator.pop(context);
        error_handling.errorValidation(
            context, response.statusCode, response.body, false);
      }
    } catch (e) {
      Navigator.pop(context);
      error_handling.errorValidation(context, 500,
          'An error occurred while fetching dashboard details', false);
    }
  }

  Future getProductOffers(String hitType) async {
    if (hitType == 'first') {
      getRewardSchemes();
    }
    if (isLoading) return;
    setState(() => isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      setState(() => isLoading = false);
      return;
    }

    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_PRODUCT_OFFERS;

    try {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: authProvider.authHeaders,
        body: json.encode({'page': currentPage, 'limit': 100}),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          // Ensure each offer has a valid ID
          var data = responseData['data'] as List;
          // print('=====responseee=========${data}');
          productOffers = data.map((offer) {
            String id;
            // if (offer['id'] == null || offer['id'].toString().isEmpty) {
            //   // Use productCode as primary identifier, fallback to productId, then to timestamp
            //   String? productCode = offer['productCode']?.toString();
            //   if (productCode != null && productCode.isNotEmpty) {
            //     id = productCode;
            //   } else {
            //     String? productId = offer['productId']?.toString();
            //     if (productId != null && productId.isNotEmpty) {
            //       id = productId;
            //     } else {
            //       // Use index-based ID to ensure uniqueness
            //       id =
            //           'product_${DateTime.now().millisecondsSinceEpoch}_${data.indexOf(offer)}';
            //     }
            //   }
            //   offer['id'] = id;
            // } else {
            //   id = offer['id'].toString();
            // }
            offer['id'] = offer['_id'];
            return offer;
          }).toList();

          // for (var offer in productOffers) {
          //   // print('=====Total=========${offer}');
          // }
        });
        setState(() => isLoading = false);
        return true;
      } else if (response.statusCode == 401) {
        // Handle unauthorized error
        setState(() => isLoading = false);
        // Clear auth and redirect to login
        await authProvider.clearAuth();
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        setState(() => isLoading = false);
        error_handling.errorValidation(
            context, response.statusCode, response.body, false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      error_handling.errorValidation(context, 500,
          'An error occurred while fetching product offers', false);
    }
  }

  Future getRewardSchemes() async {
    Utils.clearToasts(context);
    // Utils.returnScreenLoader(context);
    http.Response response;
    var apiUrl = BASE_URL + GET_REWARDS_SCHEMES;

    try {
      response = await http.get(
        Uri.parse(apiUrl),
        headers: Provider.of<AuthProvider>(context, listen: false).authHeaders,
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
    } catch (e) {
      error_handling.errorValidation(context, 500,
          'An error occurred while fetching reward schemes', false);
    }
  }

  Future<bool> _onWillPop() async {
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
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFF7AD),
                Color(0xFFFFA9F9),
              ],
            ),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  returnNameRewards(),
                  returnNewProductsScroll(),
                  const SizedBox(height: 24),
                  Text(
                    'Reward Schemes',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: bold,
                      color: const Color(0xFF3533CD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    child: rewardSchemes.isEmpty
                        ? Center(
                            child: Text(
                              'No reward schemes available',
                              style: TextStyle(
                                color: Colors.white,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  returnNameRewards() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: getScreenHeight(16)),
      padding: EdgeInsets.symmetric(
        horizontal: getScreenWidth(16),
        vertical: getScreenHeight(8),
      ),
      decoration: BoxDecoration(
        color: const Color(0x33800180),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${USER_FULL_NAME ?? 'Guest'}',
                style: TextStyle(
                  fontSize: getScreenWidth(24),
                  fontFamily: bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Reward Points: ${dashBoardList[0]['count']}',
                style: TextStyle(
                  fontSize: getScreenWidth(16),
                  fontFamily: medium,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Visibility(
            visible: USER_ACCOUNT_TYPE == 'Dealer',
            child: Consumer<CartProvider>(
              builder: (ctx, cart, _) => Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/cart');
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: getScreenWidth(28),
                    ),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: secondaryColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getScreenWidth(12),
                            fontFamily: medium,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  returnNewProductsScroll() {
    return Container(
      child: RefreshIndicator(
        onRefresh: () async {
          await getDashboardDetails();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ongoing Offers',
                style: TextStyle(
                  fontSize: getScreenWidth(24),
                  fontFamily: bold,
                  color: const Color(0xFF3533CD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: getScreenHeight(16)),
              SizedBox(
                height:
                    getScreenHeight(USER_ACCOUNT_TYPE == 'Dealer' ? 280 : 250),
                child: productOffers.isEmpty
                    ? Center(
                        child: Text(
                          'No offers available',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: getScreenWidth(16),
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
                            width: getScreenWidth(215),
                            margin: EdgeInsets.only(right: getScreenWidth(5)),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(getScreenWidth(16)),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(getScreenWidth(16)),
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
                                      height: getScreenHeight(
                                          USER_ACCOUNT_TYPE == 'Dealer'
                                              ? 160
                                              : 180),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(
                                                getScreenWidth(20)),
                                          ),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                                'assets/images/app_file_icon.png',
                                            image:
                                                offer['productOfferImageUrl'] ??
                                                    '',
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
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: getScreenWidth(12),
                                          vertical: getScreenHeight(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                offer['productOfferDescription'] ??
                                                    '',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: getScreenWidth(14),
                                                  fontFamily: medium,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            // SizedBox(height: getScreenHeight(4)),
                                            Visibility(
                                              visible:
                                                  USER_ACCOUNT_TYPE == 'Dealer',
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal:
                                                          getScreenWidth(8),
                                                      vertical:
                                                          getScreenHeight(4),
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: accentColor
                                                          .withOpacity(0.7),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              getScreenWidth(
                                                                  8)),
                                                    ),
                                                    child: Text(
                                                      'Price: ₹${offer['productPrice'] ?? '980'}',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getScreenWidth(12),
                                                        fontFamily: bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Consumer<CartProvider>(
                                                    builder: (ctx, cart, _) {
                                                      final quantity =
                                                          cart.getQuantity(
                                                              offer['id'] ??
                                                                  '');
                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                getScreenWidth(
                                                                    28),
                                                            height:
                                                                getScreenWidth(
                                                                    28),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                  Icons.remove,
                                                                  size:
                                                                      getScreenWidth(
                                                                          16)),
                                                              onPressed:
                                                                  quantity > 0
                                                                      ? () {
                                                                          cart.decrementQuantity(offer['id'] ??
                                                                              '');
                                                                        }
                                                                      : null,
                                                              style: IconButton
                                                                  .styleFrom(
                                                                backgroundColor: quantity >
                                                                        0
                                                                    ? primaryColor
                                                                        .withOpacity(
                                                                            0.1)
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.1),
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width:
                                                                getScreenWidth(
                                                                    24),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              '$quantity',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getScreenWidth(
                                                                        13),
                                                                fontFamily:
                                                                    medium,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                getScreenWidth(
                                                                    28),
                                                            height:
                                                                getScreenWidth(
                                                                    28),
                                                            child: IconButton(
                                                              icon: Icon(
                                                                  Icons.add,
                                                                  size:
                                                                      getScreenWidth(
                                                                          16)),
                                                              onPressed: () {
                                                                if (quantity <
                                                                    CartProvider
                                                                        .maxQuantity) {
                                                                  if (quantity ==
                                                                      0) {
                                                                    cart.addItem(
                                                                      offer['id'] ??
                                                                          '',
                                                                      offer['productOfferDescription'] ??
                                                                          '',
                                                                      double.parse(
                                                                          offer['productPrice']?.toString() ??
                                                                              '0'),
                                                                      offer['productOfferImageUrl'] ??
                                                                          '',
                                                                    );
                                                                  } else {
                                                                    cart.incrementQuantity(
                                                                        offer['id'] ??
                                                                            '');
                                                                  }
                                                                } else {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'Maximum quantity reached'),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              style: IconButton
                                                                  .styleFrom(
                                                                backgroundColor: quantity <
                                                                        CartProvider
                                                                            .maxQuantity
                                                                    ? primaryColor
                                                                        .withOpacity(
                                                                            0.1)
                                                                    : Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.1),
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
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
              if (isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getScreenWidth(8.0),
                      vertical: getScreenHeight(8.0)),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
