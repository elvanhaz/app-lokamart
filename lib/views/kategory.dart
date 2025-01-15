import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:loka/providers/KategoryProvider.dart';
import 'package:loka/providers/LocationProvider.dart';
import 'package:loka/providers/OutletProvider.dart';
import 'package:loka/search_bar.dart';
import 'package:loka/views/search.dart';
import 'package:loka/views/varianedit.dart';
import 'package:flutter/material.dart';
import 'package:loka/checkout.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:geolocator/geolocator.dart';

class KategoryPage extends StatefulWidget {
  const KategoryPage({super.key});

  @override
  _KategoryState createState() => _KategoryState();
}

class _KategoryState extends State<KategoryPage> {
  final PageController _pageController = PageController();
  late Timer _timer;
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _menuKey = GlobalKey(); // Key for the 'Pilih Menu' section
  bool _showPersistentHeader = false;
  bool isLoading = false; // Atur sesuai dengan status loading
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> cartItems = [];

  bool isAddedToCart = false; // Track if the item is added to cart
  int quantity = 0; // Track the quantity of the item
  int itemCount = 0;
  double totalPrice = 0.0;
  bool isFabVisible = false; // Update visibility of FAB based on cart state
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> categories = [];
  bool canPop = true; // Kondisi untuk mengontrol apakah back diperbolehkan
  bool isCategoryLoading = true;
  String selectedCategory = '0'; // Default category ID for "Semua"
  bool isLoadingQty = true; // State for showing the loading indicator
  String? outletId;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializePrefs(); // Inisialisasi prefs sekali
    Provider.of<LocationProvider>(context, listen: false).getCurrentLocation();
    Provider.of<OutletProvider>(context, listen: false).loadOutletId();

    _initializeData(); // Inisialisasi data pada startup

    // Timer untuk animasi page view
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.page == 2) {
        _pageController.animateToPage(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    });

    // Listener untuk persistent header pada scroll
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showPersistentHeader) {
        setState(() {
          _showPersistentHeader = true;
        });
      } else if (_scrollController.offset <= 200 && _showPersistentHeader) {
        setState(() {
          _showPersistentHeader = false;
        });
      }
    });
  }

  void _showBarcodeDialog(BuildContext context) {
    final randomBarcode = _generateRandomBarcode();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Kode Barcode",
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    randomBarcode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: QrImageView(
                      data: randomBarcode,
                      version: QrVersions.auto,
                      gapless: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Tutup"),
              ),
            ),
          ],
        );
      },
    );
  }

  String _generateRandomBarcode() {
    const characters = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          10, (_) => characters.codeUnitAt(random.nextInt(characters.length))),
    );
  }

  void _showCategoryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryModal(),
    );
  }

  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        isLoading = true; // Start loading indicator
      });

      await Future.wait([
        _fetchItemsFromApi(),
        _fetchCartData(), // Panggil data keranjang bersamaan dengan fetch item
        _fetchCategoriesFromApi(),
        _loadCartFromSharedPreferences(),
      ]);

      if (mounted) {
        _syncCartWithItems(); // Sync cart data dengan items setelah data diambil
        setState(() {
          isLoadingQty = false; // Stop loading indicator for qty
          isLoading = false; // Stop global loading
        });
        loadFavorites(); // Load favorites setelah semua data selesai
        _loadCartFromSharedPreferences();
      }
    } catch (e) {
      print('Error initializing data: $e');
      setState(() {
        isLoading = false; // Stop loading jika ada error
      });
    }
  }

  Future<void> _loadCartFromSharedPreferences() async {
    try {
      await _fetchCartData();
    } catch (e) {
      print('Error loading cart data: $e');
      // Handle error, mungkin menampilkan pesan error ke user
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);

    if (outletProvider.outletId != null &&
        outletProvider.outletId != outletId) {
      outletId = outletProvider.outletId;

      // Panggil nama outlet berdasarkan outletId
      outletProvider.getOutletNameById().then((outletName) {
        if (outletName != null) {
          print("Nama Outlet: $outletName");
        } else {
          print("Nama outlet tidak ditemukan.");
        }
      });

      // Ketika outlet ID berubah, muat ulang data keranjang
      _loadCartFromSharedPreferences().then((_) {
        // Setelah selesai, sinkronkan kembali data keranjang dengan item
        _syncCartWithItems();
      }).catchError((error) {
        print('Error loading cart after outlet change: $error');
      });
    }
  }

  void _syncCartWithItems() {
    if (cartItems.isNotEmpty) {
      setState(() {
        for (var item in items) {
          var cartItem = cartItems.firstWhere(
            (cart) => cart['id_item_menu'] == item['id'],
            orElse: () => {},
          );
          if (cartItem.isNotEmpty) {
            item['quantity'] = int.tryParse(cartItem['qty']) ?? 0;
            item['isAddedToCart'] = true;
          } else {
            item['quantity'] = 0;
            item['isAddedToCart'] = false;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchItemDetails(String id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return {};
      }

      final String apiUrl =
          'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu/$id';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Debug print
        print('API Response: $data');

        Map<String, dynamic> itemData = data['data'] ?? {};

        List<dynamic> cartData = itemData['data_keranjang'] ?? [];
        List<dynamic> variantData = itemData['data_varian'] ?? [];

        // Process item data
        Map<String, dynamic> processedItem = {
          'id': itemData['id'].toString(),
          'gambar': itemData['gambar'].toString(),
          'nama': itemData['nama'].toString(),
          'harga': itemData['harga'].toString(),
          'alt_harga': itemData['alt_harga'].toString(),
          'varian': itemData['varian'].toString(),
          'ketersediaan': itemData['ketersediaan'].toString(),
          'isAddedToCart': itemData['isAddedToCart'] ?? false,
          'isFavorite': itemData['isFavorite'] ?? false,
          'quantity': itemData['quantity'] ?? 0,
        };

        // Process cart data
        List<Map<String, dynamic>> processedCartItems = cartData
            .map((cartItem) => {
                  'id': cartItem['id'].toString(),
                  'id_item_menu': cartItem['id_item_menu'].toString(),
                  'kode_varian': cartItem['kode_varian'].toString(),
                  'qty': cartItem['qty'].toString(),
                  'subtotal': cartItem['subtotal'].toString(),
                  'alt_subtotal': cartItem['alt_subtotal'].toString(),
                  'data_item_menu': {
                    'id': cartItem['data_item_menu']['id'].toString(),
                    'gambar': cartItem['data_item_menu']['gambar'].toString(),
                    'nama': cartItem['data_item_menu']['nama'].toString(),
                  },
                })
            .toList();

        // Process variant data
        List<Map<String, dynamic>> processedVariants = variantData
            .map((variant) => {
                  'id': variant['id'].toString(),
                  'kode': variant['kode'].toString(),
                  'nama': variant['nama'].toString(),
                  'harga': variant['harga'].toString(),
                  'alt_harga': variant['alt_harga'].toString(),
                })
            .toList();
        // Debug print
        print('Processed Item: $processedItem');
        print('Processed Cart Items: $processedCartItems');
        print('Processed Variants: $processedVariants');

        return {
          'item': processedItem,
          'cartItems': processedCartItems,
          'variants': processedVariants,
        };
      } else {
        print(
            'Gagal memuat detail item. Status code: ${response.statusCode}, Body: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return {};
    }
  }

  Future<void> updateCartSummary() async {
    setState(() {
      isFabVisible = itemCount > 0;
    });
    _fetchCartData(); // Lakukan fetch data keranjang jika diperlukan
  }

  Future<void> toggleFavorite(String itemId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isFavorite =
          prefs.getBool(itemId) ?? false; // Ambil status favorit saat ini
      String? token = prefs
          .getString('sanctumToken'); // Sesuaikan kunci token sesuai kebutuhan

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      // Ubah status favorit dan simpan kembali ke SharedPreferences
      isFavorite = !isFavorite;
      await prefs.setBool(itemId, isFavorite);

      // Perbarui status favorit pada UI
      setState(() {
        final itemIndex = items.indexWhere((item) => item['id'] == itemId);
        if (itemIndex != -1) {
          items[itemIndex]['isFavorite'] = isFavorite;
        }
      });

      // Simpan atau hapus favorit di server
      const url =
          'https://loka-mart.demoaplikasi.web.id/api/v1/favorit/simpan-atau-hapus';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // pastikan token sudah diambil
          'Accept': 'application/json',
        },
        body: {
          'id_item_menu': itemId,
        },
      );

      if (response.statusCode != 200) {
        print('Gagal mengubah status favorit di server');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var item in items) {
        item['isFavorite'] = prefs.getBool(item['id']) ?? false;
      }
    });
  }

  Future<void> addToCart(String itemId, int quantity) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });
    try {
      final itemIndex = items.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        items[itemIndex]['isAddedToCart'] = true;
        items[itemIndex]['quantity'] = quantity;
        await prefs.setInt('cart_$itemId', quantity);
        bool success = await _updateCartToServer(itemId, quantity);
        if (success) {
          setState(() {
            itemCount += quantity;
            totalPrice += double.parse(items[itemIndex]['harga']) * quantity;
          });
          await updateCartSummary();
        }
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void incrementQuantity(String itemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true; // Start shimmer effect
    });

    try {
      final itemIndex = items.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        // Increment kuantitas di UI langsung
        items[itemIndex]['quantity']++;
        await prefs.setInt('cart_$itemId', items[itemIndex]['quantity']);

        // Update item count dan total price di UI tanpa menunggu respons server
        setState(() {
          itemCount += 1;
          totalPrice += double.parse(items[itemIndex]['harga']);
          isFabVisible = itemCount > 0;
        });

        // Kirim permintaan update ke server di background
        await _updateCartToServer(itemId, items[itemIndex]['quantity']);
      }
    } finally {
      setState(() {
        isLoading = false; // Stop shimmer effect
      });
    }
  }

  void decrementQuantity(String itemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true; // Start shimmer effect
    });

    try {
      final itemIndex = items.indexWhere((item) => item['id'] == itemId);
      if (itemIndex != -1) {
        if (items[itemIndex]['quantity'] > 1) {
          // Decrement kuantitas
          items[itemIndex]['quantity']--;

          // Simpan di SharedPreferences
          prefs.setInt('cart_$itemId', items[itemIndex]['quantity']);

          // Update keranjang di server
          await _updateCartToServer(itemId, items[itemIndex]['quantity']);
        } else {
          // Hapus item dari keranjang jika kuantitas 0
          items[itemIndex]['isAddedToCart'] = false;
          items[itemIndex]['quantity'] = 0;

          // Hapus dari SharedPreferences
          prefs.remove('cart_$itemId');

          // Hapus dari server
          await _removeFromCartOnServer(itemId);
        }
        updateCartSummary();
      }
    } finally {
      setState(() {
        isLoading = false; // Stop shimmer effect
      });
    }
  }

  Future<bool> _updateCartToServer(String itemId, int quantity) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return false;
      }

      // Definisi body
      final body = {
        'id_item_menu': itemId,
        'qty': quantity.toString(),
      };

      // Cetak isi body sebelum request
      print('Body yang akan dikirim ke server: $body');

      // Panggil API untuk memperbarui jumlah item dalam keranjang
      final response = await http.post(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/simpan-atau-perbarui'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Kuantitas berhasil diperbarui');
        return true;
      } else {
        print(
            'Gagal memperbarui kuantitas di server. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<void> _removeFromCartOnServer(String itemId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      // Panggil API untuk menghapus item dari keranjang
      final response = await http.delete(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang/hapus'), // Sesuaikan dengan endpoint API penghapusan item
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'id_item_menu': itemId,
        },
      );
// Hapus nilai qty untuk item berdasarkan itemId
      await prefs.remove('cart_$itemId');
      if (response.statusCode == 200) {
        print('Item berhasil dihapus dari keranjang $itemId');
      } else {
        print(
            'Gagal menghapus item dari keranjang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> _fetchItemsFromApi() async {
    try {
      // Ambil token dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs
          .getString('sanctumToken'); // Ganti 'token' dengan kunci yang sesuai

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final outletProvider =
          Provider.of<OutletProvider>(context, listen: false);
      if (outletProvider.outletId == null) {
        print('Outlet ID tidak tersedia');
        return;
      }

      final String apiUrl = selectedCategory == '0'
          ? 'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu?id_outlet=${outletProvider.outletId}'
          : 'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu?id_outlet=${outletProvider.outletId}&id_kategori=$selectedCategory';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Gunakan token yang diambil
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Merge fetched items with cart data
        Map<String, dynamic> cartMap = {};
        for (var cartItem in cartItems) {
          cartMap[cartItem['id_item_menu']] = cartItem['qty'];
        }
        // Ambil data item-menu dan keranjang dari response
        List<dynamic> itemsData = data['data'] ?? [];
        List<dynamic> cartData = data['data_keranjang'] ?? [];

        setState(() {
          // Map dari item-menu
          items = List<Map<String, dynamic>>.from(itemsData
              .map((item) => {
                    'id': item['id'].toString(),
                    'gambar': item['gambar'].toString(),
                    'nama': item['nama'].toString(),
                    'harga': item['harga'].toString(),
                    'alt_harga': item['alt_harga'].toString(),
                    'varian': item['varian']
                        .toString(), // Assuming varian is category id
                    'ketersediaan': item['ketersediaan'].toString(),
                    'isAddedToCart': item['isAddedToCart'] ?? false,
                    'isFavorite': item['isFavorite'] ?? false,
                    'quantity': item['quantity'] ?? 0,
                  })
              .toList());

          // Map dari data keranjang
          cartItems = List<Map<String, dynamic>>.from(cartData
              .map((cartItem) => {
                    'id': cartItem['id'].toString(),
                    'id_item_menu': cartItem['id_item_menu'].toString(),
                    'kode_varian': cartItem['kode_varian'].toString(),
                    'qty': cartItem['qty'].toString(),
                    'subtotal': cartItem['subtotal'].toString(),
                    'alt_subtotal': cartItem['alt_subtotal'].toString(),
                    'data_item_menu': {
                      'id': cartItem['data_item_menu']['id'].toString(),
                      'gambar': cartItem['data_item_menu']['gambar'].toString(),
                      'nama': cartItem['data_item_menu']['nama'].toString(),
                    },
                  })
              .toList());

          // Filtered items initially set to all items
          filteredItems = items;
        });
      } else {
        print(
            'Gagal memuat item. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> _fetchCartData() async {
    setState(() {
      isLoadingQty = true; // Start loading before fetching cart data
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('sanctumToken');
      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final outletProvider =
          Provider.of<OutletProvider>(context, listen: false);
      if (outletProvider.outletId == null) {
        print('Outlet ID tidak tersedia');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/keranjang?id_outlet=${outletProvider.outletId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        // Menghitung jumlah total qty dari item dengan ID yang sama
        setState(() {
          itemCount = data['data'].fold<int>(0, (int sum, dynamic item) {
            int qty = item['qty'] is String
                ? int.tryParse(item['qty']) ?? 0
                : item['qty'];
            return sum + qty;
          });

          // Mengelompokkan item berdasarkan id_item_menu
          Map<String, int> itemQtyMap = {};
          data['data'].forEach((item) {
            String itemId = item['id_item_menu'].toString();
            int qty = item['qty'] is String
                ? int.tryParse(item['qty']) ?? 0
                : item['qty'];
            // Set isLoadingQty to false once qty data is loaded
            isLoadingQty = false;

            if (itemQtyMap.containsKey(itemId)) {
              itemQtyMap[itemId] = itemQtyMap[itemId]! + qty;
            } else {
              itemQtyMap[itemId] = qty;
            }
          });

          // Total harga keranjang
          totalPrice =
              data['data'].fold<double>(0.0, (double sum, dynamic item) {
            double subtotal = item['subtotal'] is num
                ? (item['subtotal'] as num).toDouble()
                : 0.0;
            return sum + subtotal;
          });

          // Update tampilan UI dengan itemQtyMap
          for (var item in items) {
            var cartQty = itemQtyMap[item['id']] ?? 0;
            item['isAddedToCart'] = cartQty > 0;
            item['quantity'] = cartQty;
          }

          isFabVisible =
              itemCount > 0; // Tampilkan FAB jika ada item di keranjang
        });
      } else {
        print(
            'Gagal memuat data keranjang. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  Future<void> _fetchCategoriesFromApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs
          .getString('sanctumToken'); // Mengambil token dari SharedPreferences

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final outletProvider =
          Provider.of<OutletProvider>(context, listen: false);
      if (outletProvider.outletId == null) {
        print('Outlet ID tidak tersedia');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/kategori?table=item_menu&id_outlet=${outletProvider.outletId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (mounted) {
          setState(() {
            categories = [
              {
                'id': '0',
                'nama': 'Semua'
              }, // Tambahkan kategori default "Semua"
              ...List<Map<String, dynamic>>.from(data['data']
                  .map((category) => {
                        'id': category['id'].toString(),
                        'nama': category['nama'].toString(),
                      })
                  .toList())
            ];
            isCategoryLoading = false;
          });
        }

        // Panggil _loadCartFromSharedPreferences setelah kategori berhasil di-load
        await _loadCartFromSharedPreferences();
      } else {
        print(
            'Failed to load categories. Status code: ${response.statusCode}, Body: ${response.body}');
        if (mounted) {
          setState(() {
            isCategoryLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        setState(() {
          isCategoryLoading = false;
        });
      }
    }
  }

  void _filterItems(String categoryId) {
    setState(() {
      // Filter berdasarkan kategori atau tampilkan semua item jika "Semua" dipilih
      if (categoryId == '0') {
        // "Semua" kategori
        filteredItems = items;
      } else {
        filteredItems = items
            .where((item) =>
                item['category_id'] == categoryId ||
                cartItems.contains(
                    item)) // Filter item yang termasuk dalam kategori atau yang ada di keranjang
            .toList();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToMenuSection();
    });
  }

  void _scrollToMenuSection() {
    if (_menuKey.currentContext != null) {
      RenderBox menuBox =
          _menuKey.currentContext!.findRenderObject() as RenderBox;
      double position = menuBox.localToGlobal(Offset.zero).dy +
          _scrollController.position.pixels;

      _scrollController.animateTo(
        position - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.white : Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildMenuIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCategoryModal(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(
            4,
            (index) => Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuCategoryItem(String categoryId, String categoryName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = categoryId;
        });
        _filterItems(
            categoryId); // Filter items berdasarkan kategori yang dipilih
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color:
              selectedCategory == categoryId ? Colors.orange : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          categoryName,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: selectedCategory == categoryId ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  void _showLocationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *
              0.9, // Atur tinggi modal agar hampir full layar
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  Text(
                    'Pilih Lokasi',
                    style: GoogleFonts.poppins(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari alamat',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          const Icon(Icons.location_on, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          'Lokasimu saat ini',
                          style: GoogleFonts.poppins(
                              color: const Color.fromARGB(162, 0, 0, 0)),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map),
                        label: Text(
                          'Pilih lewat peta',
                          style: GoogleFonts.poppins(
                              color: const Color.fromARGB(162, 0, 0, 0)),
                        ),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Alamat favorit',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: const Color.fromARGB(255, 187, 178, 178)),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.place),
                      title: Text(
                        'qq',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Jl. Raya Taman Pagelaran, Padasuka, Kec. Ciomas, Kabupaten Bogor, Jawa Barat, Indonesia',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                          color: const Color.fromARGB(255, 187, 178, 178)),
                    ),
                    child: const ListTile(
                      leading: Icon(Icons.home),
                      title: Text(
                        'Rumah',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        'Jl. Marjisyah No.109, RT.003/RW.2, Larangan Indah, Kec. Larangan, Kota Tangerang, Banten 15154, Indonesia',
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final outletProvider = Provider.of<OutletProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (canPop) {
          // Jika canPop true, arahkan ke halaman cabang
          Navigator.pushReplacementNamed(context, '/cabang');
        }
        return !canPop; // Prevent pop jika canPop true (handle sendiri navigasinya)
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Image.asset('assets/000.jpg', fit: BoxFit.fill),
                          Image.asset('assets/0000.jpg', fit: BoxFit.fill),
                          Image.asset('assets/00.png', fit: BoxFit.fill),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10.0, // Adjust this value as needed
                      left: 16.0,
                      right: 16.0,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchPage(
                                        refreshCategoryPage: () {
                                          setState(() {
                                            _loadCartFromSharedPreferences()
                                                .then((_) {
                                              // Setelah selesai, sinkronkan kembali data keranjang dengan item
                                              _syncCartWithItems(); // Atau panggil metode lain yang memperbarui state halaman kategori
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const AbsorbPointer(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Lagi mau cari apa?',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.mic, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              automaticallyImplyLeading: false, // Nonaktifkan leading default
              title: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        '/cabang',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white, size: 20.0),
                            const SizedBox(width: 4.0),
                            Text(
                              outletProvider.outletName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/favorite');
                            },
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.local_activity_outlined,
                                color: Colors.red),
                            onPressed: () {
                              Navigator.pushNamed(context, '/statuspesanan');
                            },
                          ),
                        ),
                        const SizedBox(width: 2),
                        Container(
                          width: 20,
                          height: 40,
                          child: PopupMenuButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(
                                    'Profile',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_showPersistentHeader)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 60.0,
                  maxHeight: 60.0,
                  child: AnimatedOpacity(
                    opacity: _showPersistentHeader ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      offset: _showPersistentHeader
                          ? const Offset(0, 0)
                          : const Offset(0, -1),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SearchPage(
                                        refreshCategoryPage: () {
                                          setState(() {
                                            // Muat ulang data atau perbarui state yang diperlukan

                                            // Ketika outlet ID berubah, muat ulang data keranjang
                                            _loadCartFromSharedPreferences()
                                                .then((_) {
                                              // Setelah selesai, sinkronkan kembali data keranjang dengan item
                                              _syncCartWithItems(); // Atau panggil metode lain yang memperbarui state halaman kategori
                                            });
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const AbsorbPointer(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Lagi mau mamam apa?',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Icon(Icons.mic, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 10), // Adjust height as needed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.attach_money,
                        title: "Rp120.000",
                        subtitle: "Saldo Anda",
                        iconColor: Colors.orange,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.card_giftcard,
                        title: "Cek-in!",
                        subtitle: "Klaim 25RB!",
                        iconColor: Colors.amber,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.wallet,
                        title: "Transfer",
                        subtitle: "Gratis",
                        iconColor: Colors.orangeAccent,
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.qr_code,
                        title: "Barcode",
                        subtitle: "",
                        iconColor: Colors.red,
                        onTap: () => _showBarcodeDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                  Container(
                    height: 120, // Adjust the height based on your design needs
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.red, Colors.redAccent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      clipBehavior: Clip
                          .none, // Allows the image to overflow outside the container
                      children: [
                        Positioned(
                          top: -50, // Adjust the offset to move the image up
                          right:
                              -30, // Adjust this value to position the image partially outside the box
                          child: Image.asset(
                            'assets/rokok.png', // Replace with your image asset
                            height: 200, // Adjust the image size
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diskon Hingga 20% off',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Rokok Esse',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Cepat! Waktu Terbatas',
                                      style: GoogleFonts.poppins(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Container(
                  //   padding: EdgeInsets.symmetric(horizontal: 16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       CategoryButton(
                  //         label: 'Driver\nCabang',
                  //         icon: 'assets/gojekk.png',
                  //       ),
                  //       CategoryButton(
                  //         label: 'Cabang\nTerdekat',
                  //         icon: 'assets/maps.png',
                  //       ),
                  //       CategoryButton(
                  //         label: 'Paling\nAndalan',
                  //         icon: 'assets/award1.png',
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Slideshow Menu Bar
                  const SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Menu icon di sebelah kiri
                        _buildMenuIcon(context),

                        const SizedBox(
                            width: 8), // Jarak antara ikon dan filter chip

                        // Filter chip untuk kategori
                        Expanded(
                          child: isCategoryLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: categories.map((category) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedCategory = category['id'];
                                              _fetchItemsFromApi().then((_) {
                                                _scrollToMenuSection();
                                                loadFavorites();
                                                _loadCartFromSharedPreferences();
                                              });
                                            });
                                          },
                                          child: _buildFilterChip(
                                            category['nama'],
                                            isSelected: selectedCategory ==
                                                category['id'],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rekomendasi',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: items.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 3,
                                        itemBuilder: (context, index) =>
                                            Container(
                                          width: 160,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : PageView.builder(
                                      itemCount: (items.length / 2).ceil(),
                                      itemBuilder: (context, pageIndex) {
                                        int firstIndex = pageIndex * 2;
                                        int secondIndex = firstIndex + 1;

                                        return Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: buildCard(
                                                    context, items[firstIndex]),
                                              ),
                                              if (secondIndex < items.length)
                                                const SizedBox(width: 8),
                                              if (secondIndex < items.length)
                                                Expanded(
                                                  child: buildCard(context,
                                                      items[secondIndex]),
                                                ),
                                              if (secondIndex >= items.length)
                                                const Spacer(),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const Divider(),
                            Padding(
                              key:
                                  _menuKey, // Key for scrolling to this section
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0),
                                      child: Text(
                                        'Pilih Apa Yang Kamu Butuh',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 50),
                                    if (filteredItems.isEmpty)
                                      const Center(
                                        child: Text('No items available'),
                                      ),

// Display filtered items if available
                                    if (filteredItems.isNotEmpty)
                                      ...List.generate(
                                          (filteredItems.length / 1).ceil(),
                                          (rowIndex) {
                                        int firstItemIndex = rowIndex * 2;
                                        int secondItemIndex =
                                            firstItemIndex + 1;

                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: firstItemIndex <
                                                      filteredItems.length
                                                  ? Container(
                                                      margin: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: rowIndex <
                                                                (filteredItems.length /
                                                                            2)
                                                                        .ceil() -
                                                                    0
                                                            ? 30.0
                                                            : 30.0,
                                                      ),
                                                      child: buildsCard(
                                                          context,
                                                          filteredItems[
                                                              firstItemIndex]),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: secondItemIndex <
                                                      filteredItems.length
                                                  ? Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        top: 0.0,
                                                      ),
                                                      child: buildsCard(
                                                          context,
                                                          filteredItems[
                                                              secondItemIndex]),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ],
                                        );
                                      })
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  // Wrap the Stack widget with SliverToBoxAdapter
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: itemCount > 0
            ? BottomAppBar(
                color: Colors.white,
                child: Container(
                  height: 200,
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
                                    style: GoogleFonts.poppins(
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
                          Text(
                            'Total',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Shimmer.fromColors(
                            baseColor: Colors.white,
                            highlightColor: Colors.white,
                            enabled: isLoading,
                            child: Text(
                              'Rp${totalPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        child: Text(
                          'CHECK OUT (${itemCount.toString()})',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget buildCard(BuildContext context, Map<String, dynamic> item) {
    bool isAddedToCart = item['isAddedToCart'] ?? false;
    int quantity = item['quantity'] ?? 0;
    bool isAvailable = item['ketersediaan'] == 'tersedia';
    int varian = int.tryParse(item['varian']) ?? 0;
    String id = item['id'].toString();

    return GestureDetector(
      onTap: isAvailable && varian == 0
          ? () async {
              final itemInCart = items.firstWhere(
                (cartItem) => cartItem['id'] == id && cartItem['quantity'] > 0,
                orElse: () =>
                    <String, dynamic>{}, // Return an empty map if not found
              );

              if (itemInCart.isNotEmpty) {
                _showModalBottoms(context, item['id']);
              } else {
                Navigator.pushNamed(
                  context,
                  '/varian',
                  arguments: {
                    'id': id,
                    'varian': varian,
                  },
                ).then((value) async {
                  if (value != null && value is int) {
                    setState(() {
                      item['quantity'] = value; // Ambil quantity dari varian
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    // Simpan quantity ke SharedPreferences
                    await prefs.setInt('cart_$id', value);

                    // Simpan ke server dan update cart secara lokal
                    addToCart(id, value).then((_) {
                      _fetchCartData(); // Muat ulang data keranjang
                    });
                  }
                });
              }
            }
          : null,
      child: SizedBox(
        height: 260,
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                      ),
                      const Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: -0,
                                child: Icon(Icons.local_pizza,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: 20,
                                right: -30,
                                child: Icon(Icons.fastfood,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                top: 60,
                                left: -10,
                                child: Icon(Icons.rice_bowl,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: 50,
                                right: 10,
                                child: Icon(Icons.breakfast_dining,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: -10,
                                right: 30,
                                child: Icon(Icons.local_drink,
                                    size: 60, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item['nama']!,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                item['isFavorite'] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: isAvailable
                                  ? () => toggleFavorite(item['id'])
                                  : null,
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['ketersediaan']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Rp${item['alt_harga']}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isAddedToCart && isAvailable)
                                GestureDetector(
                                  onTap: () {
                                    if (varian == 1) {
                                      Navigator.pushNamed(
                                        context,
                                        '/varian',
                                        arguments: {
                                          'id': id,
                                          'varian': varian,
                                        },
                                      ).then((value) {
                                        if (value != null && value is int) {
                                          setState(() {
                                            item['quantity'] =
                                                value; // Ambil quantity dari varian
                                            addToCart(id,
                                                value); // Panggil addToCart dengan quantity yang benar
                                            _fetchCartData();
                                          });
                                        }
                                      });
                                    } else {
                                      addToCart(item['id'],
                                          1); // Tambahkan quantity default 1
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                )
                              else if (!isAvailable)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (varian == 1) {
                                          _showModalBottoms(
                                              context, item['id']);
                                        } else {
                                          decrementQuantity(item['id']);
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                      color: Colors.redAccent,
                                      iconSize: 20,
                                      padding: const EdgeInsets.all(0),
                                      constraints: const BoxConstraints(),
                                    ),
                                    isLoadingQty
                                        ? const CircularProgressIndicator() // Show loading spinner while loading qty
                                        : Text(
                                            ' ${item['quantity']}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                    IconButton(
                                      onPressed: () {
                                        if (varian == 1) {
                                          _showModalBottoms(
                                              context, item['id']);
                                        } else {
                                          incrementQuantity(item['id']);
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.redAccent,
                                      iconSize: 20,
                                      padding: const EdgeInsets.all(0),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isAvailable ? Colors.transparent : Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: Image.network(
                    item['gambar'],
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModalBottoms(BuildContext context, String itemId) async {
    // Fetch the latest item details and cart data
    Map<String, dynamic> data = await _fetchItemDetails(itemId);

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail item')),
      );
      return;
    }

    Map<String, dynamic> item = data['item'];
    List<Map<String, dynamic>> cartItems = data['cartItems'];
    List<Map<String, dynamic>> variants = data['variants'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['gambar'] ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama'] ?? '',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp${item['alt_harga'] ?? ''}',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ketersediaan: ${item['ketersediaan'] ?? ''}',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Cart items related to this item
                    if (cartItems.isNotEmpty) ...[
                      Text(
                        'Dalam Keranjang:',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var cartItem = cartItems[index];
                          var variant = variants.firstWhere(
                            (v) =>
                                v['kode'].toString() == cartItem['kode_varian'],
                            orElse: () => <String, String>{'nama': 'Unknown'},
                          );
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                  cartItem['data_item_menu']['nama'] ?? ''),
                              subtitle: Text('Varian: ${variant['nama']}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Jumlah: ${cartItem['qty']}'),
                                  Text('Rp${cartItem['alt_subtotal']}'),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close the modal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VarianEditPage(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'id': cartItem['id'].toString(),
                                        'quantity':
                                            cartItem['qty'], // Kirim qty
                                        'kode_varian': cartItem[
                                            'kode_varian'], // Kirim kode varian yang dipilih
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Text(
                        'Item ini belum ada dalam keranjang.',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Add to cart button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                        Navigator.pushNamed(context, '/varian', arguments: {
                          'id': itemId, // Kirim itemId ke halaman varian
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Tambah ke Keranjang',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget buildsCard(BuildContext context, Map<String, dynamic> item) {
    bool isAddedToCart = item['isAddedToCart'] ?? false;
    int quantity = item['quantity'] ?? 0;
    bool isAvailable = item['ketersediaan'] == 'tersedia';
    int varian = int.tryParse(item['varian']) ?? 0;
    String id = item['id'].toString();

    return GestureDetector(
      onTap: isAvailable && varian == 0
          ? () async {
              final itemInCart = items.firstWhere(
                (cartItem) => cartItem['id'] == id && cartItem['quantity'] > 0,
                orElse: () =>
                    <String, dynamic>{}, // Return an empty map if not found
              );

              if (itemInCart.isNotEmpty) {
                _showModalBottom(context, item['id']);
              } else {
                Navigator.pushNamed(
                  context,
                  '/varian',
                  arguments: {
                    'id': id,
                    'varian': varian,
                  },
                ).then((value) async {
                  if (value != null && value is int) {
                    setState(() {
                      item['quantity'] = value; // Ambil quantity dari varian
                    });
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    // Simpan quantity ke SharedPreferences
                    await prefs.setInt('cart_$id', value);

                    // Simpan ke server dan update cart secara lokal
                    addToCart(id, value).then((_) {
                      _fetchCartData(); // Muat ulang data keranjang
                    });
                  }
                });
              }
            }
          : null,
      child: SizedBox(
        height: 260,
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        height: 90,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(10)),
                        ),
                      ),
                      const Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: Stack(
                            children: [
                              Positioned(
                                top: 0,
                                left: -0,
                                child: Icon(Icons.local_pizza,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: 20,
                                right: -30,
                                child: Icon(Icons.fastfood,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                top: 60,
                                left: -10,
                                child: Icon(Icons.rice_bowl,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: 50,
                                right: 10,
                                child: Icon(Icons.breakfast_dining,
                                    size: 60, color: Colors.black),
                              ),
                              Positioned(
                                bottom: -10,
                                right: 30,
                                child: Icon(Icons.local_drink,
                                    size: 60, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                item['nama']!,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                item['isFavorite'] == true
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: isAvailable
                                  ? () => toggleFavorite(item['id'])
                                  : null,
                              padding: const EdgeInsets.all(0),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['ketersediaan']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'Rp${item['alt_harga']}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!isAddedToCart && isAvailable)
                                GestureDetector(
                                  onTap: () {
                                    if (varian == 1) {
                                      Navigator.pushNamed(
                                        context,
                                        '/varian',
                                        arguments: {
                                          'id': id,
                                          'varian': varian,
                                        },
                                      ).then((value) {
                                        if (value != null && value is int) {
                                          setState(() {
                                            item['quantity'] =
                                                value; // Ambil quantity dari varian
                                            addToCart(id,
                                                value); // Panggil addToCart dengan quantity yang benar
                                            _fetchCartData();
                                          });
                                        }
                                      });
                                    } else {
                                      // Jika tidak ada varian, langsung tambahkan ke keranjang dengan quantity default 1
                                      addToCart(item['id'],
                                          1); // Tambahkan quantity default 1
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.shopping_cart,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                )
                              else if (!isAvailable)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                )
                              else
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        if (varian == 1) {
                                          _showModalBottom(context, item['id']);
                                        } else {
                                          decrementQuantity(item['id']);
                                        }
                                      },
                                      icon: const Icon(Icons.remove),
                                      color: Colors.redAccent,
                                      iconSize: 20,
                                      padding: const EdgeInsets.all(0),
                                      constraints: const BoxConstraints(),
                                    ),
                                    isLoadingQty
                                        ? const CircularProgressIndicator() // Show loading spinner while loading qty
                                        : Text(
                                            ' ${item['quantity']}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                    IconButton(
                                      onPressed: () {
                                        if (varian == 1) {
                                          _showModalBottom(context, item['id']);
                                        } else {
                                          incrementQuantity(item['id']);
                                        }
                                      },
                                      icon: const Icon(Icons.add),
                                      color: Colors.redAccent,
                                      iconSize: 20,
                                      padding: const EdgeInsets.all(0),
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isAvailable ? Colors.transparent : Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: Image.network(
                    item['gambar'],
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModalBottom(BuildContext context, String itemId) async {
    // Fetch the latest item details and cart data
    Map<String, dynamic> data = await _fetchItemDetails(itemId);

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat detail item')),
      );
      return;
    }

    Map<String, dynamic> item = data['item'];
    List<Map<String, dynamic>> cartItems = data['cartItems'];
    List<Map<String, dynamic>> variants = data['variants'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.2,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item details
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['gambar'] ?? '',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['nama'] ?? '',
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp${item['alt_harga'] ?? ''}',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ketersediaan: ${item['ketersediaan'] ?? ''}',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Cart items related to this item
                    if (cartItems.isNotEmpty) ...[
                      Text(
                        'Dalam Keranjang:',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var cartItem = cartItems[index];
                          var variant = variants.firstWhere(
                            (v) =>
                                v['kode'].toString() == cartItem['kode_varian'],
                            orElse: () => <String, String>{'nama': 'Unknown'},
                          );
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                  cartItem['data_item_menu']['nama'] ?? ''),
                              subtitle: Text('Varian: ${variant['nama']}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Jumlah: ${cartItem['qty']}'),
                                  Text('Rp${cartItem['alt_subtotal']}'),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(context); // Close the modal
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VarianEditPage(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'id': cartItem['id'].toString(),
                                        'quantity':
                                            cartItem['qty'], // Kirim qty
                                        'kode_varian': cartItem[
                                            'kode_varian'], // Kirim kode varian yang dipilih
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ] else ...[
                      Text(
                        'Item ini belum ada dalam keranjang.',
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Add to cart button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                        Navigator.pushNamed(context, '/varian', arguments: {
                          'id': itemId, // Kirim itemId ke halaman varian
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Tambah ke Keranjang',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

Widget _buildMenuItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Ubah warna latar belakang di sini
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class CategoryIcon extends StatelessWidget {
  final String label;
  final String imagePath;

  const CategoryIcon({super.key, required this.label, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 30,
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String label;
  final String icon;

  const CategoryButton({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Adjust the width as needed
      height: 100, // Adjust the height as needed
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 40, // Adjust the size of the icon
            height: 40, // Adjust the size of the icon
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15, // Adjust the font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildShimmerCard(BuildContext context) {
  return Transform.translate(
    offset: const Offset(0, -10),
    child: Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 150.0,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 1, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 100.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 70.0,
                    height: 20.0,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget shimmerPlaceholder() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160, // Height of the image placeholder
            width: double.infinity,
            color: Colors.grey, // Color of the image placeholder
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20,
                  width: 100,
                  color: Colors.grey, // Color of the name placeholder
                ),
                const SizedBox(height: 4),
                Container(
                  height: 15,
                  width: 150,
                  color: Colors.grey, // Color of the variant placeholder
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      height: 15,
                      width: 20,
                      color: Colors.grey, // Color of the icon placeholder
                    ),
                    const SizedBox(width: 4),
                    Container(
                      height: 15,
                      width: 100,
                      color: Colors.grey, // Color of the calories placeholder
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: 80,
                  color: Colors.grey, // Color of the price placeholder
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CategoryModal extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Beras',
      'icon': Icons.grain,
      'color': Colors.brown[300],
    },
    {
      'name': 'Minyak',
      'icon': Icons.water_drop,
      'color': Colors.yellow[700],
    },
    {
      'name': 'Gula',
      'icon': Icons.coffee,
      'color': Colors.pink[200],
    },
    {
      'name': 'Tepung',
      'icon': Icons.soup_kitchen,
      'color': Colors.orange[300],
    },
    {
      'name': 'Telur',
      'icon': Icons.egg,
      'color': Colors.red[300],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {},
          child: DraggableScrollableSheet(
            initialChildSize: 0.4, // Reduced since we only have 5 items
            maxChildSize: 0.6,
            minChildSize: 0.4,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bahan Pokok',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Handle category selection
                              Navigator.pop(context, categories[index]['name']);
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: categories[index]['color']
                                        ?.withOpacity(0.2),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      categories[index]['icon'],
                                      size: 32,
                                      color: categories[index]['color'],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  categories[index]['name'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
