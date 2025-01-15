import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MenuProvider with ChangeNotifier {
  bool _isLoading = false;

  // Getter untuk mengakses isLoading
  bool get isLoading => _isLoading;

  // Setter method untuk mengubah isLoading
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  double calculatePB1(double subtotal) {
    return subtotal * 0.10; // 10% dari subtotal
  }

  double calculateTotal(double subtotal, double pb1, double otherFees) {
    return subtotal + pb1 + otherFees;
  }

  List<Map<String, dynamic>> _menuData = [];

  List<Map<String, dynamic>> get menuData => _menuData;

  // Getter untuk total items dan total price
  int get totalItems {
    return _menuData.fold<int>(0, (sum, item) {
      int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      return sum + quantity;
    });
  }

  double get totalPrice {
    return _menuData.fold(
        0.0, (sum, item) => sum + (item['subtotal']?.toDouble() ?? 0.0));
  }

  double calculateItemTotal(Map<String, dynamic> item) {
    double itemPrice = double.tryParse(item['harga'] ?? '0') ?? 0.0;
    double variantPrice = 0.0;
    if (item['selected_variant'] != null &&
        item['selected_variant'].isNotEmpty) {
      var selectedVariant = (item['varian'] as List<dynamic>).firstWhere(
        (v) => v['kode'].toString() == item['selected_variant'],
        orElse: () =>
            <String, dynamic>{}, // Return an empty map instead of null
      );
      if (selectedVariant.isNotEmpty) {
        variantPrice =
            double.tryParse(selectedVariant['harga']?.toString() ?? '0') ?? 0.0;
      }
    }
    int quantity = (item['quantity'] as num?)?.toInt() ?? 0;
    return (itemPrice + variantPrice) * quantity;
  }

  Future<void> fetchMenuData() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        _isLoading = false;
        notifyListeners();
        return;
      }

      const String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];

        _menuData = data.map((item) {
          Map<String, dynamic> itemMenuData = item['data_item_menu'];

          List<Map<String, dynamic>> varianData = [];
          if (itemMenuData.containsKey('data_varian') &&
              itemMenuData['data_varian'] != null) {
            varianData =
                List<Map<String, dynamic>>.from(itemMenuData['data_varian']);
          }
          return {
            'id': item['id'].toString(),
            'productId': itemMenuData['id'].toString(),
            'gambar': itemMenuData['gambar'].toString(),
            'nama': itemMenuData['nama'].toString(),
            'harga': itemMenuData['harga'].toString(),
            'alt_harga': itemMenuData['alt_harga'].toString(),
            'ketersediaan': itemMenuData['ketersediaan'].toString(),
            'deskripsi': itemMenuData['deskripsi'].toString(),
            'varian': varianData,
            'quantity': item['qty'] ?? 0,
            'selected_variant': item['kode_varian'] ?? '',
            'subtotal': item['subtotal'] ?? 0,
            'alt_subtotal': item['alt_subtotal'] ?? '0',
          };
        }).toList();
      } else {
        throw 'Gagal memuat item. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

Future<void> postCheckoutData(Map<String, dynamic> checkoutData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('sanctumToken');
  if (token == null) {
    print('Token tidak ditemukan');
    return;
  }

  const String apiUrl =
      'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/perbarui';

  try {
    final response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(checkoutData),
    );

    if (response.statusCode == 200) {
      print('Data berhasil dikirim: ${response.body}');
    } else {
      print('Gagal mengirim data: ${response.statusCode}');
    }
  } catch (e) {
    print('Terjadi kesalahan: $e');
  }
}
