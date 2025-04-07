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
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(cartItems[i].imageUrl),
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      cartItems[i].name,
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    subtitle: Text(
                      'Total: ₹${(cartItems[i].price * cartItems[i].quantity).toStringAsFixed(2)}',
                      style: TextStyle(fontFamily: 'Roboto'),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, size: 20),
                          onPressed: () {
                            cart.decrementQuantity(cartItems[i].id);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Color(0xFF6A1B9A).withOpacity(0.1),
                            padding: EdgeInsets.all(4),
                          ),
                        ),
                        Text(
                          '${cartItems[i].quantity}',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, size: 20),
                          onPressed: () {
                            cart.incrementQuantity(cartItems[i].id);
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Color(0xFF6A1B9A).withOpacity(0.1),
                            padding: EdgeInsets.all(4),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            cart.removeItem(cartItems[i].id);
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
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
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
