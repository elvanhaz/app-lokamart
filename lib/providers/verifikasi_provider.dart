// providers/cabang_provider.dart
import 'package:loka/models/verifikasi_model.dart';
import 'package:flutter/material.dart';

class VerifikasiProvider with ChangeNotifier {
  final VerifikasiModel _verifikasiModel = VerifikasiModel();

  VerifikasiModel get verifikasiModel => _verifikasiModel;

  void selectverifikasi(String verifikasi) {
    _verifikasiModel.selectVerifikasi(verifikasi);
    notifyListeners();
  }
}
