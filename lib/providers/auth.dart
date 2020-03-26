import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop/models/http_exception.dart';

class Auth with ChangeNotifier {
  static const SIGN_UP_SEGMENT = 'signUp';
  static const SIGN_IN_SEGMENT = 'signInWithPassword';
  static const AUTH_DATA_PREF_KEY = 'authData';

  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _autoLogoutTimer;

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

  String get userId {
    return _userId;
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
      _scheduleAutoLogout();
      await _saveAuthData();

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, SIGN_IN_SEGMENT);
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _expiryDate = null;
    cancelLogoutTimer();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  void _scheduleAutoLogout() {
    cancelLogoutTimer();
    final duration = _expiryDate.difference(DateTime.now()).inSeconds;
    print('auto logout shall occur after $duration seconds');
    _autoLogoutTimer = Timer(Duration(seconds: duration), logout);
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final authData = json.encode({
      'token': _token,
      'userId': _userId,
      'expiryDate': _expiryDate.toIso8601String(),
    });
    await prefs.setString(AUTH_DATA_PREF_KEY, authData);
  }

  void cancelLogoutTimer() {
    if (_autoLogoutTimer != null) {
      _autoLogoutTimer.cancel();
      _autoLogoutTimer = null;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey(AUTH_DATA_PREF_KEY)) {
      return false;
    }

    final authData = json.decode(prefs.getString(AUTH_DATA_PREF_KEY));
    final expiryDate = DateTime.parse(authData['expiryDate']);
    if(expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = authData['token'];
    _userId = authData['userId'];
    _expiryDate = expiryDate;
    _scheduleAutoLogout();

    notifyListeners();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, SIGN_UP_SEGMENT);
  }
}
