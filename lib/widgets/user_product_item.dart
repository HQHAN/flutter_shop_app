import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products_provider.dart';
import 'package:shop/screen/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String imgUrl;
  final String title;

  UserProductItem(this.id, this.imgUrl, this.title);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(imgUrl),
          ),
          title: Text(title),
          trailing: Container(
            width: 100,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Provider.of<ProductProvider>(context, listen: false)
                        .deleteProduct(id);
                  },
                ),
              ],
            ),
          ),
        ),
        Divider(
          color: Colors.black,
        ),
      ],
    );
  }
}
