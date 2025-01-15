// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class StatusPesananModel with ChangeNotifier {
  String _selectedStatusPesanan = '';

  String get selectedStatusPesanan => _selectedStatusPesanan;

  void selectStatusPesanan(String statuspesanan) {
    _selectedStatusPesanan = statuspesanan;
    notifyListeners();
  }
}
