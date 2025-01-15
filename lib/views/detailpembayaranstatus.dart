import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DetailPembayaranStatusPage extends StatefulWidget {
  const DetailPembayaranStatusPage({super.key});

  @override
  State<DetailPembayaranStatusPage> createState() =>
      DetailPembayaranStatusState();
}

class DetailPembayaranStatusState extends State<DetailPembayaranStatusPage> {
  String _grossAmount = 'Rp0';
  String va_number = '';
  String _expiryTime = '';
  String paymentDisplayName = '';
  bool _isCopied =
      false; // State untuk mengecek apakah sudah disalin atau belum
  String? _billKey;
  String? _billerCode;
  String payment_type = '';
  String _orderId = ''; // Add orderId variable

  DateTime? _currentTime;
  Timer? _timer;
  Duration _remainingTime = const Duration();
  bool _isLoading = true; // State untuk memantau status loading
  @override
  @override
  void initState() {
    super.initState();
    _fetchCurrentTime();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Simulasikan pengambilan data (contoh penggunaan delay)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false; // Set setelah data berhasil dimuat
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    setState(() {
      _grossAmount = args['grossAmount'] ?? 'Rp0';
      va_number = args['vaNumber'] ?? '';
      paymentDisplayName = args['paymentDisplayName'] ?? '';
      _expiryTime = args['expiryTime'] ?? '';
      payment_type = args['paymentType'] ?? '';
      _orderId = args['orderId'] ?? ''; // Load orderId
      _billKey = args['billKey'] ?? ''; // Load billKey
      _billerCode = args['billerCode'] ?? ''; // Load billerCode

      // Update tampilannya sesuai tipe pembayaran
      if (payment_type == 'echannel') {
        paymentDisplayName = 'Mandiri Bill Payment';
      }
    });
  }

  Future<void> _checkTransactionStatus() async {
    print(
        'Order ID dari SharedPreferences: $_orderId'); // Print order_id untuk debug

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');

    if (token == null) {
      print('Token tidak ditemukan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
      return;
    }

    // Ambil order_id dari SharedPreferences
    if (_orderId != '') {
      try {
        final response = await http.get(
          Uri.parse(
              'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/cek-status-transaksi-midtrans/$_orderId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        print(
            'Response Status Code: ${response.statusCode}'); // Print status code
        print('Response Body: ${response.body}'); // Print body dari response

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Akses transaction_status di dalam status
          String transactionStatus = data['status']['transaction_status'];
          print(
              'Transaction Status: $transactionStatus'); // Print transaction status

          if (transactionStatus == 'settlement') {
            Navigator.pushNamed(
                context, '/pesanan'); // Redirect ke halaman pesanan
          } else if (transactionStatus == 'pending') {
            Navigator.pushNamed(context,
                '/statuspesanan'); // Redirect ke halaman status pesanan
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Transaksi tidak dalam status yang diharapkan: $transactionStatus')),
            );
          }
        } else {
          print(
              'Gagal mengambil status transaksi, status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengambil status transaksi.')),
          );
        }
      } catch (e) {
        print(
            'Error fetching transaction status: $e'); // Print error jika terjadi exception
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Terjadi kesalahan saat mengambil status transaksi.')),
        );
      }
    } else {
      print(
          'Order ID tidak ditemukan di SharedPreferences.'); // Print jika order_id tidak ditemukan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order ID tidak ditemukan.')),
      );
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)); // Salin ke clipboard
    setState(() {
      _isCopied = true; // Ubah state menjadi true setelah disalin
    });

    // Kembalikan teks "Salin" setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isCopied = false;
      });
    });
  }

  Future<void> _fetchCurrentTime() async {
    try {
      final response = await http
          .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Jakarta'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentTime = DateTime.parse(data['datetime']);
        _startCountdown();
      } else {
        print('Failed to load current time from server.');
      }
    } catch (e) {
      print('Error fetching current time: $e');
    }
  }

  void _startCountdown() {
    if (_expiryTime.isNotEmpty) {
      final deadline = DateTime.parse(_expiryTime);
      setState(() {
        _remainingTime = deadline.difference(_currentTime!);
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
          if (_remainingTime.isNegative) {
            _timer?.cancel();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Pembayaran', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading ? _buildShimmerLoading() : _buildContent(),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerBox(),
          const SizedBox(height: 16),
          _buildShimmerBox(),
          const SizedBox(height: 16),
          _buildShimmerBox(),
        ],
      ),
    );
  }

  Widget _buildShimmerBox() {
    return Container(
      width: double.infinity,
      height: 20.0,
      color: Colors.white,
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalPayment(),
            const SizedBox(height: 16),
            _buildPaymentDeadline(),
            const SizedBox(height: 16),
            _buildBankDetails(),
            const SizedBox(height: 16),
            _buildTransferInstructions(),
            const SizedBox(height: 16),
            _buildOkButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPayment() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total Pembayaran', style: TextStyle(fontSize: 16)),
          Text('Rp$_grossAmount',
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange)),
        ],
      );
    }
  }

  Widget _buildPaymentDeadline() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      );
    } else {
      final hours = _remainingTime.inHours;
      final minutes = _remainingTime.inMinutes.remainder(60);
      final seconds = _remainingTime.inSeconds.remainder(60);
      final countdown = hours > 0
          ? '${hours}h ${minutes}m ${seconds}s'
          : '${minutes}m ${seconds}s';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_orderId, style: const TextStyle(fontSize: 16)),
              Text(countdown,
                  style:
                      const TextStyle(fontSize: 16, color: Colors.redAccent)),
            ],
          ),
          const Divider(),
        ],
      );
    }
  }

  Widget _buildBankDetails() {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 150,
              height: 20,
              color: Colors.white,
            ),
            Container(
              width: 100,
              height: 20,
              color: Colors.white,
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.orange,
                child: Text(paymentDisplayName.toLowerCase(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Kondisi untuk menampilkan berdasarkan tipe pembayaran
          if (payment_type == 'echannel') ...[
            Text('Bill Key: $_billKey',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Biller Code: $_billerCode',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ] else if (payment_type == 'bank_transfer') ...[
            const Text('No. Rek/Virtual Account'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  va_number.toUpperCase(), // Teks dalam kapital
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _copyToClipboard(va_number), // Salin VA Number
                  child: Text(
                    _isCopied
                        ? 'Tersalin'
                        : 'Salin', // Ubah teks sesuai dengan state
                    style: const TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 8),
          const Text(
              'Proses verifikasi kurang dari 10 menit setelah pembayaran berhasil',
              style: TextStyle(color: Colors.teal)),
          const SizedBox(height: 8),
          const Text(
              'Bayar pesanan ke Virtual Account di atas sebelum membuat pesanan kembali dengan Virtual Account agar nomor tetap sama.',
              style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          const Divider(),
        ],
      );
    }
  }

  Widget _buildTransferInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              payment_type == 'echannel'
                  ? 'Petunjuk Pembayaran E-Channel'
                  : 'Petunjuk Transfer mBanking',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.keyboard_arrow_up),
          ],
        ),
        const SizedBox(height: 8),

        // Kondisi instruksi berdasarkan tipe pembayaran
        if (payment_type == 'bank_transfer') ...[
          _buildInstructionStep(
              '1', 'Pilih Transfer > Virtual Account Billing.'),
          _buildInstructionStep('2',
              'Pilih Rekening Debet > Masukkan nomor Virtual Account $va_number pada menu Input Baru.'),
          _buildInstructionStep('3',
              'Tagihan yang harus dibayar akan muncul pada layar konfirmasi.'),
          _buildInstructionStep('4',
              'Periksa informasi yang tertera di layar. Pastikan Merchant adalah Shopee, Total tagihan sudah benar.'),
        ] else if (payment_type == 'echannel') ...[
          _buildInstructionStep(
              '1', 'Pilih menu Pembayaran > E-Channel di mesin ATM.'),
          _buildInstructionStep('2',
              'Masukkan Bill Key: $_billKey dan Biller Code: $_billerCode.'),
          _buildInstructionStep('3',
              'Konfirmasi informasi yang tertera, dan pastikan sesuai dengan total tagihan.'),
          _buildInstructionStep(
              '4', 'Selesaikan pembayaran dan simpan bukti transaksi Anda.'),
        ],
      ],
    );
  }

  Widget _buildInstructionStep(String number, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
            child: Center(
                child: Text(number, style: const TextStyle(fontSize: 12))),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(instruction)),
        ],
      ),
    );
  }

  Widget _buildOkButton() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepOrange,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/statuspesanan');
            },
            child: Text('OK'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
            ),
            onPressed: () {
              _checkTransactionStatus(); // Panggil fungsi untuk memeriksa status transaksi
            },
            child: Text('Check Status'),
          ),
        ),
      ],
    );
  }
}
