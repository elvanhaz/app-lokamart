// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class DetailPembayaranModel with ChangeNotifier {
  String _selectedDetailPembayaran = '';

  String get selectedDetailPembayaran => _selectedDetailPembayaran;

  void selectDetailPembayaran(String detailpembayaran) {
    _selectedDetailPembayaran = detailpembayaran;
    notifyListeners();
  }
}
