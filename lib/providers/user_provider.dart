import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _fullName;
  String? _role;

  String get fullName => _fullName ?? '';

  String get firstName {
    if (_fullName == null || _fullName!.isEmpty) return '';
    return _fullName!.split(' ')[0]; 
  }

  void setFullName(String name) {
    _fullName = name;
    notifyListeners(); 
  }

  String get role => _role ?? '';

  bool get isAdmin {
    final r = role.toLowerCase();
    return r.contains('admin') || r.contains('administrador');
  }

  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  void clearUser() {
    _fullName = null;
    _role = null;
    notifyListeners();
  }
}