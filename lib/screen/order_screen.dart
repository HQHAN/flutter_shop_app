import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders_provider.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrder(),
        builder: (ctx, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapShot.error != null) {
              return Center(child: Text(snapShot.error.toString()));
            } else {
              return Consumer<Orders>(
                builder: (BuildContext context, value, Widget child) {
                  return ListView.builder(
                    itemCount: value.orderList.length,
                    itemBuilder: (ctx, i) {
                      return OrderItemWidget(value.orderList[i]);
                    },
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}