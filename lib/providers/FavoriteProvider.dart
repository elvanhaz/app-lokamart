// providers/cabang_provider.dart
import 'package:loka/models/FavoriteModel.dart';
import 'package:flutter/material.dart';

class Favoriteprovider with ChangeNotifier {
  final FavoriteModel _favoriteModel = FavoriteModel();

  FavoriteModel get favoriteModel => _favoriteModel;

  void selectFavorite(String favorite) {
    _favoriteModel.selectFavorite(favorite);
    notifyListeners();
  }
}
