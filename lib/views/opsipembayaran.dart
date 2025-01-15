import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding the data

import 'checkout.dart'; // Import your CheckoutPage or other relevant pages

class OpsipembayaranPage extends StatefulWidget {
  const OpsipembayaranPage({super.key});

  @override
  _OpsipembayaranPageState createState() => _OpsipembayaranPageState();
}

class _OpsipembayaranPageState extends State<OpsipembayaranPage> {
  bool _isBankSelected = false;
  bool _isLoading = false; // Status loading
  String? selectedPaymentMethod; // To track selected payment method
  String? selectedBank; // To track selected bank if bank transfer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Metode Pembayaran',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              'Yang Terhubung Dengan Anda',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          _buildClickablePaymentOption(
            iconPath: 'assets/gopay.png', // Path ke logo GoPay
            title: 'GoPay',
            paymentMethod: 'gopay',
          ),

          // _buildClickablePaymentOption(
          //   icon: Icons.shopping_bag,
          //   title: 'ShopeePay',
          //   paymentMethod: 'shopeepay',
          // ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Text(
              'Pilih Metode Pembayaran',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          _buildPaymentMethodSection(
            icon: Icons.account_balance,
            title: 'Transfer Bank',
            expanded: true,
            children: [
              _buildBankOption('bca'),
              _buildBankOption('mandiri'),
              _buildBankOption('Bank BNI'),
              _buildBankOption('Bank BRI'),
              // _buildBankOption('Bank Syariah Indonesia (BSI)'),
              // _buildBankOption('Bank Permata'),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    _isBankSelected && !_isLoading ? Colors.red : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isBankSelected && !_isLoading
                  ? () async {
                      setState(() {
                        _isLoading = true;
                      });

                      Map<String, String> paymentData = {
                        'platform': 'mobile',
                        'tipe_pesanan': 'diantar',
                        'id_outlet': '1',
                        'alamat': 'bogor',
                        'kurir': 'loka',
                        'metode_pembayaran': 'online',
                        'channel_pembayaran':
                            selectedPaymentMethod ?? 'Unknown',
                        'status_pembayaran': 'belum dibayar',
                        'status_pesanan': 'menunggu',
                        'status_midtrans': 'pending',
                        'catatan': 'tes',
                        'paymentMethod': selectedPaymentMethod ?? 'Unknown',
                        'displayName': selectedBank ?? 'Unknown',
                      };

                      try {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String? token = prefs.getString('sanctumToken');

                        if (token == null) {
                          print('Token tidak ditemukan');
                          return;
                        }

                        // Remove all previous transaction-related preferences
                        await prefs.remove('order_id');
                        await prefs.remove('platform');
                        await prefs.remove('payment_type');
                        await prefs.remove('bank_transfer');
                        await prefs.remove('bill_info1');
                        await prefs.remove('bill_info2');
                        await prefs.remove('va_number');
                        await prefs.remove('bill_key');
                        await prefs.remove('biller_code');

                        var response = await http.post(
                          Uri.parse(
                              'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/buat-pesanan'),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token',
                          },
                          body: jsonEncode(paymentData),
                        );

                        if (response.statusCode == 200) {
                          print('Response berhasil: ${response.body}');

                          Map<String, dynamic> responseData =
                              json.decode(response.body);
                          Map<String, dynamic>? forMidtransCoreApi =
                              responseData['for_midtrans_core_api'];

                          if (forMidtransCoreApi != null) {
                            await prefs.setString('order_id',
                                forMidtransCoreApi['order_id'] ?? '');
                            await prefs.setString('platform',
                                forMidtransCoreApi['platform'] ?? '');

                            if (forMidtransCoreApi['payment_type'] ==
                                'echannel') {
                              Map<String, dynamic>? echannelInfo =
                                  forMidtransCoreApi['echannel'];
                              if (echannelInfo != null) {
                                await prefs.setString('payment_type',
                                    forMidtransCoreApi['payment_type']);
                                await prefs.setString('bill_info1',
                                    echannelInfo['bill_info1'] ?? '');
                                await prefs.setString('bill_info2',
                                    echannelInfo['bill_info2'] ?? '');
                              }
                            } else if (forMidtransCoreApi
                                .containsKey('bank_transfer')) {
                              await prefs.setString('payment_type',
                                  forMidtransCoreApi['payment_type']);
                              await prefs.setString('bank_transfer',
                                  forMidtransCoreApi['bank_transfer'] ?? '');
                            } else if (forMidtransCoreApi['payment_type'] ==
                                'gopay') {
                              await prefs.setString('payment_type',
                                  forMidtransCoreApi['payment_type']);
                            }

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  paymentData: paymentData,
                                ),
                              ),
                              (Route<dynamic> route) =>
                                  false, // Kembali ke halaman baru dengan menghapus semua halaman sebelumnya
                            );
                          } else {
                            print('Invalid response data');
                          }
                        } else {
                          print(
                              'Failed to create order: ${response.statusCode}');
                        }
                      } catch (e) {
                        print('Error occurred: $e');
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  : null,
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('KONFIRMASI'),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection({
    required IconData icon,
    required String title,
    bool expanded = false,
    List<Widget> children = const [],
  }) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.redAccent),
      ),
      title: Text(title,
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14)),
      initiallyExpanded: expanded,
      children: children,
    );
  }

  Widget _buildClickablePaymentOption({
    required String iconPath, // Menggunakan path gambar sebagai parameter
    required String title,
    required String paymentMethod,
  }) {
    bool isSelected = selectedPaymentMethod == paymentMethod;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = paymentMethod;
          selectedBank =
              null; // Reset bank selection if another method is selected
          _isBankSelected = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath, // Menggunakan logo GoPay
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankOption(String bankName, [String? subtitle]) {
    bool isSelected = selectedBank == bankName;

    // Peta nama bank ke path gambar logo
    final Map<String, String> bankLogos = {
      'bca': 'assets/bca.png',
      'mandiri': 'assets/mandiri.png',
      'bank bni': 'assets/bni.png',
      'bank bri': 'assets/bri.png',
      // 'bank syariah indonesia (bsi)': 'assets/bsi.png',
      // 'bank permata': 'assets/permata.png',
    };

    String? logoPath = bankLogos[bankName.toLowerCase()];

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBank = bankName;

          // Kondisi untuk mengatur metode pembayaran sesuai bank yang dipilih
          if (bankName.toLowerCase() == 'mandiri') {
            selectedPaymentMethod = "echannel,$bankName";
          } else if (bankName.toLowerCase() == 'bank permata') {
            selectedPaymentMethod = "permata,$bankName";
          } else if (bankName.toLowerCase() == 'gopay') {
            selectedPaymentMethod = "gopay,$bankName";
          } else if (bankName.toLowerCase() == 'shopeepay') {
            selectedPaymentMethod = "shopeepay,$bankName";
          } else {
            selectedPaymentMethod = "bank_transfer,$bankName";
          }

          _isBankSelected = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: logoPath != null
              ? Image.asset(
                  logoPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                )
              : const FlutterLogo(), // Default logo jika logo tidak ditemukan
          title: Text(
            bankName,
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: subtitle != null
              ? Text(subtitle, style: const TextStyle(fontSize: 12))
              : null,
        ),
      ),
    );
  }
}
