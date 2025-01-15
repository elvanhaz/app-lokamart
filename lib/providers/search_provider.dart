// providers/cabang_provider.dart
import 'package:flutter/material.dart';

import '../models/search_model.dart';

class SearchProvider with ChangeNotifier {
  final SearchModel _searchModel = SearchModel();

  SearchModel get searchModel => _searchModel;

  void selectSearch(String search) {
    _searchModel.selectSearch(search);
    notifyListeners();
  }
}
