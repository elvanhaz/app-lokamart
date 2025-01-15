// providers/cabang_provider.dart
import 'package:loka/models/VarianModel.dart';
import 'package:flutter/material.dart';

class Varianprovider with ChangeNotifier {
  final VarianModel _varianModel = VarianModel();

  VarianModel get varianModel => _varianModel;

  void selectVarian(String varian) {
    _varianModel.selectVarian(varian);
    notifyListeners();
  }
}
