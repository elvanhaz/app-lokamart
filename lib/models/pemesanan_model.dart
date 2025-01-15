// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class PemesananModel with ChangeNotifier {
  String _selectedPemesanan = '';

  String get selectedPemesanan => _selectedPemesanan;

  void selectPemesanan(String pemesanan) {
    _selectedPemesanan = pemesanan;
    notifyListeners();
  }
}
