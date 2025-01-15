// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class VarianModel with ChangeNotifier {
  String _selectedVarian = '';

  String get selectedvarian => _selectedVarian;

  void selectVarian(String varian) {
    _selectedVarian = varian;
    notifyListeners();
  }

  void selectModel(String varian) {}
}
