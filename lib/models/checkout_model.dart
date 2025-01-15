// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class CheckoutModel with ChangeNotifier {
  String _selectedCheckout = '';

  String get selectedCheckout => _selectedCheckout;

  void selectCheckout(String checkout) {
    _selectedCheckout = checkout;
    notifyListeners();
  }
}
