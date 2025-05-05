import 'package:flutter/material.dart';

import '../../providers/cart_provider.dart';
import '../../services/error_handling.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../providers/auth_provider.dart';
import '../../services/error_handling.dart';
import '../../utility/Utils.dart';
import '../../services/config.dart';
import '../../utility/size_config.dart';

import '../ProductDetailsScreen.dart';

class ProductsCatalogScreen extends StatefulWidget {
  @override
  _ProductsCatalogScreenState createState() => _ProductsCatalogScreenState();
}

class _ProductsCatalogScreenState extends State<ProductsCatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  double? _currentPage;
  final Color primaryColor = Color(0xFF6A1B9A); // Deep Purple
  final Color secondaryColor = Color(0xFFE91E63); // Pink
  final Color accentColor = Color(0xFFFFC107); // Amber

  // Font families
  static const String medium = 'Roboto';
  static const String bold = 'Roboto';

  bool isLoading = false;
  int currentPage = 1;
  List<dynamic> catalogOffers = [];
  bool catalogHasMore = true;

  var USER_ID;
  var USER_FULL_NAME;
  var USER_EMAIL;
  var USER_MOBILE_NUMBER;
  var USER_ACCOUNT_TYPE;
  var USER_PARENT_DEALER_CODE;
  var userParentDealerMobile;
  var userParentDealerName;

  @override
  void initState() {
    super.initState();
    fetchLocalStorageData();
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
      // getDashboardDetails();
      getCatalogOffers();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // getCatalogOffers();
  }

  Future<void> getCatalogOffers() async {
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
    var apiUrl = BASE_URL + GET_CATALOG_SEARCH;

    try {
      response = await http.post(
        Uri.parse(apiUrl),
        headers: authProvider.authHeaders,
        body: json.encode({'page': currentPage, 'limit': 100}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('catalog responseData====>${responseData}  ');
        setState(() {
          // Ensure each offer has a valid ID
          var data = responseData['data'] as List;
          catalogOffers = data.map((offer) {
            offer['id'] = offer['_id'];
            return offer;
          }).toList();
          if (catalogOffers.isNotEmpty) {
            catalogHasMore = true;
          } else {
            catalogHasMore = false;
          }
        });
        setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products Catalog',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3533CD),
                    ),
                  ),
                ],
              ),
            ),
            returnCatalogScroll(),
          ],
        ),
      ),
    );
  }

  returnCatalogScroll() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double unitHeightValue = MediaQuery.of(context).size.height;

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: (catalogOffers.length / 2).ceil(),
          itemBuilder: (context, index) {
            int firstIndex = index * 2;
            int secondIndex = firstIndex + 1;
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDetailsBottomSheet(
                        context, catalogOffers[firstIndex],
                        isOffer: true),
                    child: _buildCatalogCard(catalogOffers[firstIndex]),
                  ),
                ),
                Expanded(
                  child: secondIndex < catalogOffers.length
                      ? GestureDetector(
                          onTap: () => _showDetailsBottomSheet(
                              context, catalogOffers[secondIndex],
                              isOffer: true),
                          child: _buildCatalogCard(catalogOffers[secondIndex]),
                        )
                      : SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCatalogCard(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: FadeInImage.assetNetwork(
              placeholder: 'assets/images/app_file_icon.png',
              image: item['productOfferImageUrl'] ?? '',
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/app_file_icon.png',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          SizedBox(height: 8),
          Text(
            item['productOfferDescription'] ?? 'No Description',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Price: ₹${item['productPrice'] ?? '0'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              int quantity = cart.getQuantity(item['id'] ?? '');
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: quantity > 0
                        ? () => cart.decrementQuantity(item['id'] ?? '')
                        : null,
                  ),
                  Text(
                    '$quantity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      if (quantity > 0) {
                        cart.incrementQuantity(item['id'] ?? '');
                      } else {
                        cart.addItem(
                          item['id'] ?? '',
                          item['productOfferDescription'] ?? 'Unknown',
                          item['productPrice'] ?? 0.0,
                          item['productOfferImageUrl'] ?? '',
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context, Map<String, dynamic> data,
      {bool isOffer = true}) {
    final imageUrl =
        isOffer ? data['productOfferImageUrl'] : data['rewardSchemeImageUrl'];
    final description = isOffer
        ? data['productOfferDescription']
        : data['rewardSchemeDescription'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFFFFF7AD),
                Color(0xFFFFA9F9),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: getScreenWidth(16),
                        vertical: getScreenHeight(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.grey[800],
                                size: getScreenWidth(28),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                            minHeight: MediaQuery.of(context).size.height * 0.3,
                          ),
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: getScreenHeight(16)),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(getScreenWidth(12)),
                            child: FadeInImage.assetNetwork(
                              placeholder: 'assets/images/app_file_icon.png',
                              image: imageUrl ?? '',
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.4,
                              fit: BoxFit.contain,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  color: Colors.grey[100],
                                  child: Image.asset(
                                    'assets/images/app_file_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        if (description != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(getScreenWidth(12)),
                            margin:
                                EdgeInsets.only(bottom: getScreenHeight(16)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(getScreenWidth(12)),
                            ),
                            child: Text(
                              description ?? '',
                              style: TextStyle(
                                fontSize: getScreenWidth(16),
                                color: Colors.black87,
                                height: getScreenHeight(1.5),
                                fontFamily: bold,
                              ),
                            ),
                          ),
                        if (isOffer && USER_ACCOUNT_TYPE == 'Dealer')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: getScreenWidth(8),
                              vertical: getScreenHeight(4),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(getScreenWidth(8)),
                            ),
                            child: Text(
                              'Price: ₹${data['productPrice'] ?? '0'}',
                              style: TextStyle(
                                fontSize: getScreenWidth(14),
                                fontFamily: bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        if (isOffer && USER_ACCOUNT_TYPE == 'Dealer')
                          Consumer<CartProvider>(
                            builder: (ctx, cart, child) {
                              int quantity = cart.getQuantity(data['id'] ?? '');
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      if (quantity > 0) {
                                        cart.decrementQuantity(
                                            data['id'] ?? '');
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor: quantity > 0
                                          ? primaryColor.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  SizedBox(width: getScreenWidth(5)),
                                  Text(
                                    '$quantity',
                                    style: TextStyle(
                                      fontSize: getScreenWidth(18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: getScreenWidth(5)),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      if (quantity < CartProvider.maxQuantity) {
                                        if (quantity == 0) {
                                          cart.addItem(
                                            data['id'] ?? '',
                                            data['productOfferDescription'] ??
                                                '',
                                            double.parse(data['productPrice']
                                                    ?.toString() ??
                                                '0'),
                                            data['productOfferImageUrl'] ?? '',
                                          );
                                        } else {
                                          cart.incrementQuantity(
                                              data['id'] ?? '');
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Maximum quantity reached'),
                                          ),
                                        );
                                      }
                                    },
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          quantity < CartProvider.maxQuantity
                                              ? primaryColor.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.1),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
