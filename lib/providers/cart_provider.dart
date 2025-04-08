import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    try {
      return CartItem(
        id: json['id'] as String,
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : json['price'] as double,
        imageUrl: json['imageUrl'] as String,
      );
    } catch (e) {
      print('Error creating CartItem from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}

class CartProvider with ChangeNotifier {
  static const int maxQuantity = 99;
  String? _userId;
  Map<String, CartItem> _items = {};

  CartProvider() {
    // Don't load cart in constructor - wait for setUserId
  }

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> setUserId(String? userId) async {
    print('Setting cart user ID: $userId (previous: $_userId)');

    try {
      if (_userId != userId) {
        // Save current cart data before switching user
        if (_userId != null && _items.isNotEmpty) {
          print(
              'Saving cart for previous user: $_userId with ${_items.length} items');
          await saveCart();
          print('Previous cart saved successfully');
        }

        // Clear items and set new user ID
        _items = {};
        _userId = userId;

        // Load new user's cart data
        if (userId != null) {
          print('Loading cart for new user: $userId');
          await _loadCartFromPrefs();
          print('Cart loaded successfully with ${_items.length} items');
        }

        notifyListeners();
      } else {
        print('User ID unchanged, skipping cart reload');
      }
    } catch (e) {
      print('Error in setUserId: $e');
      _items = {};
      notifyListeners();
    }
  }

  Future<void> _loadCartFromPrefs() async {
    if (_userId == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'cart_${_userId}';
      final cartData = prefs.getString(cartKey);
      print('Loading cart from key: $cartKey, data: $cartData');

      _items = {}; // Clear existing items before loading

      if (cartData != null && cartData.isNotEmpty) {
        try {
          final decodedData = json.decode(cartData) as Map<String, dynamic>;
          print('Decoded cart data: $decodedData');

          decodedData.forEach((key, value) {
            try {
              final cartItem = CartItem.fromJson(value as Map<String, dynamic>);
              _items[key] = cartItem;
              print('Loaded item: $key with quantity: ${cartItem.quantity}');
            } catch (e) {
              print('Error loading cart item $key: $e');
            }
          });
          print('Successfully loaded ${_items.length} items');
        } catch (e) {
          print('Error decoding cart data: $e');
        }
      } else {
        print('No saved cart found for key: $cartKey');
      }
    } catch (e) {
      print('Error loading cart data: $e');
      _items = {};
    }
  }

  Future<void> saveCart() async {
    if (_userId == null) {
      print('Cannot save cart: no user ID set');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cartKey = 'cart_${_userId}';

      if (_items.isEmpty) {
        print('Cart is empty, removing saved data for user: $_userId');
        await prefs.remove(cartKey);
        return;
      }

      final cartData = <String, dynamic>{};
      _items.forEach((key, value) {
        try {
          cartData[key] = value.toJson();
        } catch (e) {
          print('Error converting item $key to JSON: $e');
        }
      });

      final encodedData = json.encode(cartData);
      print('Saving cart data: $encodedData');
      await prefs.setString(cartKey, encodedData);

      // Verify the save
      final savedData = prefs.getString(cartKey);
      if (savedData == encodedData) {
        print('Cart data verified and saved successfully');
      } else {
        print('Warning: Saved cart data verification failed');
      }
    } catch (e) {
      print('Error saving cart data: $e');
    }
  }

  void addItem(String productId, String name, double price, String imageUrl) {
    print('Adding item to cart - ID: $productId, User: $_userId');

    if (productId.isEmpty || _userId == null) {
      print('Cannot add item: productId is empty or no user is set');
      return;
    }

    if (_items.containsKey(productId)) {
      print('Item exists in cart, updating quantity');
      // Change quantity
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      print('Adding new item to cart');
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          quantity: 1,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }

    saveCart();
    notifyListeners();
    print('Added/Updated item in cart. Total items: ${_items.length}');
  }

  void removeItem(String productId) {
    print('Removing item from cart - ID: $productId, User: $_userId');

    if (productId.isEmpty || _userId == null) {
      print('Cannot remove item: productId is empty or no user is set');
      return;
    }

    _items.remove(productId);
    saveCart();
    notifyListeners();
    print('Removed item from cart. Total items: ${_items.length}');
  }

  void incrementQuantity(String productId) {
    print('Incrementing quantity - ID: $productId, User: $_userId');
    print('Current cart state before increment: ${_items.toString()}');

    if (productId.isEmpty || _userId == null) {
      print('Cannot increment: productId is empty or no user is set');
      return;
    }

    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < maxQuantity) {
        print('Current quantity before increment: ${item.quantity}');
        
        // Create new cart item with incremented quantity
        final updatedItem = CartItem(
          id: item.id,
          name: item.name,
          quantity: item.quantity + 1,
          price: item.price,
          imageUrl: item.imageUrl,
        );
        
        // Update the items map
        _items[productId] = updatedItem;
        
        print('New quantity after increment: ${updatedItem.quantity}');
        
        // Notify listeners first to update UI immediately
        notifyListeners();
        // Then save to storage
        saveCart();
      } else {
        print('Cannot increment: maximum quantity reached');
      }
    } else {
      print('Product ID not found in cart');
    }
  }

  void decrementQuantity(String productId) {
    print('Decrementing quantity - ID: $productId, User: $_userId');

    if (productId.isEmpty || _userId == null) {
      print('Cannot decrement: productId is empty or no user is set');
      return;
    }

    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            name: existingCartItem.name,
            quantity: existingCartItem.quantity - 1,
            price: existingCartItem.price,
            imageUrl: existingCartItem.imageUrl,
          ),
        );
      } else {
        _items.remove(productId);
      }
      saveCart();
      notifyListeners();
      print(
          'Decremented quantity. New quantity: ${_items[productId]?.quantity}');
    }
  }

  int getQuantity(String productId) {
    if (productId.isEmpty) return 0;
    return _items[productId]?.quantity ?? 0;
  }

  void clear() {
    _items = {};
    saveCart();
    notifyListeners();
    print('Cleared cart');
  }
}
