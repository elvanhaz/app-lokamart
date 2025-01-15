// providers/cabang_provider.dart
import 'package:loka/models/DetailPembayaranModel.dart';
import 'package:flutter/material.dart';

class DetailPembayaranProvider with ChangeNotifier {
  final DetailPembayaranModel _detailpembayaranModel = DetailPembayaranModel();

  DetailPembayaranModel get detailpembayaranModel => _detailpembayaranModel;

  void selectDetailPembayaran(String detailpembayaran) {
    _detailpembayaranModel.selectDetailPembayaran(detailpembayaran);
    notifyListeners();
  }
}
