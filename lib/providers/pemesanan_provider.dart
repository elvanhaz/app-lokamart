// providers/cabang_provider.dart
import 'package:loka/models/pemesanan_model.dart';
import 'package:flutter/material.dart';

class PemesananProvider with ChangeNotifier {
  final PemesananModel _pemesananModel = PemesananModel();

  PemesananModel get pemesananModel => _pemesananModel;

  void selectPemesanan(String pemesanan) {
    _pemesananModel.selectPemesanan(pemesanan);
    notifyListeners();
  }
}
