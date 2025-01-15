// providers/cabang_provider.dart
import 'package:loka/models/DetailPembayaranStatusModel.dart';
import 'package:flutter/material.dart';

class DetailPembayaranStatusProvider with ChangeNotifier {
  final DetailPembayaranStatusModel _detailpembayaranstatusModel =
      DetailPembayaranStatusModel();

  DetailPembayaranStatusModel get detailpembayaranModel =>
      _detailpembayaranstatusModel;

  void selectDetailPembayaranStatus(String detailpembayaranstatus) {
    _detailpembayaranstatusModel
        .selectDetailPembayaranStatus(detailpembayaranstatus);
    notifyListeners();
  }
}
