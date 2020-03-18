import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context).settings.arguments;
    final title = Provider.of<ProductProvider>(
      context,
      listen: false,
    ).findById(id).title;
    return Scaffold(
        appBar: AppBar(
      title: Text(title),
    ));
  }
}
