import 'package:flutter/material.dart';

class OtpProvider with ChangeNotifier {
  String _phoneNumber = '';
    String get phoneNumber => _phoneNumber;

  void setPhoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  String getPhoneNumber() {
    return _phoneNumber;
  }

  // Add additional methods as needed
}
