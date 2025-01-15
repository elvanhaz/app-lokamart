// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class VerifikasiModel with ChangeNotifier {
  String _selectedverifikasi = '';

  String get selectedVerifikasi => _selectedverifikasi;

  void selectVerifikasi(String verifikasi) {
    _selectedverifikasi = verifikasi;
    notifyListeners();
  }
}
