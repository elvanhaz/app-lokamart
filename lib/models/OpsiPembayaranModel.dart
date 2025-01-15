// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class OpsiPembayaranModel with ChangeNotifier {
  String _selectedOpsiPembayaran = '';

  String get selectedOpsiPembayaran => _selectedOpsiPembayaran;

  void selectOpsiPembayaran(String opsipembayaran) {
    _selectedOpsiPembayaran = opsipembayaran;
    notifyListeners();
  }
}
