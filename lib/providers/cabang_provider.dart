// providers/cabang_provider.dart
import 'package:loka/models/cabang_model.dart';
import 'package:flutter/material.dart';

class CabangProvider with ChangeNotifier {
  final CabangModel _cabangModel = CabangModel();

  CabangModel get cabangModel => _cabangModel;

  void selectCabang(String cabang) {
    _cabangModel.selectCabang(cabang);
    notifyListeners();
  }
}
