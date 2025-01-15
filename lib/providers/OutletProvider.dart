import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OutletProvider extends ChangeNotifier {
  String _outletName = 'Menunggu...';

  String? _outletId;
  String? _outletAddress;
  double? _latitude;
  double? _longitude;
  Map<String, Map<String, dynamic>> _outletData =
      {}; // Untuk menyimpan outletId, nama, latitude, longitude, dan alamat

  String? get outletId => _outletId;
  String get outletName => _outletName;
  String? get outletAddress => _outletAddress;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  // Simpan outletId ke SharedPreferences dan notifyListeners jika ada perubahan
  Future<void> setOutletId(String id) async {
    if (_outletId != id) {
      _outletId = id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('outletId', id);
      // Ambil nama outlet, latitude, longitude, dan alamat berdasarkan ID yang dipilih
      await _setOutletDetails(id);
      notifyListeners();
    }
  }

  // Muat outletId dari SharedPreferences, pastikan notifyListeners dipanggil setelah frame selesai dibangun
  Future<void> loadOutletId() async {
    final prefs = await SharedPreferences.getInstance();
    _outletId = prefs.getString('outletId');

    if (_outletId != null) {
      await _setOutletDetails(_outletId!);
    }

    // Pastikan notifyListeners dipanggil setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  // Panggil API untuk mendapatkan data outlet dan simpan ke _outletData
  Future<void> fetchOutletData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse('https://loka-mart.demoaplikasi.web.id/api/v1/outlet'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] is List) {
          // Simpan data outlet di _outletData
          _outletData = {
            for (var item in data['data'])
              item['id'].toString(): {
                'name': item['nama'] as String? ?? 'Nama tidak tersedia',
                'latitude': double.tryParse(item['latitude'].toString()) ?? 0.0,
                'longitude':
                    double.tryParse(item['longitude'].toString()) ?? 0.0,
                'address': item['alamat'] as String? ?? 'Alamat tidak tersedia'
              }
          };
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        } else {
          print('Format data tidak sesuai');
        }
      } else if (response.statusCode == 401) {
        print('Sesi telah berakhir');
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  // Dapatkan nama outlet berdasarkan outletId
  Future<String?> getOutletNameById() async {
    if (_outletId != null) {
      // Pastikan outletData sudah diambil dari API
      if (_outletData.isEmpty) {
        await fetchOutletData();
      }
      _outletName = _outletData[_outletId]?['name'];

      // Pastikan notifyListeners dipanggil setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      return _outletName;
    }
    return null;
  }

  // Set outlet details berdasarkan outletId yang diberikan
  Future<void> _setOutletDetails(String id) async {
    if (_outletData.isNotEmpty && _outletData.containsKey(id)) {
      _outletName = _outletData[id]?['name'];
      _latitude = _outletData[id]?['latitude'];
      _longitude = _outletData[id]?['longitude'];
      _outletAddress = _outletData[id]?['address'];
    } else {
      // Jika outletData kosong, ambil data dari API
      await fetchOutletData();
      if (_outletData.containsKey(id)) {
        _outletName = _outletData[id]?['name'];
        _latitude = _outletData[id]?['latitude'];
        _longitude = _outletData[id]?['longitude'];
        _outletAddress = _outletData[id]?['address'];
      }
    }
    notifyListeners();
  }
}
