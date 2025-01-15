import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:loka/routes/app_routes.dart';
import 'package:loka/providers/otp_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({super.key});

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  late DateTime _otpExpiryTime;
  int _timeRemaining = 300; // 5 menit dalam detik
  bool _canResendCode = true; // Track if the resend button is clickable
  int _resendCooldown = 300; // Cooldown time for resend in seconds
  late String _phoneNumber;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _phoneNumber = context.read<OtpProvider>().getPhoneNumber();
    _startOtpTimer();
    _fetchOtpExpiryTime();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchOtpExpiryTime() async {
    try {
      // Panggil API untuk mendapatkan waktu kadaluarsa OTP
      var url = Uri.parse(
          'http://sela-resto.beritanesia.id/api/v1/check-verified/$_phoneNumber');
      var response = await http.get(url);

      if (response.statusCode == 200) {p
        var responseData = json.decode(response.body);
        String otpTimestamp = responseData['timestamp'];

        // Parsing waktu OTP dan menghitung waktu kadaluarsa
        DateTime otpTime = DateTime.parse(otpTimestamp);
        DateTime currentTime = await NTP.now();

        if (mounted) {
          setState(() {
            _otpExpiryTime = otpTime.add(const Duration(minutes: 5));
            _timeRemaining = _otpExpiryTime.difference(currentTime).inSeconds;
          });
        }
      } else {
        print('Error fetching OTP expiry time: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  void _startOtpTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          _otpExpired();
        }
      }
    });
  }

  void _startResendCooldown() {
    setState(() {
      _canResendCode = false;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer
            .cancel(); // Ensure the timer is canceled if the widget is disposed
        return;
      }

      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResendCode = true;
            _resendCooldown = 300; // Reset cooldown timer
          });
        }
      }
    });
  }

  void _otpExpired() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP telah kadaluarsa. Silakan minta OTP baru.'),
      ),
    );
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _resendOtpCode() async {
    String generateOtp() {
      var random = Random();
      int otp = random.nextInt(900000) + 100000;
      return otp.toString();
    }

    String otpCode = generateOtp();
    var url = Uri.parse('https://app.wapanels.com/api/create-message');
    var headers = {
      'Content-Type': 'application/json',
    };

    var requestBody = {
      'appkey': '3bf1b60b-b170-49c4-b8f8-9ca3cf35e7c9',
      'authkey': '4dJOBpMkbqQO5q13FGXvPYAL2t5oyY7w48YPyzW5I6CqPndOVf',
      'to': _phoneNumber,
      'message': 'Hallo sayang, kode OTP kamu adalah: $otpCode',
      'sandbox': false
    };

    try {
      var response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody), // Encode body as JSON
      );

      if (response.statusCode == 200) {
        print('Message sent successfully');
        // Simpan OTP ke database Firebase
      } else {
        print('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
    _startResendCooldown();
  }

  Future<void> _verifyOtp() async {
    String smsCode = _otpController.text.trim();

    if (smsCode.length != 6) {
      _showErrorSnackBar('Kode OTP harus terdiri dari 6 digit.');
      return;
    }

    try {
      var url = Uri.parse(
          'https://loka-mart.demoaplikasi.web.id/api/v1/verifikasi-otp');
      var response = await http.post(
        url,
        body: {
          'telepon': _phoneNumber,
          'otp': smsCode,
        },
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          // Simpan token Sanctum jika ada dalam respons
          if (responseData['token'] != null) {
            String sanctumToken = responseData['token'];
            try {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('sanctumToken', sanctumToken);
              print('Token Sanctum berhasil disimpan: $sanctumToken');
            } catch (e) {
              print('Error saat menyimpan token: $e');
              // Meskipun gagal menyimpan token, kita tetap lanjutkan prosesnya
            }
          }

          // Navigasi ke halaman berikutnya
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/cabang',
            (Route<dynamic> route) => false,
          );
        } else {
          // OTP tidak valid
          _showErrorSnackBar('OTP tidak valid. Silakan coba lagi.');
        }
      } else {
        // Kesalahan server
        _showErrorSnackBar(
            'Terjadi kesalahan server. Silakan coba lagi nanti.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorSnackBar('Terjadi kesalahan. Silakan coba lagi.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> verifyOtp(String phoneNumber, String smsCode) async {
    try {
      var url =
          Uri.parse('http://sela-resto.beritanesia.id/api/v1/verifikasi-otp');
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'telepon': _phoneNumber,
          'otp': _otpController.text,
        }),
      );

      if (response.statusCode == 200) {
        print('berhasil');
        return true; // Tambahkan fallback jika tidak ada nilai 'isValid'
      } else {
        print('Failed to verify OTP: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      return false; // Pastikan selalu ada return dalam catch
    }
  }

  String _formatTimeRemaining(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatTimeRemaining(_timeRemaining),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'kami akan mengirimkan kode otp',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(6, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    index < _otpController.text.length
                        ? _otpController.text[index]
                        : '',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.pink,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  if (index == 9) {
                    return const SizedBox.shrink();
                  } else if (index == 10) {
                    return _buildNumberButton(0);
                  } else if (index == 11) {
                    return _buildDeleteButton();
                  } else {
                    return _buildNumberButton(index + 1);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _canResendCode ? _resendOtpCode : null,
              child: Text(
                _canResendCode
                    ? 'Send again'
                    : 'Wait $_resendCooldown seconds to resend',
                style: TextStyle(
                  color: _canResendCode ? Colors.blue : Colors.grey,
                  decoration: _canResendCode
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () {
        if (_otpController.text.length < 6) {
          setState(() {
            _otpController.text += number.toString();
          });
          if (_otpController.text.length == 6) {
            // Verify OTP automatically when 6 digits are entered
            _verifyOtp();
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        number.toString(),
        style: const TextStyle(color: Colors.black, fontSize: 24),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: () {
        if (_otpController.text.isNotEmpty) {
          setState(() {
            _otpController.text = _otpController.text
                .substring(0, _otpController.text.length - 1);
          });
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Icon(Icons.backspace_outlined, color: Colors.black),
    );
  }
}
