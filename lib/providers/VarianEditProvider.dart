// providers/cabang_provider.dart
import 'package:loka/models/VarianEditModel.dart';
import 'package:flutter/material.dart';

class Varianprovider with ChangeNotifier {
  final VarianEditModel _varianeditModel = VarianEditModel();

  VarianEditModel get varianeditModel => _varianeditModel;

  void selectVarianEdit(String varianedit) {
    _varianeditModel.selectVarianEdit(varianedit);
    notifyListeners();
  }
}
