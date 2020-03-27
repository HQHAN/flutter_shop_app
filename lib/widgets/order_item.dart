import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders_provider.dart';

class OrderItemWidget extends StatefulWidget {
  final OrderItem item;

  OrderItemWidget(this.item);

  @override
  _OrderItemWidgetState createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  var _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    List<CartItem> cartItems = widget.item.cartItems;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded ? min(cartItems.length * 20.0 + 120, 200) : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('\$${widget.item.amount}'),
              subtitle: Text(
                DateFormat('dd MM yyyy hh:mm').format(widget.item.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: _isExpanded ? min(cartItems.length * 20.0 + 20, 100) : 0,
              child: Container(
                  padding: EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (_, i) {
                      final item = cartItems[i];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item.quantity} x ${item.price}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
