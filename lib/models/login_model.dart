// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class LoginModel with ChangeNotifier {
  String _selectedLogin = '';

  String get selectedLogin => _selectedLogin;

  void selectLogin(String login) {
    _selectedLogin = login;
    notifyListeners();
  }

}