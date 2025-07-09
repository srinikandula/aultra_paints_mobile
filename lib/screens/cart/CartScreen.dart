import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/config.dart';
import '../../services/error_handling.dart';
import '../../utility/Colors.dart';
import '../../utility/Utils.dart';
import '../../utility/size_config.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatelessWidget {
  CartScreen({Key? key}) : super(key: key);

  // Colors for gradient backgrounds
  static const Color primaryColor = Color(0xFF6A1B9A);
  static const Color secondaryColor = Color(0xFF9C27B0);

  bool isLoading = false;

  void _showSnackBar(String message, BuildContext context, ColorCheck) {
    final snackBar = SnackBar(
        content: Text(message),
        backgroundColor: ColorCheck ? Colors.green : Colors.red,
        duration: Utils.returnStatusToastDuration(ColorCheck));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> createCheckout(
      BuildContext context, List<CartItem> cartItems) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return;
    }

    Utils.clearToasts(context);
    Utils.returnScreenLoader(context);

    http.Response response;
    var apiUrl = BASE_URL + CREATE_CHECKOUT;

    List<Map<String, dynamic>> itemsJson = cartItems.map((item) {
      var volume;
      var actualId;
      if (item.id.contains('_')) {
        actualId = item.id.split('_')[0];
        volume = item.id.split('_')[1];
      } else {
        actualId = item.id;
        volume = "0";
      }
      return {
        "_id": actualId,
        "productOfferDescription": item.name,
        "quantity": item.quantity,
        "productPrice": item.price,
        "productOfferImageUrl": item.imageUrl,
        "volume": volume,
      };
    }).toList();

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      response = await http.post(
        Uri.parse(apiUrl),
        headers: authProvider.authHeaders,
        body: json.encode(
            {'items': itemsJson, 'totalPrice': cartProvider.totalAmount}),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          Provider.of<CartProvider>(context, listen: false).clear();

          _showSuccessDialog(context);
        }
      } else {
        error_handling.errorValidation(
            context, response.statusCode, response.body, false);
      }
    } catch (e) {
      Navigator.of(context).pop();
      error_handling.errorValidation(
          context, 500, 'An error occurred while creating checkout', false);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushReplacementNamed('/dashboardPage');
        });
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: AnimationController(
              vsync: Navigator.of(ctx),
              duration: Duration(milliseconds: 500),
            )..forward(),
            curve: Curves.elasticOut,
          ),
          child: AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.zero,
            backgroundColor: Colors.white,
            content: Container(
              padding: EdgeInsets.all(getScreenWidth(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: getScreenWidth(100),
                    width: getScreenWidth(100),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10.0,
                          ),
                        ],
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF6A1B9A),
                              Color(0xFFAB47BC),
                            ])),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: getScreenWidth(80),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: getScreenWidth(20),
                  ),
                  Text(
                    'Order Placed',
                    style: TextStyle(
                        fontSize: getScreenWidth(20),
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: getScreenWidth(10),
                  ),
                  Text(
                    'Your order has been placed successfully.',
                    style: TextStyle(
                      fontSize: getScreenWidth(18),
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
    // print('cartItems====>${cartItems}');
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
          children: [
            // Header
            SafeArea(
              child: Container(
                width: screenWidth,
                padding: EdgeInsets.symmetric(vertical: getScreenWidth(10)),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: getScreenWidth(20),
                        ),
                        child: Icon(
                          Icons.keyboard_double_arrow_left_sharp,
                          color: const Color(0xFF7A0180),
                          size: getScreenWidth(30),
                        ),
                      ),
                    ),
                    Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: getScreenWidth(18),
                        color: const Color(0xFF7A0180),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: cart.items.isEmpty
                  ? Center(
                      child: Text(
                        'Your cart is empty',
                        style: TextStyle(
                          fontSize: getScreenWidth(18),
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: getScreenWidth(10)),
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, i) => Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: getScreenWidth(15),
                          vertical: getScreenWidth(4),
                        ),
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
                                Colors.white,
                                Color(0xFFFFF7AD).withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: getScreenWidth(8),
                                horizontal: getScreenWidth(2)),
                            child: Row(
                              children: [
                                // Product image
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(cartItems[i].imageUrl),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    if (cartItems[i].id.contains('_')) ...[
                                      SizedBox(height: getScreenWidth(2)),
                                      Text(
                                        cartItems[i]
                                            .id
                                            .split('_')
                                            .sublist(1)
                                            .join('_'),
                                        style: TextStyle(
                                          fontSize: getScreenWidth(12),
                                          color: Colors.blueGrey,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(width: getScreenWidth(12)),
                                // Product details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItems[i].name,
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: getScreenWidth(16),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: getScreenWidth(4)),
                                      Text(
                                        'Total: ₹${(cartItems[i].price * cartItems[i].quantity).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity controls
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove,
                                          size: getScreenWidth(20)),
                                      onPressed: cartItems[i].quantity > 1
                                          ? () => cart.decrementQuantity(
                                              cartItems[i].id)
                                          : null,
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            cartItems[i].quantity > 1
                                                ? primaryColor.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getScreenWidth(4),
                                            vertical: getScreenWidth(4)),
                                      ),
                                    ),
                                    SizedBox(
                                      width: getScreenWidth(30),
                                      child: Text(
                                        '${cartItems[i].quantity}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: getScreenWidth(16),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add,
                                          size: getScreenWidth(20)),
                                      onPressed: cartItems[i].quantity <
                                              CartProvider.maxQuantity
                                          ? () => cart.incrementQuantity(
                                              cartItems[i].id)
                                          : () {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Maximum quantity reached'),
                                                  duration:
                                                      Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                      style: IconButton.styleFrom(
                                        backgroundColor: cartItems[i].quantity <
                                                CartProvider.maxQuantity
                                            ? primaryColor.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getScreenWidth(4),
                                            vertical: getScreenWidth(4)),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          size: getScreenWidth(20)),
                                      onPressed: () {
                                        cart.removeItem(cartItems[i].id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Item removed from cart'),
                                            duration: Duration(seconds: 1),
                                            action: SnackBarAction(
                                              label: 'UNDO',
                                              onPressed: () {
                                                cart.addItem(
                                                  cartItems[i].id,
                                                  cartItems[i].name,
                                                  cartItems[i].price,
                                                  cartItems[i].imageUrl,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            Colors.red.withOpacity(0.1),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: getScreenWidth(4),
                                            vertical: getScreenWidth(4)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Color(0xFFFFF7AD).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(getScreenWidth(16)),
                  topRight: Radius.circular(getScreenWidth(16)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: getScreenWidth(15), vertical: getScreenWidth(15)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: getScreenWidth(20),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: getScreenWidth(20),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: getScreenWidth(15)),
                  Container(
                    width: screenWidth * 0.8,
                    child: ElevatedButton(
                      child: Text(
                        'PROCEED TO CHECKOUT',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: getScreenWidth(16),
                          color: colorC8C7C7,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: getScreenWidth(30),
                            vertical: getScreenWidth(15)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(getScreenWidth(30)),
                        ),
                      ),
                      onPressed: () {
                        if (cart.items.isEmpty) {
                          _showSnackBar('Cart is empty', context, false);
                        } else {
                          createCheckout(context, cartItems);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
