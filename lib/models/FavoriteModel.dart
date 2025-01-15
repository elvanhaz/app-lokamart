// models/cabang_model.dart
import 'package:flutter/foundation.dart';

class FavoriteModel with ChangeNotifier {
  String _selectedFavorite = '';

  String get selectedFavorite => _selectedFavorite;

  void selectFavorite(String favorite) {
    _selectedFavorite = favorite;
    notifyListeners();
  }
}
