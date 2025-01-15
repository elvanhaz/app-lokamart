// providers/cabang_provider.dart
import 'package:loka/models/OpsiPembayaranModel.dart';
import 'package:flutter/material.dart';

class OpsiPembayaranProvider with ChangeNotifier {
  final OpsiPembayaranModel _opsipembayaranModel = OpsiPembayaranModel();

  OpsiPembayaranModel get opsipembayaranModel => _opsipembayaranModel;

  void selectlogin(String opsipembayaran) {
    _opsipembayaranModel.selectOpsiPembayaran(opsipembayaran);
    notifyListeners();
  }
}
