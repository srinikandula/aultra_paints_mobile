import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, String name, double price, String imageUrl) {
    if (productId.isEmpty) {
      print('Warning: Attempted to add item with empty ID'); // Debug log
      return;
    }
    print('Adding item with ID: $productId'); // Debug log
    
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: productId,
          name: name,
          price: price,
          imageUrl: imageUrl,
        ),
      );
    }
    print('Cart items after add:'); // Debug log
    _items.forEach((key, item) => print('ID: $key, Quantity: ${item.quantity}')); // Debug log
    notifyListeners();
  }

  void removeItem(String productId) {
    if (productId.isEmpty) {
      print('Warning: Attempted to remove item with empty ID'); // Debug log
      return;
    }
    print('Removing item with ID: $productId'); // Debug log
    
    _items.remove(productId);
    print('Cart items after remove:'); // Debug log
    _items.forEach((key, item) => print('ID: $key, Quantity: ${item.quantity}')); // Debug log
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    if (productId.isEmpty) {
      print('Warning: Attempted to increment quantity with empty ID'); // Debug log
      return;
    }
    print('Incrementing quantity for ID: $productId'); // Debug log
    
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity + 1,
        ),
      );
      print('Cart items after increment:'); // Debug log
      _items.forEach((key, item) => print('ID: $key, Quantity: ${item.quantity}')); // Debug log
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    if (productId.isEmpty) {
      print('Warning: Attempted to decrement quantity with empty ID'); // Debug log
      return;
    }
    print('Decrementing quantity for ID: $productId'); // Debug log
    
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            name: existingCartItem.name,
            price: existingCartItem.price,
            imageUrl: existingCartItem.imageUrl,
            quantity: existingCartItem.quantity - 1,
          ),
        );
      } else {
        _items.remove(productId);
      }
      print('Cart items after decrement:'); // Debug log
      _items.forEach((key, item) => print('ID: $key, Quantity: ${item.quantity}')); // Debug log
      notifyListeners();
    }
  }

  int getQuantity(String productId) {
    if (productId.isEmpty) {
      print('Warning: Attempted to get quantity with empty ID'); // Debug log
      return 0;
    }
    final quantity = _items[productId]?.quantity ?? 0;
    print('Getting quantity for ID: $productId, Value: $quantity'); // Debug log
    return quantity;
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
