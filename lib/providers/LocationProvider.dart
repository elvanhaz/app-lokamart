import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  String _location = 'Menunggu lokasi...';
  String _placeName = 'Sedang mengambil nama tempat...';
  
  // Menyimpan latitude dan longitude
  double? _latitude;
  double? _longitude;

  String get location => _location;
  String get placeName => _placeName;

  double? get latitude => _latitude; // Getter untuk latitude
  double? get longitude => _longitude; // Getter untuk longitude

  Future<void> getCurrentLocation() async {
    try {
      bool permissionGranted = await _checkLocationPermission();
      if (!permissionGranted) {
        _location = 'Izin lokasi tidak diberikan';
        _placeName = 'Tidak dapat mengakses lokasi';
        notifyListeners();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks[0];

      // Mengambil nama jalan dan kota sebagai nama tempat
      _placeName = '${place.name}, ${place.locality}';
      _location = '${place.street}, ${place.locality}';
      
      // Menyimpan latitude dan longitude
      _latitude = position.latitude; 
      _longitude = position.longitude; 
    } catch (e) {
      _placeName = 'Nama tempat tidak ditemukan';
      _location = 'Lokasi tidak ditemukan';
      _latitude = null; // Reset jika ada kesalahan
      _longitude = null; // Reset jika ada kesalahan
    }
    notifyListeners();
  }

  void updateLocation(String newLocation, String newPlaceName) {
    _location = newLocation;
    _placeName = newPlaceName;
    notifyListeners();
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false; // Izin ditolak
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false; // Izin secara permanen ditolak
    }

    return true; // Izin diberikan
  }
}
