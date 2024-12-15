import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _email;
  bool _isLoggedIn = false;

  String? get userId => _userId;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;

  void setUser(String userId, String email) {
    _userId = userId;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _email = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
