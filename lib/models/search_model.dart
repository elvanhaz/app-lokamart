// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class SearchModel with ChangeNotifier {
  String _selectedSearch  = '';

  String get selectedSearch => _selectedSearch;

  void selectSearch(String search) {
    _selectedSearch = search;
    notifyListeners();
  }
}
