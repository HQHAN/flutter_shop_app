import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  static const SIGN_UP_SEGMENT = 'signUp';
  static const SIGN_IN_SEGMENT = 'signInWithPassword';

  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final _authenticateUrl =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyD8MfKcGUMg7D5f3igQG1AvotvkI-KYauU';
    try {
      final response = await http.post(_authenticateUrl,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final jsonRes = json.decode(response.body);
      print(jsonRes);
      if (jsonRes['error'] != null && jsonRes['error']['code'] != 200) {
        throw HttpException(jsonRes['error']['message']);
      }
      _token = jsonRes['idToken'];
      _userId = jsonRes['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(jsonRes['expiresIn']),
        ),
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, SIGN_IN_SEGMENT);
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, SIGN_UP_SEGMENT);
  }
}
