// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class PesananModel with ChangeNotifier {
  String _selectedPesanan = '';

  String get selectedPesanan => _selectedPesanan;

  void selectPesanan(String pesanan) {
    _selectedPesanan = pesanan;
    notifyListeners();
  }
}
