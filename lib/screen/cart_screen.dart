import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders_provider.dart';
import 'package:shop/widgets/cart_item.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<Cart>(context);
    return Scaffold(
        appBar: AppBar(title: Text('Your Cart')),
        body: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Total',
                      style: TextStyle(fontSize: 20),
                    ),
                    Spacer(),
                    Chip(
                      label: Text(
                        '\$${cartProvider.totalPrice}',
                        style: TextStyle(
                          color: Theme.of(context).primaryTextTheme.title.color,
                        ),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    OrderButton(cartProvider),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (_, index) {
                  var item = cartProvider.cartItems.values.toList()[index];
                  var key = cartProvider.cartItems.keys.toList()[index];
                  return CartItemWidget(
                    item.id,
                    item.title,
                    item.price,
                    item.quantity,
                    key,
                  );
                },
                itemCount: cartProvider.cartItems.length,
              ),
            ),
          ],
        ));
  }
}

class OrderButton extends StatefulWidget {
  final Cart cart;
  OrderButton(this.cart);
  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isOrderInProgress = false;

  @override
  Widget build(BuildContext context) {
    return _isOrderInProgress
        ? CircularProgressIndicator()
        : FlatButton(
            onPressed: widget.cart.cartItems.length == 0
                ? null
                : () async {
                    setState(() {
                      _isOrderInProgress = true;
                    });
                    try {
                      await Provider.of<Orders>(context, listen: false)
                          .addOrder(
                        widget.cart.cartItems.values.toList(),
                        widget.cart.totalPrice,
                      );
                      widget.cart.clear();
                    } catch (error) {
                      print(error.toString());
                    } finally {
                      setState(() {
                        _isOrderInProgress = false;
                      });
                    }
                  },
            child: Text('Order now'),
            textColor: Theme.of(context).primaryColor,
          );
  }
}
