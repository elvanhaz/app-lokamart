// providers/cabang_provider.dart
import 'package:loka/models/PesananModel.dart';
import 'package:flutter/material.dart';

class PesananProvider with ChangeNotifier {
  final PesananModel _pesananModel = PesananModel();

  PesananModel get pesananModel => _pesananModel;

  void selectPesanan(String pesanan) {
    _pesananModel.selectPesanan(pesanan);
    notifyListeners();
  }
}
