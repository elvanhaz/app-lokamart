import 'dart:async';
import 'dart:convert'; // For parsing JSON
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For using SharedPreferences

class VarianEditPage extends StatefulWidget {
  const VarianEditPage({super.key});

  @override
  _VarianScreenState createState() => _VarianScreenState();
}

class _VarianScreenState extends State<VarianEditPage> {
  int quantityCheese = 1;
  // Tambahkan variabel untuk menyimpan id dari keranjang
  int? cartId;

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
  String? varian;

  bool isAnimationStarted = false; // To ensure animation runs only once
  double pricePerItem = 0; // fetched price from API
  double selectedVariantsPrice =
      0; // Untuk menyimpan total harga varian yang dipilih
  String? selectedVariantCode; // Untuk menyimpan kode varian yang dipilih
  bool _isMounted = false;
  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && id == null) {
      setState(() {
        id = args['id'];
        varian = args['varian'].toString();
        quantityCheese = (args['quantity'] is String)
            ? int.tryParse(args['quantity']) ?? 1
            : args['quantity'] ?? 1;
        selectedVariantCode = args['selected_variant']
            ?.toString(); // Ambil varian yang sudah dipilih
        _menuData = fetchMenuData(id!);

        // Cek jika ada varian yang cocok dengan selectedVariantCode dan tambahkan ke selectedVariants
        if (selectedVariantCode != null) {
          selectedVariants = [
            {
              'kode': selectedVariantCode,
              // Tambahkan data lain terkait varian jika diperlukan
            }
          ];
        }
      });
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

  Future<Map<String, dynamic>?> fetchMenuData(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        return null;
      }

      final String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/$id';
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
          Map<String, dynamic> itemMenuData = data['data']['data_item_menu'];

          // Ambil id dari data_item_menu
          String productId = itemMenuData['id'].toString();

          List<Map<String, dynamic>> varianList = [];
          if (itemMenuData.containsKey('data_varian')) {
            for (var varian in itemMenuData['data_varian']) {
              varianList.add({
                'id': varian['id'].toString(),
                'kode': varian['kode'].toString(),
                'nama': varian['nama'].toString(),
                'harga': varian['harga'].toString(),
                'alt_harga': varian['alt_harga'].toString(),
                'isAddedToCart':
                    varian['kode'].toString() == data['data']['kode_varian'],
              });
            }
          }

          double pricePerItem =
              double.tryParse(itemMenuData['harga'].toString()) ?? 0;

          cartId = data['data']['id'];

          if (mounted) {
            setState(() {
              this.pricePerItem = pricePerItem;
              quantityCheese = data['data']['qty'] ?? 1;
              selectedVariantCode = data['data']['kode_varian'] ?? '';

              // Inisialisasi selectedVariantsPrice
              for (var varian in varianList) {
                if (varian['kode'] == selectedVariantCode) {
                  selectedVariantsPrice = double.tryParse(varian['harga']) ?? 0;
                  break;
                }
              }
              // Update total harga
              updateTotalHarga();
            });
          }

          // Kembalikan productId bersama data lainnya
          return {
            'id': data['data']['id'].toString(),
            'productId': productId, // Tambahkan productId ke hasil
            'gambar': itemMenuData['gambar'].toString(),
            'nama': itemMenuData['nama'].toString(),
            'harga': itemMenuData['harga'].toString(),
            'alt_harga': itemMenuData['alt_harga'].toString(),
            'varian': varianList,
            'ketersediaan': itemMenuData['ketersediaan'].toString(),
            'isAddedToCart': data['data']['isAddedToCart'] ?? false,
            'isFavorite': data['data']['isFavorite'] ?? false,
            'quantity': data['data']['qty'] ?? 0,
            'selected_variant': data['data']['kode_varian'] ?? '',
            'price_per_item': pricePerItem,
            'subtotal': data['data']['subtotal'],
            'alt_subtotal': data['data']['alt_subtotal'],
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

  void addToCart(String id, int quantity,
      List<Map<String, dynamic>> selectedVariants) async {
    if (!mounted) return;

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

      // Ambil productId dari fetchMenuData
      Map<String, dynamic>? menuData = await fetchMenuData(id);
      if (menuData == null || !menuData.containsKey('productId')) {
        print('Gagal mendapatkan productId.');
        return;
      }

      String productId = menuData['productId'];
      String variantCode = selectedVariants
          .map((variant) => variant['kode'].toString())
          .join(',');

      const String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/perbarui';

      print('Cart ID yang akan digunakan: $cartId');

      // Mencetak data body sebelum dikirim
      final Map<String, dynamic> body = {
        'id': cartId,
        'id_item_menu': productId,
        'kode_varian': variantCode,
        'qty': quantity,
      };
      print('Body yang akan dikirim: $body');

      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          setState(() {
            jumlahKeranjang += quantity;
            cartId = responseData['id'] ?? cartId;

            // Perbarui data menu setelah pembaruan berhasil
            _menuData = fetchMenuData(productId);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan. Silakan coba lagi.')),
      );
    }
  }

  void updateTotalHarga() {
    setState(() {
      totalHarga = (pricePerItem + selectedVariantsPrice) * quantityCheese;
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _menuData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No item found.'));
          } else {
            final menuData = snapshot.data!;
            selectedVariantCode = menuData['selected_variant'];
            if (!isAnimationStarted) {
              startTypingAnimation(menuData['nama']);
            }
            return Stack(
              children: [
                // AppBar & Background Box
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: backgroundGradients[
                          (_currentPage.round()) % backgroundGradients.length],
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
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
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
                  padding: const EdgeInsets.only(left: 5, top: 250),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Jumlah Pesanan',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const WidgetSpan(
                          child: Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Icon(
                              Icons.fire_hydrant,
                              size: 24,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 35, top: 290),
                    child: Column(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.black),
                            onPressed: () {
                              setState(() {
                                quantityCheese++;
                                updateTotalHarga();
                              });
                            }),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: quantityCheese
                                    .toString(), // Display quantity
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.black),
                          onPressed: () {
                            setState(() {
                              if (quantityCheese > 0) {
                                quantityCheese--;
                                updateTotalHarga();
                              }
                              if (quantityCheese == 0) {
                                Map<String, dynamic>? selectedVariant;
                                double selectedVariantPrice = 0;
                                for (var varian in menuData['varian']) {
                                  if (varian['isAddedToCart'] ?? false) {
                                    selectedVariant = {
                                      'id': varian['id'],
                                      'kode': varian['kode'],
                                    };
                                    selectedVariantPrice =
                                        double.tryParse(varian['harga']) ?? 0;
                                    break;
                                  }
                                }

                                // Periksa apakah ada varian yang dipilih
                                if (selectedVariant == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Silakan pilih setidaknya satu varian sebelum menambahkan ke keranjang')),
                                  );
                                  return;
                                }

                                // Tambahkan ke keranjang
                                addToCart(
                                    id!, quantityCheese, [selectedVariant]);
                                // Cetak cartId sebelum menambahkan ke keranjang
                                print(
                                    'Cart ID yang akan digunakan: $selectedVariant');

                                // Update total harga dan navigasi
                                setState(() {
                                  totalHarga = (pricePerItem * quantityCheese) +
                                      (selectedVariantPrice * quantityCheese);
                                });

                                Navigator.pop(context,
                                    quantityCheese); // Tutup halaman setelah menambahkan
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/kategory',
                                    (Route<dynamic> route) => false);
                              }
                            });
                          },
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 150.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
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
                                    'Rp. ${menuData['alt_harga'].toString()}', // Fetched price
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
                              'Pilih Varian Menu',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: menuData['varian'].length,
                          itemBuilder: (context, index) {
                            var varian = menuData['varian'][index];
                            return CheckboxListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      varian['nama'].toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Rp${varian['harga']}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              value: varian['isAddedToCart'] ?? false,
                              onChanged: (bool? value) {
                                setState(() {
                                  // Reset semua varian
                                  for (var item in menuData['varian']) {
                                    item['isAddedToCart'] = false;
                                  }
                                  // Tandai varian yang baru dipilih
                                  varian['isAddedToCart'] = value ?? false;

                                  // Update harga varian dan total harga
                                  if (varian['isAddedToCart'] == true) {
                                    selectedVariantCode =
                                        varian['kode'].toString();
                                    selectedVariantsPrice =
                                        double.tryParse(varian['harga']) ?? 0;
                                  } else {
                                    selectedVariantCode = null;
                                    selectedVariantsPrice = 0;
                                  }

                                  // Update total harga
                                  updateTotalHarga();
                                });
                              },
                            );
                          },
                        ),
                      ),
                      BottomAppBar(
                        color: Colors.white,
                        child: Container(
                          height: 200,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[200]!, Colors.red[300]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  const Icon(Icons.shopping_basket,
                                      size: 30, color: Colors.white),
                                  Positioned(
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.blueGrey,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        quantityCheese
                                            .toString(), // Display quantity.toString(),  // Jumlah barang dinamis
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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
                                  Text(
                                    formatRupiah(
                                        totalHarga), // Menggunakan fungsi formatRupiah
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  if (!mounted) return;

                                  // Ambil varian yang dipilih
                                  Map<String, dynamic>? selectedVariant;
                                  double selectedVariantPrice = 0;
                                  for (var varian in menuData['varian']) {
                                    if (varian['isAddedToCart'] ?? false) {
                                      selectedVariant = {
                                        'id': varian['id'],
                                        'kode': varian['kode'],
                                      };
                                      selectedVariantPrice =
                                          double.tryParse(varian['harga']) ?? 0;
                                      break;
                                    }
                                  }

                                  // Periksa apakah ada varian yang dipilih
                                  if (selectedVariant == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Silakan pilih setidaknya satu varian sebelum menambahkan ke keranjang')),
                                    );
                                    return;
                                  }

                                  // Tambahkan ke keranjang
                                  addToCart(
                                      id!, quantityCheese, [selectedVariant]);
                                  // Cetak cartId sebelum menambahkan ke keranjang
                                  print('Cart ID yang akan digunakan: $cartId');

                                  // Update total harga dan navigasi
                                  setState(() {
                                    totalHarga = (pricePerItem *
                                            quantityCheese) +
                                        (selectedVariantPrice * quantityCheese);
                                  });

                                  Navigator.pop(context,
                                      quantityCheese); // Tutup halaman setelah menambahkan
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/kategory',
                                      (Route<dynamic> route) => false);
                                },
                                child: const Text('Tambahkan Keranjang',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildMenuItem(
      String optionName,
      String price,
      String variantCode, // Terima variantCode sebagai parameter
      VoidCallback onCheckboxChanged) {
    bool isSelected = selectedVariantCode ==
        variantCode; // Cek apakah ini varian yang dipilih
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
                        selectedVariantCode = variantCode;

                        selectedVariantsPrice = double.tryParse(price) ?? 0;
                        totalHarga = (pricePerItem * quantityCheese) +
                            (selectedVariantsPrice * quantityCheese);

                        selectedVariants.clear();
                        selectedVariants.add({
                          'kode': variantCode,
                          'harga': price,
                        });
                      } else {
                        selectedVariantCode = null;
                        selectedVariantsPrice = 0;
                        totalHarga = pricePerItem * quantityCheese;
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
