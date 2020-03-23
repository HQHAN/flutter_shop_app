import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/cart.dart';

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orderList {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartItem, double total) {
    _orders.insert(
        0,
        OrderItem(
          id: DateTime.now().toString(),
          amount: total,
          cartItems: cartItem,
          dateTime: DateTime.now(),
        ));
    notifyListeners();
  }
}

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.cartItems,
    @required this.dateTime,
  });
}
