import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';
import '../../utility/size_config.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  // Colors for gradient backgrounds
  static const Color primaryColor = Color(0xFF6A1B9A);
  static const Color secondaryColor = Color(0xFF9C27B0);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();
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
                padding: EdgeInsets.symmetric(vertical: 10),
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
                          fontSize: 18,
                          fontFamily: 'Roboto',
                          color: Colors.black87,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(top: 10),
                      itemCount: cartItems.length,
                      itemBuilder: (ctx, i) => Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
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
                                Colors.white,
                                Color(0xFFFFF7AD).withOpacity(0.2),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // Product image
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(cartItems[i].imageUrl),
                                  backgroundColor: Colors.transparent,
                                ),
                                SizedBox(width: 12),
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
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
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
                                      icon: Icon(Icons.remove, size: 20),
                                      onPressed: cartItems[i].quantity > 1
                                          ? () => cart.decrementQuantity(
                                              cartItems[i].id)
                                          : null,
                                      style: IconButton.styleFrom(
                                        backgroundColor:
                                            cartItems[i].quantity > 1
                                                ? primaryColor.withOpacity(0.1)
                                                : Colors.grey.withOpacity(0.1),
                                        padding: EdgeInsets.all(4),
                                      ),
                                    ),
                                    Container(
                                      width: 30,
                                      child: Text(
                                        '${cartItems[i].quantity}',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add, size: 20),
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
                                        padding: EdgeInsets.all(4),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, size: 20),
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
                                        padding: EdgeInsets.all(4),
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
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
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
              padding: EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: screenWidth * 0.8,
                    child: ElevatedButton(
                      child: Text(
                        'PROCEED TO CHECKOUT',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        // Implement checkout functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Checkout functionality coming soon!'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
