import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _fullName;

  String get fullName => _fullName ?? '';

  String get firstName {
    if (_fullName == null || _fullName!.isEmpty) return '';
    return _fullName!.split(' ')[0]; 
  }

  void setFullName(String name) {
    _fullName = name;
    notifyListeners(); 
  }

  void clearUser() {
    _fullName = null;
    notifyListeners();
  }
}