// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class Searchbar with ChangeNotifier {
  String _selectedSearchbar = '';

  String get selectedsearchbar => _selectedSearchbar;

  void selectSearchbar(String searchbar) {
    _selectedSearchbar = searchbar;
    notifyListeners();
  }
}
