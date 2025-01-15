// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class CheckoutEditModel with ChangeNotifier {
  String _selectedCheckoutEdit = '';

  String get selectedCheckoutEdit => _selectedCheckoutEdit;

  void selectCheckoutEdit(String checkoutedit) {
    _selectedCheckoutEdit = checkoutedit;
    notifyListeners();
  }
}
