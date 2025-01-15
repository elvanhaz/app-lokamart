import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GetOutletProvider extends ChangeNotifier {
  List<Map<String, dynamic>> outlets = [];
  List<Map<String, dynamic>> nearbyOutlets = [];
  List<Map<String, dynamic>> filteredOutlets = [];
  String userAddress = 'Loading location...';
  bool isLoading = true;
  String? sanctumToken;
  bool isRequestingPermission = false;

  GetOutletProvider(this.sanctumToken) {
    // Fetch outlets when the provider is initialized
    fetchOutlets();
  }

  Future<void> fetchOutlets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs
        .getString('sanctumToken'); // Sesuaikan kunci token sesuai kebutuhan

    if (token == null) {
      print('Token tidak tersedia');
      return;
    }
    print('Token kamu $token');
    isLoading = true;
    notifyListeners();

    try {
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
          outlets = (data['data'] as List).map((item) {
            return {
              'id': item['id'].toString(),
              'nama': item['nama'] as String? ?? 'Nama tidak tersedia',
              'alamat': item['alamat'] as String? ?? 'Alamat tidak tersedia',
              'gambar': item['gambar'] as String? ?? '',
              'latitude': double.tryParse(item['latitude'].toString()) ?? 0.0,
              'longitude': double.tryParse(item['longitude'].toString()) ?? 0.0,
            };
          }).toList();

          // Initialize filteredOutlets with all outlets
          filteredOutlets = List.from(outlets);

          isLoading = false;
          notifyListeners();

          // After fetching outlets, check location permission
          checkLocationPermission();
        }
      } else {
        print('Gagal mengambil data, status code: ${response.statusCode}');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLocationPermission() async {
    // Cegah permintaan izin ganda
    if (isRequestingPermission) {
      return;
    }

    isRequestingPermission = true;

    try {
      var status = await Permission.location.status;

      if (!status.isGranted) {
        // Minta izin lokasi jika belum diberikan
        var permissionResult = await Permission.location.request();

        if (permissionResult.isGranted) {
          // Izin diberikan, ambil data outlet terdekat
          await getNearbyOutlets();
        } else {
          // Izin ditolak
          userAddress = 'Location permission denied';
          isLoading = false;
          notifyListeners();
        }
      } else {
        // Izin sudah diberikan, ambil data outlet terdekat
        await getNearbyOutlets();
      }
    } finally {
      // Reset flag agar bisa meminta izin lagi di masa depan
      isRequestingPermission = false;
    }
  }

  Future<void> getNearbyOutlets() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      List<Map<String, dynamic>> sortedOutlets = outlets.map((outlet) {
        double distance = calculateDistance(
          position.latitude,
          position.longitude,
          outlet['latitude'],
          outlet['longitude'],
        );
        // Membulatkan jarak menjadi 1 desimal
        return {...outlet, 'distance': distance.toStringAsFixed(1)};
      }).toList();

      sortedOutlets.sort((a, b) => a['distance'].compareTo(b['distance']));

      userAddress = "${place.street}, ${place.locality}";
      nearbyOutlets = sortedOutlets;
      filteredOutlets = nearbyOutlets;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      userAddress = 'Location not found';
      isLoading = false;
      notifyListeners();
    }
  }

  void filterOutlets(String searchText) {
    filteredOutlets = nearbyOutlets.where((outlet) {
      return outlet['nama'].toLowerCase().contains(searchText.toLowerCase()) ||
          outlet['alamat'].toLowerCase().contains(searchText.toLowerCase());
    }).toList();
    notifyListeners();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = degToRad(lat2 - lat1);
    double dLon = degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degToRad(lat1)) *
            cos(degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double degToRad(double deg) {
    return deg * (pi / 180);
  }
}
