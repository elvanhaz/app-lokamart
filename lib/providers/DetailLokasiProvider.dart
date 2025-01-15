// providers/cabang_provider.dart
import 'package:loka/models/DetailLokasiModel.dart';
import 'package:flutter/material.dart';

class DetailLokasiprovider with ChangeNotifier {
  final DetailLokasiModel _detaillokasiModel = DetailLokasiModel();

  DetailLokasiModel get detaillokasiModel => _detaillokasiModel;

  void selectDetailLokasi(String detaillokasi) {
    _detaillokasiModel.selectDetailLokasi(detaillokasi);
    notifyListeners();
  }
}
