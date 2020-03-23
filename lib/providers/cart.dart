import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get cartItems {
    return {..._items};
  }

  double get totalPrice {
    double totalPrice = 0.0;
    _items.forEach((key, item) {
      totalPrice += item.price * item.quantity;
    });
    return totalPrice;
  }

  void addItem(String productId, String title, double price) {
    _items.update(
      productId,
      (existing) => CartItem(
          id: existing.id,
          title: existing.title,
          price: existing.price,
          quantity: existing.quantity + 1),
      ifAbsent: () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1),
    );
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }

    if (_items[productId].quantity > 1) {
      _items.update(productId, (item) {
        return CartItem(
            id: item.id,
            title: item.title,
            price: item.price,
            quantity: item.quantity - 1);
      });
    } else {
      _items.remove(productId);
    }

    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
