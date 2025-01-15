import 'dart:async';
import 'dart:convert'; // For parsing JSON
import 'package:loka/providers/OutletProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For using SharedPreferences

class VarianPage extends StatefulWidget {
  const VarianPage({super.key});

  @override
  _VarianScreenState createState() => _VarianScreenState();
}

class _VarianScreenState extends State<VarianPage> {
  int quantityCheese = 1;
  bool addBacon = false;
  bool addCheese = false;
  bool addCheeseSauce = false;
  final double _currentPage = 0;
  double totalHarga = 0;
  String currentText = '';
  int currentCharIndex = 0;
  double opacity = 0;
  Timer? _typingTimer;
  Future<Map<String, dynamic>?>? _menuData;
  int jumlahKeranjang = 0; // Inisialisasi jumlah keranjang
  List<Map<String, dynamic>> selectedVariants =
      []; // Inisialisasi di dalam State
  String? id;
  int? varian;
  bool isAnimationStarted = false; // To ensure animation runs only once
  double pricePerItem = 0; // fetched price from API
  double selectedVariantsPrice =
      0; // Untuk menyimpan total harga varian yang dipilih
  String? selectedVariantCode; // Untuk menyimpan kode varian yang dipilih
  bool _isMounted = false;
  String? outletId;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);
    if (outletProvider.outletId != null &&
        outletProvider.outletId != outletId) {
      outletId = outletProvider.outletId;
      if (_menuData == null) {
        final args =
            ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        if (args != null && id == null) {
          id = args['id'];
          varian = args['varian'];
          _menuData = fetchMenuData(id!);
        }

        print('API Response: $outletId');

        _menuData?.then((data) {
          if (data != null && _isMounted) {
            setState(() {
              pricePerItem = double.tryParse(data['harga']) ?? 0;
              totalHarga = (pricePerItem * quantityCheese) +
                  (selectedVariantsPrice * quantityCheese);
            });
          }
        });
      }
    }
  }

  Future<Map<String, dynamic>?> fetchMenuData(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }
      final String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu/$id?id_outlet=$outletId';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey('data')) {
          // Proses data varian
          List<Map<String, dynamic>> varianList = [];
          if (data['data'].containsKey('data_varian')) {
            for (var varian in data['data']['data_varian']) {
              varianList.add({
                'id': varian['id'].toString(),
                'kode': varian['kode'].toString(),
                'nama': varian['nama'].toString(),
                'harga': varian['harga'].toString(),
                'alt_harga': varian['alt_harga'].toString(),
                'isAddedToCart':
                    false, // Inisialisasi status isAddedToCart untuk setiap varian
              });
            }
          }
          return {
            'id': data['data']['id'].toString(),
            'gambar': data['data']['gambar'].toString(),
            'nama': data['data']['nama'].toString(),
            'harga': data['data']['harga'].toString(),
            'alt_harga': data['data']['alt_harga'].toString(),
            'varian': varianList, // Kembalikan data varian
            'ketersediaan': data['data']['ketersediaan'].toString(),
            'deskripsi': data['data']['deskripsi'].toString(),
            'isAddedToCart': data['data']['isAddedToCart'] ?? false,
            'isFavorite': data['data']['isFavorite'] ?? false,
            'quantity': data['data']['quantity'] ?? 0,
          };
        } else {
          throw 'Data tidak valid';
        }
      } else {
        throw 'Gagal memuat item. Status code: ${response.statusCode}, Body: ${response.body}';
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return null;
    }
  }

  void addToCart(String productId, int quantity,
      List<Map<String, dynamic>> selectedVariants) async {
    if (!mounted) return; // Periksa apakah widget masih terpasang
    if (selectedVariants.isEmpty) {
      print('Tidak ada varian yang dipilih.');
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }
      String variantCode = selectedVariants
          .map((variant) => variant['kode'].toString())
          .join(',');
      const String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/simpan-atau-perbarui';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id_item_menu': productId,
          'kode_varian': variantCode,
          'qty': quantity,
        }),
      );
      if (!mounted) return; // Periksa lagi setelah operasi asinkron
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          setState(() {
            if (mounted) {
              // Periksa sebelum memperbarui state
              jumlahKeranjang += quantity;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['pesan'])),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal menambahkan ke keranjang: ${responseData['pesan']}')),
          );
        }
      } else {
        print(
            'Gagal menambahkan ke keranjang. Status: ${response.statusCode}, Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Gagal menambahkan ke keranjang. Silakan coba lagi.')),
        );
      }
    } catch (e) {
      print('Terjadi kesalahan saat menambahkan ke keranjang: $e');
      if (mounted) {
        // Periksa sebelum menampilkan Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Terjadi kesalahan. Silakan coba lagi.')),
        );
      }
    }
  }

  bool isOrderCompleted() {
    // Implement your logic here to determine if the order is completed
    // For example, you might check if a certain condition is met
    // Return true if the order is completed, false otherwise
    return false; // Placeholder return value
  }

  void startTypingAnimation(String nama) {
    if (isAnimationStarted || !_isMounted) return;
    isAnimationStarted = true;
    final String fullText = ' $nama';
    currentCharIndex = 0;
    currentText = '';
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentCharIndex < fullText.length && _isMounted) {
        setState(() {
          currentText += fullText[currentCharIndex];
          currentCharIndex++;
          opacity = 1.0;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<List<Color>> backgroundGradients = [
      [Colors.red[100]!, Colors.red[300]!],
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
    return WillPopScope(
      onWillPop: () async {
        // Cek apakah proses telah selesai
        if (isOrderCompleted()) {
          // Jika selesai, arahkan ke halaman kategori
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/kategory', (Route<dynamic> route) => false);
          return false; // Mencegah default back button behavior
        }
        // Jika belum selesai, biarkan default back button behavior
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _menuData, // Data menu dari fetchMenuData
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No item found.'));
            } else {
              final String nama = snapshot.data!['nama'];
              startTypingAnimation(
                  nama); // Panggil animasi setelah data didapatkan
              final menuData = snapshot.data!;
              return Stack(
                children: [
                  // AppBar & Background Box
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: backgroundGradients[(_currentPage.round()) %
                            backgroundGradients.length],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, top: 80),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: currentText,
                            style: GoogleFonts.poppins(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (currentCharIndex == currentText.length)
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Icon(
                                  Icons.fastfood,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 00.0),
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 300,
                                  height: 300,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(menuData['gambar']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  left: -30,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(150),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'Rp. ${menuData['alt_harga']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Deskripsi Produk',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${menuData['deskripsi']}',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildMenuItem(String optionName, String price, String variantCode,
      VoidCallback onCheckboxChanged) {
    bool isSelected = selectedVariantCode == variantCode;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 0),
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(optionName, style: GoogleFonts.poppins(fontSize: 16)),
            ),
            Row(
              children: [
                Text(
                  'Rp. ${price.toString()}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                const SizedBox(width: 10),
                Checkbox(
                  value: isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        // Bersihkan daftar varian yang dipilih sebelumnya
                        selectedVariants.clear();

                        // Tetapkan varian yang dipilih saat ini
                        selectedVariantCode = variantCode;
                        selectedVariantsPrice = double.tryParse(price) ?? 0;

                        // Hitung ulang total harga
                        totalHarga = (pricePerItem * quantityCheese) +
                            (selectedVariantsPrice * quantityCheese);

                        // Tambahkan varian yang dipilih ke daftar selectedVariants
                        selectedVariants.add({
                          'kode': variantCode,
                          'harga': price,
                        });
                      } else {
                        selectedVariantCode = null;
                        selectedVariantsPrice = 0;
                        totalHarga = pricePerItem * quantityCheese;

                        // Kosongkan varian yang dipilih
                        selectedVariants.clear();
                      }
                    });
                    onCheckboxChanged();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
