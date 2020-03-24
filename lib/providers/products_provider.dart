import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  static const _url =
      'https://flutter-update-48aa1.firebaseio.com/products.json';
  List<Product> _products = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._products];
  }

  List<Product> get favItems {
    return _products.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _products.firstWhere((item) => item.id == id);
  }

  Future<void> upsertProduct(Product update) async {
    try {
      final foundIndex = _products.indexWhere((item) => item.id == update.id);
      if (foundIndex >= 0) {
        final updateUrl =
            'https://flutter-update-48aa1.firebaseio.com/products/${update.id}.json';
        await http.patch(
          updateUrl,
          body: json.encode(
            {
              'title': update.title,
              'description': update.description,
              'imageUrl': update.imageUrl,
              'price': update.price
            },
          ),
        );
        _products[foundIndex] = update;
      } else {
        final response = await http.post(
          _url,
          body: json.encode(
            {
              'title': update.title,
              'description': update.description,
              'imageUrl': update.imageUrl,
              'price': update.price,
              'isFavorite': update.isFavorite,
            },
          ),
        );
        update = update.copyWith(
          id: json.decode(response.body)['name'],
        );
        _products.add(update);
      }
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetProducts() async {
    try {
      final response = await http.get(_url);
      final products = json.decode(response.body) as Map<String, dynamic>;
      if(products == null) return;
      
      _products.clear();
      products.forEach((productId, mapValue) {
        _products.add(Product(
          id: productId,
          title: mapValue['title'],
          description: mapValue['description'],
          price: mapValue['price'],
          imageUrl: mapValue['imageUrl'],
          isFavorite: mapValue['isFavorite'],
        ));
      });
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteProduct(String id) async {
    final updateUrl =
        'https://flutter-update-48aa1.firebaseio.com/products/$id.json';
    final deleteIndex = _products.indexWhere((item) => item.id == id);
    final deleteItem = _products.removeAt(deleteIndex);
    notifyListeners();

    var result = await http.delete(updateUrl);
    if (result.statusCode == 200) {
      print('delete succeded in Cloud!');
    } else {
      print('delete fails with the resonse : ${result.body}');
      _products.insert(deleteIndex, deleteItem);
      notifyListeners();
      throw HttpException('could not delete product!');
    }
  }
}
