import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products_provider.dart';
import 'package:shop/screen/edit_product_screen.dart';
import 'package:shop/widgets/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const String routeName = '/user-product-list';

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<ProductProvider>(ctx, listen: false)
        .fetchAndSetProducts(filterByUser: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your products'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<ProductProvider>(
                      builder: (ctx, products, _) => ListView.builder(
                        itemCount: products.items.length,
                        itemBuilder: (_, i) {
                          return UserProductItem(
                            products.items[i].id,
                            products.items[i].imageUrl,
                            products.items[i].title,
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
