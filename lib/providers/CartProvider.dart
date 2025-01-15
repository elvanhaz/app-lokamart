import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  int _itemCount = 0;
  double _totalPrice = 0.0;
  bool _isFabVisible = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> get cartItems => _cartItems;
  int get itemCount => _itemCount;
  double get totalPrice => _totalPrice;
  bool get isFabVisible => _isFabVisible;
  bool get isLoading => _isLoading;
  Future<void> fetchCartData(String outletId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners()); // Update the state after build

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang?id_outlet=$outletId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        _itemCount = data['data'].fold<int>(0, (int sum, dynamic item) {
          int qty = item['qty'] is String
              ? int.tryParse(item['qty']) ?? 0
              : item['qty'];
          return sum + qty;
        });

        _totalPrice =
            data['data'].fold<double>(0.0, (double sum, dynamic item) {
          double subtotal = item['subtotal'] is num
              ? (item['subtotal'] as num).toDouble()
              : 0.0;
          return sum + subtotal;
        });

        _cartItems =
            List<Map<String, dynamic>>.from(data['data'].map((item) => {
                  'id': item['id'].toString(),
                  'id_item_menu': item['id_item_menu'].toString(),
                  'kode_varian': item['kode_varian'].toString(),
                  'qty': item['qty'].toString(),
                  'subtotal': item['subtotal'].toString(),
                  'alt_subtotal': item['alt_subtotal'].toString(),
                  'data_item_menu': {
                    'id': item['data_item_menu']['id'].toString(),
                    'gambar': item['data_item_menu']['gambar'].toString(),
                    'nama': item['data_item_menu']['nama'].toString(),
                  },
                }));

        _isFabVisible = _itemCount > 0;
      } else {
        print(
            'Gagal memuat data keranjang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners()); // Notify after build phase
    }
  }

  Future<void> optimisticAddToCart(String itemId, int quantity, String outletId,
      Map<String, dynamic> itemData) async {
    // Optimistically update the cart
    int existingIndex =
        _cartItems.indexWhere((item) => item['id_item_menu'] == itemId);
    if (existingIndex != -1) {
      _cartItems[existingIndex]['qty'] = quantity.toString();
      _cartItems[existingIndex]['subtotal'] =
          (double.parse(itemData['harga']) * quantity).toString();
    } else {
      _cartItems.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        'id_item_menu': itemId,
        'qty': quantity.toString(),
        'subtotal': (double.parse(itemData['harga']) * quantity).toString(),
        'data_item_menu': itemData,
      });
    }
    _updateCartStats();
    notifyListeners();

    // Perform the actual server request
    try {
      await addToCart(itemId, quantity, outletId);
    } catch (e) {
      // If the server request fails, revert the optimistic update
      await fetchCartData(outletId);
    }
  }

  Future<void> optimisticRemoveFromCart(String itemId, String outletId) async {
    // Optimistically update the cart
    _cartItems.removeWhere((item) => item['id_item_menu'] == itemId);
    _updateCartStats();
    notifyListeners();

    // Perform the actual server request
    try {
      await removeFromCart(itemId, outletId);
    } catch (e) {
      // If the server request fails, revert the optimistic update
      await fetchCartData(outletId);
    }
  }

  void _updateCartStats() {
    _itemCount =
        _cartItems.fold<int>(0, (sum, item) => sum + int.parse(item['qty']));
    _totalPrice = _cartItems.fold<double>(
        0.0, (sum, item) => sum + double.parse(item['subtotal']));
    _isFabVisible = _itemCount > 0;
  }

  Future<bool> addToCart(String itemId, int quantity, String outletId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return false;
      }

      final response = await http.post(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/simpan-atau-perbarui'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'id_item_menu': itemId,
          'qty': quantity.toString(),
          'id_outlet': outletId,
        },
      );

      if (response.statusCode == 200) {
        await fetchCartData(outletId);
        return true;
      } else {
        print(
            'Gagal menambahkan ke keranjang. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<bool> removeFromCart(String itemId, String outletId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return false;
      }

      final response = await http.delete(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/hapus'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'id_item_menu': itemId,
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('cart_$itemId');
        await fetchCartData(outletId);
        return true;
      } else {
        print(
            'Gagal menghapus dari keranjang. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }
}
