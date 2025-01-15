// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class VarianEditModel with ChangeNotifier {
  String _selectedVarianEdit = '';

  String get selectedvarianedit => _selectedVarianEdit;

  void selectVarianEdit(String varianedit) {
    _selectedVarianEdit = varianedit;
    notifyListeners();
  }

  void selectModel(String varianedit) {}
}
