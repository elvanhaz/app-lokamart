// providers/cabang_provider.dart
import 'package:loka/models/CheckoutEditModel.dart';
import 'package:flutter/material.dart';

class CheckoutEditProvider with ChangeNotifier {
  final CheckoutEditModel _checkouteditModel = CheckoutEditModel();

  CheckoutEditModel get checkouteditModel => _checkouteditModel;

  void selectCheckout(String checkoutedit) {
    _checkouteditModel.selectCheckoutEdit(checkoutedit);
    notifyListeners();
  }
}
