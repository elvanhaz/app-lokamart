import 'package:flutter/material.dart';

class ItemProvider with ChangeNotifier {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> categories = [];
  bool isCategoryLoading = true;
  String selectedCategory = '0';

  Future<void> fetchItemsFromApi(String outletId) async {
    try {
      // Fetch items logic here
      notifyListeners();
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  Future<void> fetchCategoriesFromApi() async {
    // Fetch categories logic
    notifyListeners();
  }

  void syncCartWithItems(List<Map<String, dynamic>> cartItems) {
    if (cartItems.isNotEmpty) {
      for (var item in items) {
        var cartItem = cartItems.firstWhere((cart) => cart['id_item_menu'] == item['id'], orElse: () => {});
        if (cartItem.isNotEmpty) {
          item['quantity'] = int.tryParse(cartItem['qty']) ?? 0;
          item['isAddedToCart'] = true;
        } else {
          item['quantity'] = 0;
          item['isAddedToCart'] = false;
        }
      }
    }
    notifyListeners();
  }
}
