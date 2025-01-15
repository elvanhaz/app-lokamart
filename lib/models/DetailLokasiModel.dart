// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class DetailLokasiModel with ChangeNotifier {
  String _selectedDetailLokasi = '';

  String get selectedDetailLokasi => _selectedDetailLokasi;

  void selectDetailLokasi(String detaillokasi) {
    _selectedDetailLokasi = detaillokasi;
    notifyListeners();
  }
}
