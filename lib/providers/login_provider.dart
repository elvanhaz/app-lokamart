// providers/cabang_provider.dart
import 'package:loka/models/login_model.dart';
import 'package:flutter/material.dart';

class LoginProvider with ChangeNotifier {
  final LoginModel _loginModel = LoginModel();

  LoginModel get loginModel => _loginModel;

  void selectlogin(String login) {
    _loginModel.selectLogin(login);
    notifyListeners();
  }
}
