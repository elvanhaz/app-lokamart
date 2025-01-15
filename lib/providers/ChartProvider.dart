import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartProvider with ChangeNotifier {
  Map<String, int> _items = {};  // itemId as key, quantity as value
  double _totalPrice = 0.0;

  Map<String, int> get items => _items;
  double get totalPrice => _totalPrice;

  // Menambah item ke cart
  void addItem(String itemId, double price) {
    if (_items.containsKey(itemId)) {
      _items[itemId] = _items[itemId]! + 1;
    } else {
      _items[itemId] = 1;
    }
    _totalPrice += price;
    _saveCartToSharedPreferences();
    notifyListeners();
  }

  // Mengurangi item dari cart
  void removeItem(String itemId, double price) {
    if (_items.containsKey(itemId) && _items[itemId]! > 1) {
      _items[itemId] = _items[itemId]! - 1;
      _totalPrice -= price;
    } else {
      _items.remove(itemId);
      _totalPrice -= price;
    }
    _saveCartToSharedPreferences();
    notifyListeners();
  }

  // Menyimpan data ke SharedPreferences
  void _saveCartToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cart_items', _items.toString());
    prefs.setDouble('total_price', _totalPrice);
  }

  // Memuat data dari SharedPreferences
  void loadCartFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;

    String? cartData = prefs.getString('cart_items');
    if (cartData != null) {
      // Convert String back to Map
      _items = Map<String, int>.from(json.decode(cartData));
    }
    notifyListeners();
  }

  // Menghapus semua item dari cart
  void clearCart() {
    _items.clear();
    _totalPrice = 0.0;
    _saveCartToSharedPreferences();
    notifyListeners();
  }
}
