// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class KategoryModel with ChangeNotifier {
  String _selectedKategory = '';

  String get selectedKategory => _selectedKategory;

  void selectKategory(String kategory) {
    _selectedKategory = kategory;
    notifyListeners();
  }
}
