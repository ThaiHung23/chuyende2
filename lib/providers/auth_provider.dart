import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _role;

  String? get role => _role;
  bool get isLoggedIn => _role != null;

  void login(String role) {
    _role = role;
    notifyListeners();
  }

  void logout() {
    _role = null;
    notifyListeners();
  }
}