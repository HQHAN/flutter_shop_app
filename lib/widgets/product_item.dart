import 'package:flutter/material.dart';
import 'package:shop/models/product.dart';
import 'package:shop/screen/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  final Product item;

  ProductItem(this.item);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          ProductDetailScreen.routeName,
          arguments: item.id,
        ),
        child: GridTile(
            child: Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              leading: IconButton(
                icon: Icon(
                  Icons.favorite,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {},
              ),
              title: Text(
                item.title,
                textAlign: TextAlign.center,
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Theme.of(context).accentColor,
                ),
                onPressed: () {},
              ),
            )),
      ),
    );
  }
}
