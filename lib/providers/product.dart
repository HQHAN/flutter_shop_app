import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  @override
  String toString() {
    return 'id: $id\n title: $title\n description: $description\n price:$price\n imageUrl:$imageUrl\n isFavorite:$isFavorite';
  }

  Product copyWith(
      {String id,
      String title,
      String description,
      double price,
      String imageUrl,
      bool isFavorite}) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Future<void> toggelFavorite(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        'https://flutter-update-48aa1.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _setFavoriteStatus(oldStatus);
      }
    } catch (exception) {
      _setFavoriteStatus(oldStatus);
      throw HttpException('favorite toggle failed!');
    }
  }

  void _setFavoriteStatus(bool oldStatus) {
    isFavorite = oldStatus;
    notifyListeners();
  }
}
