import 'dart:convert'; // untuk mengubah response menjadi JSON
import 'package:flutter/material.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:http/http.dart' as http; // untuk memanggil API

class KategoryPage extends StatefulWidget {
  const KategoryPage({super.key});

  @override
  _KategoryState createState() => _KategoryState();
}

class _KategoryState extends State<KategoryPage> {
  MidtransSDK? _midtrans;
  String _snapToken = ''; // Simpan snap token di sini
  String _orderId = ''; // Simpan order ID untuk pengecekan status

  @override
  void initState() {
    super.initState();
    initMidtrans();
  }

  Future<void> initMidtrans() async {
    String clientKey = 'SB-Mid-client-dKcG6OdHIXY0-YGN';
    String merchantBaseUrl =
        'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/buat-transaksi-midtrans/';

    try {
      _midtrans = await MidtransSDK.init(
        config: MidtransConfig(
          clientKey: clientKey,
          merchantBaseUrl: merchantBaseUrl,
          enableLog: true,
        ),
      );

      _midtrans?.setTransactionFinishedCallback((result) {
        print('Transaction finished: ${result.toJson()}');
        _orderId =
            result.orderId ?? ''; // Simpan orderId untuk pengecekan status
        _handleTransactionResult(result);
      });
    } catch (e) {
      print('Error initializing Midtrans SDK: $e');
    }
  }

  void _handleTransactionResult(TransactionResult result) {
    if (result.transactionStatus == 'capture' ||
        result.transactionStatus == 'settlement') {
      print('Transaction successful');
      // Tambahkan logika untuk menangani pembayaran berhasil
      _showSuccessDialog();
    } else if (result.transactionStatus == 'pending') {
      print('Transaction pending');
      // Tambahkan logika untuk menangani pembayaran pending
      _showPendingDialog();
    } else {
      print('Transaction failed or canceled');
      // Tambahkan logika untuk menangani pembayaran gagal atau dibatalkan
      _showFailureDialog();
    }
  }

  Future<void> _checkPaymentStatus() async {
    // URL API backend Anda untuk pengecekan status transaksi berdasarkan order_id
    String url =
        'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/status-transaksi-midtrans/$_orderId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Periksa status transaksi
        String transactionStatus = data['transaction_status'];
        print('Status transaksi: $transactionStatus');

        // Tangani status transaksi
        if (transactionStatus == 'capture' ||
            transactionStatus == 'settlement') {
          _showSuccessDialog();
        } else if (transactionStatus == 'pending') {
          _showPendingDialog();
        } else {
          _showFailureDialog();
        }
      } else {
        print('Gagal mendapatkan status transaksi');
      }
    } catch (e) {
      print('Error checking payment status: $e');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Berhasil'),
          content: const Text('Terima kasih atas pembayaran Anda.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _restartPaymentFlow(); // Mulai ulang alur pembayaran
              },
            ),
          ],
        );
      },
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Pending'),
          content: const Text(
              'Pembayaran Anda sedang diproses. Silakan cek status pembayaran nanti.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pembayaran Gagal'),
          content:
              const Text('Maaf, pembayaran Anda gagal. Silakan coba lagi.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _restartPaymentFlow() async {
    _snapToken = '96ed89d6-9664-4c1e-be11-2bffcc41d65b';

    if (_midtrans != null) {
      try {
        await _midtrans!.startPaymentUiFlow(
          token: _snapToken,
        );
      } catch (e) {
        print('Error restarting payment flow: $e');
      }
    } else {
      print('Midtrans SDK is not initialized');
    }
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midtrans Payment Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _checkPaymentStatus, // Tambahkan fungsi untuk cek status pembayaran
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _restartPaymentFlow,
          child: Text("Pay Now"),
        ),
      ),
    );
  }
}
