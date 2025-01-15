// providers/cabang_provider.dart
import 'package:loka/models/checkout_model.dart';
import 'package:flutter/material.dart';

class CheckoutProvider with ChangeNotifier {
  final CheckoutModel _checkoutModel = CheckoutModel();

  CheckoutModel get checkoutModel => _checkoutModel;

  void selectCheckout(String checkout) {
    _checkoutModel.selectCheckout(checkout);
    notifyListeners();
  }
}
