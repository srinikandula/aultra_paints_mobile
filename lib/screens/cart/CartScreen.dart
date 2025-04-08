import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../utility/Colors.dart';
import '../../utility/Fonts.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF6A1B9A),
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Roboto',
                ),
              ),
            )
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (ctx, i) => Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      // Product image
                      CircleAvatar(
                        backgroundImage: NetworkImage(cartItems[i].imageUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      SizedBox(width: 12),
                      // Product details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                ? () => cart.decrementQuantity(cartItems[i].id)
                                : null,
                            style: IconButton.styleFrom(
                              backgroundColor: cartItems[i].quantity > 1
                                  ? Color(0xFF6A1B9A).withOpacity(0.1)
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
                                ? () => cart.incrementQuantity(cartItems[i].id)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Maximum quantity reached'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                            style: IconButton.styleFrom(
                              backgroundColor: cartItems[i].quantity <
                                      CartProvider.maxQuantity
                                  ? Color(0xFF6A1B9A).withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              padding: EdgeInsets.all(4),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, size: 20),
                            onPressed: () {
                              cart.removeItem(cartItems[i].id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Item removed from cart'),
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
                              backgroundColor: Colors.red.withOpacity(0.1),
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
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
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
                        ),
                      ),
                      Text(
                        '₹${cart.totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    child: Text(
                      'PROCEED TO CHECKOUT',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6A1B9A),
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
                          content: Text('Checkout functionality coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
