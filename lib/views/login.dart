import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:loka/providers/otp_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isOtpSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _phoneController.text = "628";

    _phoneController.addListener(() {
      String text = _phoneController.text;

      // Jika teks kosong, kembalikan ke "628"
      if (text.isEmpty) {
        _phoneController.text = "628";
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: 3),
        );
        return;
      }

      // Jika panjang teks kurang dari 3, pastikan itu "628"
      if (text.length < 3) {
        _phoneController.text = "628";
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: 3),
        );
        return;
      }

      // Jika awalan bukan "628", perbaiki
      if (!text.startsWith("628")) {
        // Hapus semua "628" yang mungkin ada di tengah teks
        String cleanText = text.replaceAll("628", "");
        // Hapus semua karakter non-digit
        cleanText = cleanText.replaceAll(RegExp(r'[^0-9]'), '');
        // Tambahkan "628" di awal
        _phoneController.text = "628" + cleanText;
        // Atur posisi kursor ke akhir
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> sendMessage(String phoneNumber) async {
    if (_isOtpSending) return;
    setState(() {
      _isOtpSending = true;
    });
    await saveOtpToServer(phoneNumber);
    setState(() {
      _isOtpSending = false;
    });
  }

  Future<void> saveOtpToServer(String phoneNumber) async {
    var saveOtpUrl = Uri.parse(
        'https://loka-mart.demoaplikasi.web.id/api/v1/login-by-telepon');
    var saveOtpRequest = http.MultipartRequest('POST', saveOtpUrl);
    saveOtpRequest.fields['telepon'] = phoneNumber;
    try {
      var saveOtpResponse = await saveOtpRequest.send();
      if (saveOtpResponse.statusCode == 200) {
        print('OTP berhasil dikirim ke nomor telepon');
      } else {
        print('Gagal mengirim OTP: ${saveOtpResponse.statusCode}');
      }
    } catch (e) {
      print('Error mengirim OTP: $e');
    }
  }

  void _validateAndSubmit() async {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.length <= 3) {
      // Check if only "628" is present
      setState(() {
        _errorMessage = "Tolong isikan nomor telepon";
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
      await sendMessage(phoneNumber);
      context.read<OtpProvider>().setPhoneNumber(phoneNumber);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/verifikasi',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned(
                              top: -50,
                              right: -50,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -100,
                              left: -100,
                              child: Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/logo-loka.png',
                                    width: constraints.maxWidth * 0.3,
                                    height: constraints.maxWidth * 0.3,
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    'Selamat Datang',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: constraints.maxWidth * 0.06,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Belanja dengan mudah bersama loka',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: constraints.maxWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Masukkan nomor telepon',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxWidth * 0.045,
                              ),
                            ),
                            SizedBox(height: 20),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.shade50,
                              ),
                              child: TextField(
                                controller: _phoneController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nomor dimulai dengan 628',
                                  hintStyle:
                                      GoogleFonts.poppins(color: Colors.grey),
                                ),
                                keyboardType: TextInputType.phone,
                                style: GoogleFonts.poppins(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                      13), // Batasi panjang maksimal
                                ],
                              ),
                            ),
                            SizedBox(height: 15),
                            Text(
                              'Kami akan mengirimkan kode verifikasi ke nomor ini',
                              style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontSize: constraints.maxWidth * 0.03,
                              ),
                            ),
                            SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isOtpSending ? null : _validateAndSubmit,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                    'Lanjutkan',
                                    style: GoogleFonts.poppins(
                                      fontSize: constraints.maxWidth * 0.04,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontSize: constraints.maxWidth * 0.035,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
