import 'dart:async';

import 'package:loka/providers/CartProvider.dart';
import 'package:loka/providers/OutletProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';

class SearchPage extends StatefulWidget {
  final VoidCallback refreshCategoryPage;

  const SearchPage({super.key, required this.refreshCategoryPage});
  @override
  _SearchBarScreenState createState() => _SearchBarScreenState();
}

class _SearchBarScreenState extends State<SearchPage> {
  bool hasChanges = false;
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;
  bool isCategoryLoading = true;
  String selectedCategoryId = '0'; // 0 for "Semua" category
  final String fullText =
      'Cari apapun\n yang kamu butuhin'; // Full text to be animated
  String currentText = '';
  int currentCharIndex = 0;
  double opacity = 0.0;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _fetchItemsFromApi();
    _fetchCategoriesFromApi();

    // Fetch cart data
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.fetchCartData(
        outletProvider.outletId!); // Assuming outletId is non-null
    startTypingAnimation();
  }

  @override
  void dispose() {
    _typingTimer?.cancel(); // Batalkan timer saat widget di-`dispose`

    super.dispose();
  }

  void startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentCharIndex < fullText.length) {
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

  Future<void> _fetchItemsFromApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await storage.read(key: 'sanctumToken') ??
          prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      String apiUrl = selectedCategoryId == '0'
          ? 'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu'
          : 'https://loka-mart.demoaplikasi.web.id/api/v1/item-menu?id_kategori=$selectedCategoryId';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        if (!mounted) return;

        setState(() {
          items = List<Map<String, dynamic>>.from(data['data']
              .map((item) => {
                    'id': item['id'].toString(),
                    'gambar': item['gambar'].toString(),
                    'nama': item['nama'].toString(),
                    'harga': item['harga'].toString(),
                    'alt_harga': item['alt_harga'].toString(),
                    'varian': item['varian'].toString(),
                    'ketersediaan': item['ketersediaan'].toString(),
                    'isAddedToCart': item['isAddedToCart'] ?? false,
                    'quantity': item['quantity'] ?? 0,
                  })
              .toList());
          filteredItems = items;
          isLoading = false;
        });
      } else {
        _handleErrorResponse(response);
      }
    } catch (e) {
      print('Error occurred: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchCategoriesFromApi() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = await storage.read(key: 'sanctumToken') ??
          prefs.getString('sanctumToken');

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/kategori?table=item_menu'),
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
              {'id': '0', 'nama': 'Semua'},
              ...List<Map<String, dynamic>>.from(data['data']
                  .map((category) => {
                        'id': category['id']?.toString() ?? '',
                        'nama': category['nama'].toString(),
                      })
                  .toList())
            ];
            isCategoryLoading = false;
          });
        }
      } else {
        _handleErrorResponse(response);
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

  void _handleErrorResponse(http.Response response) {
    print(
        'Failed to load data. Status code: ${response.statusCode}, Body: ${response.body}');
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  String sanitizeInput(String input) {
    final RegExp regExp = RegExp(r'^[a-zA-Z0-9\s\-_]*$');
    String sanitizedInput = regExp.hasMatch(input) ? input : '';
    return sanitizedInput.length > 100
        ? sanitizedInput.substring(0, 100)
        : sanitizedInput;
  }

  void _onSearchChanged(String query) {
    if (_typingTimer != null) {
      _typingTimer!.cancel(); // Cancel the previous timer
    }

    _typingTimer = Timer(const Duration(milliseconds: 300), () {
      _filterItems(query); // Delay search to avoid frequent calls
    });
  }

  void _filterItems(String query) {
    String sanitizedQuery = sanitizeInput(query);
    setState(() {
      filteredItems = items.where((item) {
        return item['nama']
            .toString()
            .toLowerCase()
            .contains(sanitizedQuery.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          if (hasChanges) {
            widget.refreshCategoryPage();
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Makanan List',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 300),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: currentText, // Typing effect text
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'CoolFont', // Replace with your custom font
                              color: Colors.black,
                            ),
                          ),
                          if (currentCharIndex ==
                              fullText.length) // Show icon when typing is done
                            const WidgetSpan(
                              child: Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Icon(
                                  Icons.fastfood, // Burger emoji replacement
                                  size: 24,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Lagi Mau Cari Apa ?...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) {
                      _filterItems(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: isCategoryLoading
                        ? [
                            const CircularProgressIndicator()
                          ] // Show loading indicator while loading
                        : categories.map((category) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryId = category['id'];
                                  _fetchItemsFromApi(); // Fetch items based on the selected category
                                });
                              },
                              child: _buildFilterChip(category['nama'],
                                  isSelected:
                                      selectedCategoryId == category['id']),
                            );
                          }).toList(),
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? Expanded(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: ListView.builder(
                              itemCount: 5, // Placeholder count
                              itemBuilder: (context, index) =>
                                  _buildShimmerItem(),
                            ),
                          ),
                        )
                      : Expanded(
                          child: filteredItems.isEmpty
                              ? const Center(
                                  child: Text('Menu tidak ditemukan'),
                                )
                              : ListView.builder(
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    return _buildFoodItem(
                                        context, filteredItems[index]);
                                  },
                                ),
                        ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.red : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.red,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.red,
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, Map<String, dynamic> item) {
    final cartProvider = Provider.of<CartProvider>(context);
    final outletProvider = Provider.of<OutletProvider>(context, listen: false);
    final outletId = outletProvider.outletId;
    bool isInCart = cartProvider.cartItems
        .any((cartItem) => cartItem['id_item_menu'] == item['id']);
    int quantity = isInCart
        ? int.parse(cartProvider.cartItems.firstWhere(
            (cartItem) => cartItem['id_item_menu'] == item['id'])['qty'])
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 35, right: 50),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                item['ketersediaan'],
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${item['alt_harga']}',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
              const SizedBox(height: 12),
              isInCart
                  ? Row(
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (quantity > 1) {
                              cartProvider.optimisticAddToCart(
                                  item['id'], quantity - 1, outletId!, item);
                            } else {
                              cartProvider.optimisticRemoveFromCart(
                                  item['id'], outletId!);
                            }
                            setState(() {
                              hasChanges = true;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onPressed: () {
                            cartProvider.optimisticAddToCart(
                                item['id'], quantity + 1, outletId!, item);
                            setState(() {
                              hasChanges = true;
                            });
                          },
                        ),
                      ],
                    )
                  : GestureDetector(
                      onTap: () {
                        cartProvider.optimisticAddToCart(
                            item['id'], 1, outletId!, item);
                        setState(() {
                          hasChanges = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                    ),
            ],
          ),
          Positioned(
            top: -10,
            right: -80,
            child: ClipRRect(
              clipBehavior: Clip.none,
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item['gambar'],
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
