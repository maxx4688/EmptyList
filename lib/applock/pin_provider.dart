import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomLockProvider extends ChangeNotifier {
  bool _isLocked = false;
  String? _code;

  bool get isLocked => _isLocked;
  String? get code => _code;

  CustomLockProvider() {
    _loadPin();
  }

  Future<void> _loadPin() async {
    try {
      final saved = await SharedPreferences.getInstance();
      _isLocked = saved.getBool('isLocked') ?? false;
      _code = saved.getString('code');
    } catch (e) {
      _isLocked = false;
      _code = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> enableLock(String newCode) async {
    if (newCode.length != 4 || int.tryParse(newCode) == null) {
      throw ArgumentError("The code must be a valid 4-digit PIN.");
    } else {
    final saved = await SharedPreferences.getInstance();
    await saved.setString('code', newCode);
    await saved.setBool('isLocked', true);
    _code = newCode;
    _isLocked = true;
    }
    notifyListeners();
  }

  Future<void> disableLock() async {
    final saved = await SharedPreferences.getInstance();
    await saved.remove('code');
    await saved.setBool('isLocked', false);
    _code = null;
    _isLocked = false;
    notifyListeners();
  }
}