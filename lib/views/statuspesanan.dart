import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'dart:typed_data'; // Untuk Uint8List

class StatusPesananPage extends StatefulWidget {
  @override
  _StatusPesananPageState createState() => _StatusPesananPageState();
}

class _StatusPesananPageState extends State<StatusPesananPage> {
  final int _selectedIndex = 0;
  final List<String> _categories = ['Makanan', 'Mart', 'Keuangan', 'Express'];
  late Future<List<dynamic>> _pesananFuture;
  bool canPop = true; // Kondisi untuk mengontrol apakah back diperbolehkan

  // Map untuk melacak status pembayaran per order
  final Map<String, bool> _paymentStatus = {};
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool _isConnected = false;
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _pesananFuture = fetchPesanan();
    _pesananFuture.then((pesananList) {
      for (var pesanan in pesananList) {
        _loadPaymentStatusFromPreferences(pesanan['kode']);
      }
    });
  }

  Future<void> _initializeBluetooth() async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
        for (BluetoothDevice device in devices) {
          if (device.name?.toLowerCase().contains("printer") ?? false) {
            bool connected = await _connectToDevice(device);
            if (connected) return;
          }
        }
        if (!_isConnected && devices.isNotEmpty) {
          bool connected = await _connectToDevice(devices.first);
          if (connected) return;
        }
        break; // Exit loop if no errors but no suitable device found
      } catch (e) {
        print('Error initializing bluetooth (Attempt ${retryCount + 1}): $e');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    if (!_isConnected) {
      print('Failed to initialize Bluetooth after $maxRetries attempts');
    }
  }

  Future<bool> _connectToDevice(BluetoothDevice device) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        bool? isConnected = await bluetooth.isConnected;
        if (isConnected == true) {
          setState(() {
            _selectedDevice = device;
            _isConnected = true;
          });
          return true;
        }

        await bluetooth.connect(device);
        setState(() {
          _selectedDevice = device;
          _isConnected = true;
        });
        return true;
      } catch (e) {
        print('Error connecting to device (Attempt ${retryCount + 1}): $e');
        retryCount++;
        if (retryCount < maxRetries) {
          await Future.delayed(retryDelay);
        }
      }
    }

    print('Failed to connect to device after $maxRetries attempts');
    setState(() {
      _isConnected = false;
    });
    return false;
  }

  Future<void> _printReceipt(String orderId) async {
    if (_selectedDevice == null) return;

    try {
      Map<String, dynamic> orderDetails = await fetchOrderDetails(orderId);
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      final receiptData = _createReceipt(generator, orderDetails);

      await bluetooth.isConnected.then((isConnected) async {
        if (!isConnected!) {
          await bluetooth.connect(_selectedDevice!);
        }
        await bluetooth.writeBytes(receiptData);
        await bluetooth.disconnect();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt printed successfully')),
      );
    } catch (e) {
      print('Error printing receipt: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print receipt')),
      );
    }
  }

  Uint8List _createReceipt(
      Generator generator, Map<String, dynamic> orderDetails) {
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'RECEIPT',
      styles: PosStyles(
          align: PosAlign.center, bold: true, height: PosTextSize.size2),
    );

    bytes += generator.text('Order ID: ${orderDetails['kode']}');
    bytes += generator.text('Date: ${orderDetails['tanggal_pesanan']}');

    bytes += generator.hr();

    // Items
    for (var item in orderDetails['data_item_menu']) {
      bytes += generator.row([
        PosColumn(text: '${item['kuantitas']}x', width: 1),
        PosColumn(text: item['nama_item_menu'], width: 8),
        PosColumn(
            text: 'Rp${item['alt_subtotal']}',
            width: 3,
            styles: PosStyles(align: PosAlign.right)),
      ]);
    }

    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(text: 'TOTAL', width: 6, styles: PosStyles(bold: true)),
      PosColumn(
          text: 'Rp${orderDetails['alt_total']}',
          width: 6,
          styles: PosStyles(bold: true, align: PosAlign.right)),
    ]);

    // Footer
    bytes += generator.text('Thank you for your order!',
        styles: PosStyles(align: PosAlign.center));

    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }

  Future<void> _savePaymentStatusToPreferences(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        'paymentStatus_$orderId', true); // Simpan status pembayaran
  }

  Future<void> _loadPaymentStatusFromPreferences(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isPaid = prefs.getBool('paymentStatus_$orderId');

    if (isPaid != null && isPaid) {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          _paymentStatus[orderId] =
              true; // Update status pembayaran dari SharedPreferences
        });
      }
    }
  }

  void _showOrderDetailsModal(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchOrderDetails(orderId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading order details'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No details available'));
            }

            final orderData = snapshot.data!;

            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.5,
              maxChildSize: 0.5,
              expand: false,
              builder: (_, controller) {
                return ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rangkuman pesanan',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...orderData['data_item_menu'].map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${item['kuantitas']}x',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['nama_item_menu'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  if (item['keterangan'] != null)
                                    Text(item['keterangan'],
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Rp${item['alt_subtotal']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (item['harga_asli'] != null)
                                  Text('Rp${item['harga_asli']}',
                                      style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    _buildSummaryRow('Subtotal(Termasuk pajak)',
                        'Rp${orderData['alt_total']}'),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _checkTransactionStatus(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/cek-status-transaksi-midtrans/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String transactionStatus = data['status']['transaction_status'];
        String paymentType = data['status']['payment_type'];

        if (transactionStatus == 'settlement') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran telah diterima.')),
          );
          Navigator.pushNamed(context, '/pesanan', arguments: {
            'orderId': data['status']['order_id'],
          });
          // Update status pembayaran di Map untuk orderId ini
          // Simpan status pembayaran ke SharedPreferences
          await _savePaymentStatusToPreferences(orderId);

          setState(() {
            _paymentStatus[orderId] = true;
          });
          await _printReceipt(orderId);
        } else if (transactionStatus == 'pending') {
          if (paymentType == 'gopay') {
            // Hanya munculkan snackbar jika payment_type adalah gopay
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Transaksi GoPay dalam status pending.')),
            );
          } else if (paymentType == 'bank_transfer') {
            Navigator.pushNamed(
              context,
              '/detailpembayaranstatus',
              arguments: {
                'orderId': data['status']['order_id'],
                'grossAmount': data['status']['gross_amount'],
                'paymentType': paymentType,
                'expiryTime': data['status']['expiry_time'],
                'paymentDisplayName':
                    data['status']['va_numbers'][0]['bank'].toUpperCase(),
                'vaNumber': data['status']['va_numbers'][0]['va_number'],
              },
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pembayaran pending.')),
            );
            Navigator.pushNamed(
              context,
              '/detailpembayaranstatus',
              arguments: {
                'orderId': data['status']['order_id'],
                'transactionStatus': transactionStatus,
                'transactionTime': data['status']['transaction_time'],
                'grossAmount': data['status']['gross_amount'],
                'paymentType': paymentType,
                'expiryTime': data['status']['expiry_time'],
                'billerCode': data['status']['biller_code'],
                'billKey': data['status']['bill_key'],
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status transaksi: $transactionStatus')),
          );
        }
        return transactionStatus;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengambil status transaksi.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Terjadi kesalahan saat mengambil status transaksi.')),
      );
    }

    return null;
  }

// Fetch order details function
  Future<Map<String, dynamic>> fetchOrderDetails(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');

    final response = await http.get(
      Uri.parse(
          'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/detail/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception('Failed to load order details');
    }
  }

  Future<List<dynamic>> fetchPesanan() async {
    // Ganti dengan endpoint yang sesuai
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');
    if (token == null) {
      print('Token tidak ditemukan');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token tidak ditemukan.')),
      );
    }

    final response = await http.get(
      Uri.parse('https://loka-mart.demoaplikasi.web.id/api/v1/pesanan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Kembalikan array data pesanan
    } else {
      throw Exception('Gagal mengambil data pesanan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (canPop) {
          // Jika canPop true, arahkan ke halaman cabang
          Navigator.pushReplacementNamed(context, '/kategory');
        }
        return !canPop; // Prevent pop jika canPop true (handle sendiri navigasinya)
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Riwayat Aktivitas',
              style: TextStyle(color: Colors.black, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // _buildCategoryButtons(),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _pesananFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Gagal mengambil data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada pesanan'));
                  }

                  final pesananList = snapshot.data!;
                  return ListView.builder(
                    itemCount: pesananList.length,
                    itemBuilder: (context, index) {
                      final pesanan = pesananList[index];
                      final orderId = pesanan[
                          'kode']; // Ambil orderId untuk masing-masing pesanan

                      return GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman detailpembayaranstatus dengan membawa id pesanan
                          Navigator.pushNamed(
                            context,
                            '/detailpembayaranstatus',
                            arguments: pesanan[
                                'id_order'], // Ganti dengan field yang menyimpan ID order
                          );
                        },
                        child: _buildOrderItem(
                          orderId, // title (orderId)
                          pesanan['alamat'] ?? '', // subtitle
                          pesanan['status_pesanan'], // status pesanan
                          'Rp${pesanan['alt_total']}', // price
                          '+${pesanan['total']}', // points
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget _buildCategoryButtons() {
  //   return Container(
  //     height: 40,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _categories.length,
  //       itemBuilder: (context, index) {
  //         return Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 4),
  //           child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               foregroundColor: _selectedIndex == index ? Colors.white : Colors.black,
  //               backgroundColor: _selectedIndex == index ? Color(0xFF006D3B) : Colors.white,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(20),
  //               ),
  //               elevation: 0,
  //               side: BorderSide(color: _selectedIndex == index ? Colors.transparent : Colors.grey.shade300),
  //             ),
  //             onPressed: () {
  //               setState(() {
  //                 _selectedIndex = index;
  //               });
  //             },
  //             child: Text(_categories[index], style: TextStyle(fontSize: 14)),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget _buildOrderItem(
      String title, String subtitle, String date, String price, String points) {
    // Variabel tambahan untuk melacak status pembayaran

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.restaurant, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(price,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(date,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(points,
                        style:
                            const TextStyle(fontSize: 14, color: Colors.green)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              String? status =
                                  await _checkTransactionStatus(title);
                              if (status == 'settlement') {
                                setState(() {
                                  _paymentStatus[title] = true;
                                });
                                // Receipt will be printed automatically in _checkTransactionStatus
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Status transaksi: $status')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                  color: _paymentStatus[title] == true
                                      ? Colors.blue
                                      : Colors.green,
                                  width: 2),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _paymentStatus[title] == true
                                      ? Icons.check_circle
                                      : Icons.info,
                                  size: 16,
                                  color: _paymentStatus[title] == true
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _paymentStatus[title] == true
                                      ? 'Sudah Dibayar'
                                      : 'Belum Dibayar',
                                  style: TextStyle(
                                    color: _paymentStatus[title] == true
                                        ? Colors.blue
                                        : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Detail Pesanan Button with fill color
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showOrderDetailsModal(context, title);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Detail Pesanan',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, height: 16),
        ],
      ),
    );
  }
}
