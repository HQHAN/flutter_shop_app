import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/products_provider.dart';
import 'package:shop/screen/cart_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/badge.dart';
import 'package:shop/widgets/product_item.dart';

enum FilterOptions { FavoritesOnly, All }

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  bool _isFavoriteShowOnly = false;
  bool _isLoading = false;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });

    Provider.of<ProductProvider>(context, listen: false)
        .fetchAndSetProducts()
        .then((_) {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOptions option) {
              setState(() {
                switch (option) {
                  case FilterOptions.FavoritesOnly:
                    _isFavoriteShowOnly = true;
                    break;
                  case FilterOptions.All:
                    _isFavoriteShowOnly = false;
                    break;
                }
              });
            },
            icon: Icon(
              Icons.more_vert,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                  child: Text('Only Favorite'),
                  value: FilterOptions.FavoritesOnly),
              PopupMenuItem(child: Text('Show All'), value: FilterOptions.All),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, children) {
              print(cart.cartItems.toString());
              return Badge(
                child: children,
                value: cart.cartItems.length.toString(),
              );
            },
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        color: Colors.amber,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ProductGrid(_isFavoriteShowOnly),
      ),
    );
  }
}

class ProductGrid extends StatelessWidget {
  final bool isFavoriteOnly;

  ProductGrid(this.isFavoriteOnly);

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context);
    final items = isFavoriteOnly ? products.favItems : products.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: items[index],
        child: ProductItem(),
      ),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
