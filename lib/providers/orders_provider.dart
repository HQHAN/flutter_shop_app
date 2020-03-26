import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  final _url = 'https://flutter-update-48aa1.firebaseio.com/orders';
  List<OrderItem> _orders = [];

  get orderUrl => _url + '/$_userId.json?auth=$_authToken';

  String _authToken;
  set authToken(String token) {
    if(_authToken != token) {
      _authToken = token;
    }
  }

  String _userId;
  set userId(String userId) {
    _userId = userId;
  }

  List<OrderItem> get orderList {
    return [..._orders];
  }

  Future<List<OrderItem>> fetchAndSetOrder() async {
    try {
      final response = await http.get(orderUrl);
      print(json.decode(response.body));
      final fetched = json.decode(response.body) as Map<String, dynamic>;
      if(fetched == null) return null;

      _orders.clear();
      fetched.forEach((id, orderData) {
        _orders.add(OrderItem(
          id: id,
          amount: orderData['amount'],
          cartItems: (orderData['cartItems'] as List<dynamic>).map(
            (item) {
              return CartItem(
                  id: item['id'],
                  title: item['title'],
                  price: item['price'],
                  quantity: item['quantity']);
            },
          ).toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ));
      });
      _orders = _orders.reversed.toList();
      notifyListeners();
      return _orders;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addOrder(List<CartItem> cartItem, double total) async {
    final now = DateTime.now();
    print('add order : $orderUrl');
    try {
      
      final response = await http.post(orderUrl,
          body: json.encode({
            'amount': total,
            'cartItems': cartItem
                .map((cart) => {
                      'id': cart.id,
                      'title': cart.title,
                      'price': cart.price,
                      'quantity': cart.quantity,
                    })
                .toList(),
            'dateTime': now.toIso8601String(),
          }));

      final orderId = json.decode(response.body)['name'];
      final addItem = OrderItem(
        id: orderId,
        amount: total,
        cartItems: cartItem,
        dateTime: now,
      );
      _orders.insert(0, addItem);
      notifyListeners();
    } catch (error) {
      print(error);
      throw HttpException('Add order fails');
    }
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
