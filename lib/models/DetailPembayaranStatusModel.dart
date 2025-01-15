// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class DetailPembayaranStatusModel with ChangeNotifier {
  String _selectedDetailPembayaranStatus = '';

  String get selectedDetailPembayaranStatus => _selectedDetailPembayaranStatus;

  void selectDetailPembayaranStatus(String detailpembayaranstatus) {
    _selectedDetailPembayaranStatus = detailpembayaranstatus;
    notifyListeners();
  }
}
