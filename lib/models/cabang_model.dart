// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class CabangModel with ChangeNotifier {
  String _selectedCabang = '';

  String get selectedCabang => _selectedCabang;

  void selectCabang(String cabang) {
    _selectedCabang = cabang;
    notifyListeners();
  }
}
