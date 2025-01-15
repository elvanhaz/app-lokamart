import 'dart:convert';
import 'package:loka/providers/LocationProvider.dart';
import 'package:loka/providers/MenuProvider.dart';
import 'package:loka/providers/OutletProvider.dart';
import 'package:loka/providers/otp_provider.dart';
import 'package:loka/views/opsipembayaran.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:shimmer/shimmer.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, String> paymentData;
  const CheckoutPage({super.key, required this.paymentData});
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutPage> {
  late String paymentDisplayName;
  late String selectedPaymentMethod;
  MidtransSDK? _midtrans;
  final String _snapToken = '';
  double _distance = 0.0;
  double _estimatedCost = 0.0;
  final double _deliveryRate = 2000.0;
  double _estimatedTime = 0.0;
  String? orderId;

  String? platform;
  String? paymentType;
  String? bankTransfer;
  final double _averageSpeed =
      20.0; // Kecepatan rata-rata pengiriman dalam km/jam
  double calculatePB1(double subtotal) {
    return subtotal * 0.10; // 10% dari subtotal
  }

  double calculateTotal(double subtotal, double pb1) {
    return subtotal + pb1;
  }

  final PageController _pageController = PageController(viewportFraction: 0.6);
  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  _loadPaymentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      orderId = prefs.getString('order_id');
      platform = prefs.getString('platform');
      paymentType = prefs.getString('payment_type');
      bankTransfer = prefs.getString('bank_transfer');
    });
  }

  double _currentPage = 0.0;
  final List<List<Color>> _backgroundGradients = [
    [Colors.pink[100]!, Colors.pink[300]!],
    [Colors.lightBlue[100]!, Colors.lightBlue[300]!],
    [Colors.green[100]!, Colors.green[300]!],
    [Colors.orange[100]!, Colors.orange[300]!],
    [Colors.purple[100]!, Colors.purple[300]!],
    [Colors.teal[100]!, Colors.teal[300]!],
    [Colors.yellow[100]!, Colors.yellow[300]!],
    [Colors.red[100]!, Colors.red[300]!],
    [Colors.indigo[100]!, Colors.indigo[300]!],
    [Colors.cyan[100]!, Colors.cyan[300]!],
  ];

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
    paymentDisplayName =
        widget.paymentData['displayName'] ?? 'Pilih Pembayaran';
    selectedPaymentMethod =
        widget.paymentData['paymentMethod'] ?? 'Pilih Pembayaran';

    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.addListener(_onPageChanged);
      Provider.of<MenuProvider>(context, listen: false).fetchMenuData();
      _calculateDistance();
    });
    setState(() {
      platform = null;
      paymentType = null;
      bankTransfer = null;
    });
  }

  Future<String?> _createTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');

    if (token == null) {
      print('Token tidak ditemukan');
      return null;
    }

    if (orderId == null ||
        platform == null ||
        paymentType == null ||
        paymentDisplayName.isEmpty) {
      print('Some required data is missing');
      return null;
    }

    String bankTransferName =
        paymentType == 'gopay' ? 'gopay' : paymentDisplayName;

    final response = await http.post(
      Uri.parse(
          'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/buat-transaksi-midtrans-core-api'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'order_id': orderId,
        'platform': platform,
        'payment_type': paymentType,
        'bank_transfer': bankTransferName,
      }),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      // Reset data di SharedPreferences
      await prefs.remove('order_id');
      await prefs.remove('platform');
      await prefs.remove('payment_type');
      await prefs.remove('bank_transfer');
      await prefs.remove('displayName');
      await prefs.remove('transaction_id');
      await prefs.remove('paymentMethod');

      if (responseBody['midtrans'] != null) {
        final midtrans = responseBody['midtrans'];
        await prefs.setString('transaction_id', midtrans['transaction_id']);
        await prefs.setString('order_id', midtrans['order_id']);
        await prefs.setString('gross_amount', midtrans['gross_amount']);
        await prefs.setString('payment_type', midtrans['payment_type']);
        await prefs.setString(
            'transaction_status', midtrans['transaction_status']);
        await prefs.setString('expiry_time', midtrans['expiry_time']);

        if (responseBody['midtrans'] != null) {
          final midtrans = responseBody['midtrans'];
          // Validasi dan simpan semua data yang dibutuhkan
          if (midtrans['transaction_id'] != null) {
            await prefs.setString('transaction_id', midtrans['transaction_id']);
          }
          if (midtrans['order_id'] != null && midtrans['order_id'].isNotEmpty) {
            await prefs.setString('order_id', midtrans['order_id']);
          } else {
            print('Order ID is missing or empty.');
          }
          await prefs.setString('gross_amount', midtrans['gross_amount'] ?? '');
          await prefs.setString('payment_type', midtrans['payment_type'] ?? '');
          await prefs.setString(
              'transaction_status', midtrans['transaction_status'] ?? '');
          await prefs.setString('expiry_time', midtrans['expiry_time'] ?? '');

          // Handling khusus untuk GoPay
          if (midtrans['payment_type'] == 'gopay') {
            String? gopayDeeplink;
            for (var action in midtrans['actions']) {
              if (action['name'] == 'deeplink-redirect') {
                gopayDeeplink = action['url'];
                break;
              }
            }
            if (gopayDeeplink != null) {
              await prefs.setString('gopay_deeplink_url', gopayDeeplink);
              print('Transaction details saved successfully for GoPay.');
              return gopayDeeplink;
            }
          }
          // Handling khusus untuk echannel
          else if (midtrans['payment_type'] == 'echannel') {
            if (midtrans['bill_key'] != null) {
              await prefs.setString('bill_key', midtrans['bill_key']);
            }
            if (midtrans['order_id'] != null) {
              await prefs.setString('order_id', midtrans['order_id']);
            }
            if (midtrans['biller_code'] != null) {
              await prefs.setString('biller_code', midtrans['biller_code']);
            }
            print('Transaction details saved successfully for echannel.');
          }
          // Handling bank transfer
          else if (midtrans['va_numbers'] != null &&
              midtrans['va_numbers'].isNotEmpty) {
            await prefs.setString('va_bank', midtrans['va_numbers'][0]['bank']);
            await prefs.setString(
                'va_number', midtrans['va_numbers'][0]['va_number']);
            print('Transaction details saved successfully for bank transfer.');
          }
        } else {
          print('Response does not contain the expected "midtrans" key.');
        }
      }
    } else {
      print(
          'Failed to create transaction. Status Code: ${response.statusCode}');
      throw Exception('Failed to create transaction');
    }
    return null;
  }

  Future<void> _calculateDistance() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);

    if (locationProvider.latitude != null && outletProvider.latitude != null) {
      // Menghitung jarak menggunakan koordinat pengguna dan outlet
      double distanceInMeters = Geolocator.distanceBetween(
        locationProvider.latitude!,
        locationProvider.longitude!,
        outletProvider.latitude!,
        outletProvider.longitude!,
      );

      setState(() {
        // Ubah jarak ke kilometer
        _distance = distanceInMeters / 1000; // Konversi ke kilometer
        _estimatedCost = _distance * _deliveryRate; // Hitung biaya

        // Hitung estimasi waktu (dalam menit)
        _estimatedTime = (_distance / _averageSpeed) * 60; // Konversi ke menit
      });
    }
  }

  void _onPageChanged() {
    if (_pageController.hasClients) {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    }
  }

  @override
  void dispose() {
    _midtrans?.removeTransactionFinishedCallback();

    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Kembali ke halaman sebelumnya
        },
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<MenuProvider>(
          builder: (context, menuProvider, child) {
            if (menuProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (menuProvider.menuData.isEmpty) {
              return const Center(child: Text('No data available'));
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(menuProvider),
                  const Divider(),
                  SizedBox(
                    height: MediaQuery.of(context)
                        .size
                        .height, // This will make the TabBarView scrollable
                    child: TabBarView(
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling of TabBarView
                      children: [
                        _buildPengiriman(menuProvider),
                        _buildDonutsTab(menuProvider),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomAppBar(context),
      ),
    );
  }

  Widget _buildPaymentDetailss(MenuProvider menuProvider) {
    final otpProvider = Provider.of<OtpProvider>(context);

    const double subtotal = 50000; // Contoh subtotal
    final double pb1 = calculatePB1(subtotal);
    final double total = calculateTotal(subtotal, pb1);
    bool useOVOPoints = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail pembayaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
//               Text('Order ID: $orderId'),
//           Text('Platform: $platform'),
//           Text('Payment Type: $paymentType'),
//           Text('Bank Transfer: ${paymentType == 'gopay' ? 'Gopay' : paymentDisplayName}',
// ),
              // Text('Nomor telepon yang diverifikasi:', semanticsLabel: otpProvider.phoneNumber),

              const SizedBox(height: 16),
              // _buildDetailRow(
              //   leading: Container(
              //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Colors.transparent,
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     child: Text(
              //       ' ${paymentType == 'gopay' ? 'Gopay' : paymentDisplayName}',
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              //   title: formatRupiah(total),
              //   onTap: () async {
              //     // Arahkan ke halaman pilihan metode pembayaran jika ingin mengganti
              //     final result = await Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => OpsipembayaranPage(),
              //       ),
              //     );

              //     // Jika ada data yang dikembalikan, tampilkan nama yang dipilih
              //     if (result != null && result is Map<String, String>) {
              //       setState(() {
              //         paymentDisplayName = result['displayName'] ?? 'Pilih Pembayaran';
              //       });
              //     }
              //   },
              // ),
              const Divider(),
              _buildDetailRow(
                leading: const Icon(Icons.payment),
                title:
                    ' ${paymentType == 'gopay' ? 'Gopay' : paymentDisplayName}',
                onTap: () async {
                  // Arahkan ke halaman pilihan metode pembayaran jika ingin mengganti
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpsipembayaranPage(),
                    ),
                  );

                  // Jika ada data yang dikembalikan, tampilkan nama yang dipilih
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      paymentDisplayName =
                          result['displayName'] ?? 'Pilih Pembayaran';
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    final itemCount = menuProvider.totalItems; // Ambil item count dari provider
    final isLoading =
        menuProvider.isLoading; // Ambil loading status dari provider
    final double subtotal = menuProvider.totalPrice; // Subtotal dari provider
    final double pb1 = calculatePB1(subtotal); // Hitung PB1 (10% dari subtotal)
    final double total = calculateTotal(subtotal, pb1); // Total akhir

    return BottomAppBar(
      color: Colors.white,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                const Icon(Icons.shopping_basket,
                    size: 30, color: Colors.white),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: const BoxDecoration(
                        color: Colors.blueGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        enabled: isLoading,
                        child: Text(
                          itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.white,
                  enabled: isLoading,
                  child: Text(
                    'Rp${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: menuProvider.isLoading
                  ? null
                  : () async {
                      // Validasi apakah metode pembayaran sudah dipilih
                      if (selectedPaymentMethod == 'Pilih Pembayaran') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Pilih metode pembayaran terlebih dahulu.')),
                        );
                        return;
                      }

                      // Set loading state menjadi true
                      menuProvider.setLoading(true);

                      try {
                        // Lakukan transaksi pembayaran di sini
                        final gopayDeeplink = await _createTransaction();
                        Navigator.pushReplacementNamed(
                            context, '/statuspesanan');

                        if (gopayDeeplink != null) {
                          final uri = Uri.parse(gopayDeeplink);

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            print('Could not launch $gopayDeeplink');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Tidak dapat membuka aplikasi GoPay')),
                            );
                          }
                        } else {
                          // Jika bukan GoPay, arahkan ke halaman detail pembayaran
                          Navigator.pushReplacementNamed(
                              context, '/detailpembayaran');
                        }

                        // Reset data di SharedPreferences
                        // Hapus nomor telepon dari OtpProvider jika diperlukan
                        // Provider.of<OtpProvider>(context, listen: false).resetPhoneNumber();
                      } catch (e) {
                        print('Error creating transaction: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Terjadi kesalahan saat memproses pembayaran')),
                        );
                      } finally {
                        // Set loading state menjadi false setelah selesai
                        menuProvider.setLoading(false);
                      }
                    },
              // ... (sisa kode tombol)

              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              child: menuProvider.isLoading
                  ? const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                    )
                  : Text(
                      'Bayar Sekarang (${itemCount.toString()})',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(MenuProvider menuProvider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          margin: const EdgeInsets.only(bottom: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _backgroundGradients[
                  (_currentPage.round()) % _backgroundGradients.length],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(180),
              bottomRight: Radius.circular(180),
            ),
          ),
        ),
        Positioned(
          top: 50, // Menempatkan tombol back di posisi atas
          left: 16, // Menambahkan jarak dari kiri
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Navigasi kembali ke halaman sebelumnya
            },
          ),
        ),
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Consumer<OutletProvider>(
                builder: (context, outletProvider, child) {
                  final outletName =
                      outletProvider.outletName ?? 'Outlet tidak ditemukan';
                  return Text(
                    outletName, // Menampilkan nama outlet
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 360,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: menuProvider.menuData.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/checkoutedit',
                          arguments: menuProvider.menuData[index],
                        );
                      },
                      child: _buildSlide(menuProvider.menuData[index], index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(Map<String, dynamic> menuData, int index) {
    final menuProvider = Provider.of<MenuProvider>(context);
    double total = menuProvider.calculateItemTotal(menuData);
    double delta = (index - _currentPage).abs();
    double opacity = (1 - delta).clamp(0.0, 1.0);

    var selectedVariant = menuData['varian'].firstWhere(
      (v) => v['kode'].toString() == menuData['selected_variant'],
      orElse: () => {'nama': 'Unknown'},
    )['nama'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/checkoutedit',
                arguments: menuData, // Mengirim data ke halaman berikutnya
              );
            },
            child: Hero(
              tag: menuData['id'], // Use a unique tag
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  menuData['gambar'],
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Agar di tengah
                  children: [
                    Text(
                      menuData['nama'],
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                        width: 8), // Memberi jarak antara nama dan quantity
                    Text(
                      'x${menuData['quantity']}', // Menampilkan quantity
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(total), // Menggunakan fungsi formatRupiah
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (menuData['varian'] != null && menuData['varian'].isNotEmpty)
                  Text(
                    ' $selectedVariant',
                    style:
                        GoogleFonts.poppins(fontSize: 15, color: Colors.black),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPengiriman(MenuProvider menuProvider) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/detaillokasi');
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locationProvider.placeName,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                locationProvider.location,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Pengantaran dari ${outletProvider.outletName ?? 'Outlet'}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Jarak: ${_distance.toStringAsFixed(2)} km',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 8),
          _buildDeliveryOption(
            'Standar',
            '${_estimatedTime.toStringAsFixed(0)} Menit',
            '',
            'Biaya: ${formatRupiah(_estimatedCost)}',
            false,
          ),
          const SizedBox(height: 24),
          _buildPaymentDetails(menuProvider),
          _buildPaymentDetailss(menuProvider),
        ],
      ),
    );
  }
}

String formatRupiah(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  return formatter.format(amount);
}

Widget _buildPaymentDetails(MenuProvider menuProvider) {
  final double subtotal = menuProvider.totalPrice; // Subtotal dari provider
  final double pb1 = calculatePB1(subtotal); // Hitung PB1 (10% dari subtotal)
  final double total = calculateTotal(subtotal, pb1); // Total akhir
  String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal (${menuProvider.totalItems} menu)',
                style: TextStyle(color: Colors.grey[700])),
            Text(formatRupiah(subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Other fees', style: TextStyle(color: Colors.grey[700])),
                Icon(Icons.keyboard_arrow_down,
                    size: 18, color: Colors.grey[500]),
              ],
            ),
            Text(formatRupiah(pb1),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('PB1 (10%)', style: TextStyle(color: Colors.grey[500])),
              Text(formatRupiah(pb1),
                  style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(formatRupiah(total),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)),
          ],
        ),
      ],
    ),
  );
}

double calculatePB1(double subtotal) {
  return subtotal * 0.10; // 10% dari subtotal
}

double calculateTotal(double subtotal, double pb1) {
  return subtotal + pb1;
}

Widget _buildDeliveryOption(String title, String duration, String description,
    String price, bool showInfo) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(
          color: title == 'Standar' ? Colors.green : Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    const Text('•'),
                    const SizedBox(width: 8),
                    Text(duration),
                    if (showInfo) const SizedBox(width: 8),
                    if (showInfo)
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.grey),
                  ],
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(description,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget _buildScheduleOption() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[300]!),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Text('Pesan untuk nanti',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}

Widget _buildDonutsTab(MenuProvider menuProvider) {
  return Column(
    children: menuProvider.menuData.map((item) {
      return _buildDonutItem(
        item['nama'],
        item['gambar'],
        double.parse(item['harga']),
        item['selected_variant'],
      );
    }).toList(),
  );
}

Widget _buildDonutItem(
    String name, String imagePath, double price, String selectedVariant) {
  return ListTile(
    leading: Image.network(
      imagePath,
      width: 50,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    ),
    title: Text(name),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rp$price'),
        if (selectedVariant.isNotEmpty)
          Text('Variant: $selectedVariant',
              style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  );
}

Widget _buildDetailRow(
    {required Widget leading,
    required String title,
    required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap, // Menangani aksi tap untuk navigasi
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    ),
  );
}
