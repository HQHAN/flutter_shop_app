import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders_provider.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-page';

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: orders.orderList.length,
        itemBuilder: (ctx, i) {
          return OrderItemWidget(orders.orderList[i]);
        },
      ),
    );
  }
}
