// providers/cabang_provider.dart
import 'package:loka/models/kategory_model.dart';
import 'package:flutter/material.dart';

class KategoryProvider with ChangeNotifier {
  final KategoryModel _kategoryModel = KategoryModel();

  KategoryModel get kategoryModel => _kategoryModel;

  void selectKategory(String kategory) {
    _kategoryModel.selectKategory(kategory);
    notifyListeners();
  }
}
