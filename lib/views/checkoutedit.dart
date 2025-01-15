import 'package:loka/providers/MenuProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CheckoutEditPage extends StatefulWidget {
  const CheckoutEditPage({super.key});

  @override
  _CheckoutEditPageState createState() => _CheckoutEditPageState();
}

class _CheckoutEditPageState extends State<CheckoutEditPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? productData;
  late AnimationController _animationController;
  late Animation<double> _contentAnimation;

  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _contentAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        productData = args;
        _isChecked = List<bool>.filled(productData!['varian'].length, false);
        quantity = (args['quantity'] is String)
            ? int.tryParse(args['quantity']) ?? 1
            : args['quantity'] ?? 1;
        // Initialize selected variant
        _selectedVariantIndex = productData!['varian'].indexWhere(
          (v) => v['kode'].toString() == productData!['selected_variant'],
        );
        if (_selectedVariantIndex != -1) {
          _isChecked[_selectedVariantIndex] = true;
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

  int quantity = 1;
  bool isButtonDisabled = false; // Menambahkan state untuk disable tombol
  bool _isExpandedAbout = false;
  bool _isExpandedIngredients = false;
  bool _isExpandedOrder = false;
  // State untuk mengatur apakah checkbox terpilih atau tidak

  List<bool> _isChecked = [];
  int _selectedVariantIndex = -1;
  double imageSize = 300;
  double textSize = 25;
  double imageLeftPosition = 50;
  double imageTopPosition = 100;
  double textLeftPosition = 70;
  double textTopPosition = 400;
  double pricePerItem = 0; // fetched price from API
  double selectedVariantsPrice =
      0; // Untuk menyimpan total harga varian yang dipilih

  @override
  Widget build(BuildContext context) {
    bool isAnyExpanded =
        _isExpandedAbout || _isExpandedIngredients || _isExpandedOrder;
    String selectedVariant = productData!['varian'].firstWhere(
      (v) => v['kode'].toString() == productData!['selected_variant'],
      orElse: () => {'nama': ''},
    )['nama'];
    double screenWidth = MediaQuery.of(context).size.width;
    // Cek apakah ada varian
    bool hasVariants = productData != null &&
        productData!['varian'] != null &&
        productData!['varian'].isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipPath(
                clipper: WaveClipper(_animation.value),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.pink[100]!,
                        Colors.orange[200]!.withOpacity(0.7),
                        Colors.orange[50]!.withOpacity(0.5),
                      ],
                      stops: const [0, 0.5, 1],
                    ),
                  ),
                ),
              );
            },
          ),
          // Content
          AnimatedBuilder(
            animation: _contentAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    0,
                    MediaQuery.of(context).size.height *
                        (1 - _contentAnimation.value)),
                child: child,
              );
            },
            child: Column(
              children: [
                SizedBox(
                  height: 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: isAnyExpanded ? 100 : imageTopPosition,
                        left: isAnyExpanded ? 0 : imageLeftPosition,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: isAnyExpanded ? 200 : imageSize,
                          width: isAnyExpanded ? 200 : imageSize,
                          child: Image.network(
                            productData!['gambar'], // Menggunakan productData
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 350,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        top: isAnyExpanded ? 180 : textTopPosition,
                        left: isAnyExpanded ? 150 : textLeftPosition,
                        width: screenWidth - 2 * textLeftPosition,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isAnyExpanded ? 20 : textSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              child: Text(
                                '${productData!['nama']}', // Menggunakan productData
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: TextStyle(
                                fontSize: isAnyExpanded ? 18 : textSize - 4,
                                color: Colors.black38,
                                fontWeight: FontWeight.bold,
                              ),
                              child: Text(
                                ' $selectedVariant',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Transform.translate(
                            offset: const Offset(0, 80),
                            child: _buildOverlappingSection(
                              title: 'Deskripsi',
                              content: _buildAboutSection(),
                              isExpanded: _isExpandedAbout,
                              onToggle: () {
                                setState(() {
                                  _isExpandedAbout = !_isExpandedAbout;
                                  _isExpandedIngredients = false;
                                  _isExpandedOrder = false;
                                });
                              },
                              backgroundColor:
                                  const Color.fromARGB(255, 238, 116, 107),
                              isTop: true,
                            ),
                          ),
                          // Hanya tampilkan bagian varian jika ada varian
                          if (hasVariants)
                            Transform.translate(
                              offset: const Offset(0, 50),
                              child: _buildOverlappingSection(
                                title: 'Varian',
                                content: _buildIngredientsSection(),
                                isExpanded: _isExpandedIngredients,
                                onToggle: () {
                                  setState(() {
                                    _isExpandedIngredients =
                                        !_isExpandedIngredients;
                                    _isExpandedAbout = false;
                                    _isExpandedOrder = false;
                                  });
                                },
                                backgroundColor: Colors.brown.shade400,
                              ),
                            ),
                          const SizedBox(height: 10),
                          Transform.translate(
                            offset: const Offset(0, 10),
                            child: _buildOverlappingSection(
                              title: 'Pesanan',
                              content: _buildOrderSection(),
                              isExpanded: _isExpandedOrder,
                              onToggle: () {
                                setState(() {
                                  _isExpandedOrder = !_isExpandedOrder;
                                  _isExpandedAbout = false;
                                  _isExpandedIngredients = false;
                                });
                              },
                              backgroundColor: Colors.white,
                              isBottom: true,
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
        ],
      ),
    );
  }

  Widget _buildOverlappingSection({
    required String title,
    required Widget content,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Color backgroundColor,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(40), // Padding instead of margin
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: isTop ? const Radius.circular(60) : const Radius.circular(40),
            bottom:
                isBottom ? const Radius.circular(0) : const Radius.circular(0),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Adding Transform.translate to move the title slightly up
            Transform.translate(
              offset:
                  const Offset(0, -15), // Adjust this value to move title up
              child: Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Memisahkan title dan quantity
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isBottom ? Colors.black : Colors.white,
                    ),
                  ),
                  // Ini untuk menampilkan quantity di sebelah kanan title
                  if (title ==
                      'Pesanan') // Hanya tampilkan untuk "Jumlah Pesanan"
                    Row(
                      children: [
                        _buildQuantityButton(Icons.remove, () {
                          if (quantity > 1) setState(() => quantity--);
                        }),
                        const SizedBox(width: 10),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        _buildQuantityButton(Icons.add, () {
                          setState(() => quantity++);
                        }, isAdd: true),
                      ],
                    ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: content,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSection() {
    double itemPrice = double.tryParse(productData!['harga'].toString()) ?? 0.0;
    double variantPrice = _selectedVariantIndex != -1
        ? double.tryParse(productData!['varian'][_selectedVariantIndex]['harga']
                .toString()) ??
            0.0
        : 0.0;

    double totalPrice = (itemPrice + variantPrice) * quantity;

    return Column(
      children: [
        // Dotted line
        SizedBox(
          height: 1,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => Container(
              width: 5,
              height: 1,
              color: index % 2 == 0 ? Colors.grey[300] : Colors.transparent,
            ),
            itemCount: 100,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  elevation: 0,
                ),
                onPressed: isButtonDisabled
                    ? null // Disable tombol jika `isButtonDisabled == true`
                    : () async {
                        if (_selectedVariantIndex == -1) {
                          // Jika varian belum dipilih, tampilkan Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Harap pilih varian terlebih dahulu'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          setState(() {
                            isButtonDisabled = true;
                          });

                          Map<String, dynamic> checkoutData = {
                            'id': productData!['id'],
                            'id_item_menu': productData!['productId'],
                            'kode_varian': productData!['varian']
                                [_selectedVariantIndex]['kode'],
                            'qty': quantity,
                          };
                          print('Body yang akan dikirim: $checkoutData');

                          try {
                            await postCheckoutData(checkoutData);
                            Navigator.pushNamed(context, '/checkout');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Produk berhasil ditambahkan ke keranjang'),
                              ),
                            );
                          } catch (error) {
                            // Jika terjadi kesalahan, tampilkan Snackbar dan enable tombol lagi
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Gagal menambahkan produk, coba lagi'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            setState(() {
                              isButtonDisabled =
                                  false; // Enable tombol jika gagal
                            });
                          }
                        }
                      },
                child: Text(
                  isButtonDisabled
                      ? 'Memproses...'
                      : 'Tambah Keranjang', // Mengubah teks saat proses berlangsung
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                formatRupiah(totalPrice), // Menggunakan fungsi formatRupiah
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed,
      {bool isAdd = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent, // Remove shadow
        side: BorderSide(
          color: isAdd ? Colors.black : Colors.grey.shade300,
        ),
        padding: const EdgeInsets.all(18),
      ),
      child: Icon(icon, color: isAdd ? Colors.black : Colors.grey),
    );
  }

  Widget _buildIngredientsSection() {
    if (productData == null || productData!['varian'] == null) {
      return const Text('Tidak tersedia varian');
    }

    List<dynamic> variants = productData!['varian'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (int i = 0; i < variants.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0),
            child: _buildIngredientCheckbox(variants[i]['nama'], i),
          ),
      ],
    );
  }

  Widget _buildIngredientCheckbox(String variantName, int index) {
    String variantPrice = productData!['varian'][index]['harga'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  variantName,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                'Rp. $variantPrice',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              const SizedBox(width: 10),
              Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.white,
                ),
                child: Checkbox(
                  side: const BorderSide(color: Colors.white, width: 2),
                  checkColor: Colors.white,
                  activeColor: Colors.black,
                  value: _isChecked[index],
                  onChanged: (bool? value) {
                    setState(() {
                      for (int i = 0; i < _isChecked.length; i++) {
                        _isChecked[i] = i == index;
                      }
                      _selectedVariantIndex = index;
                      productData!['selected_variant'] =
                          productData!['varian'][index]['kode'];
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Text(
        '${productData!['deskripsi']}',
        style: GoogleFonts.poppins(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  WaveClipper(this.animation);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double waveHeight = 20.0;
    double waveCount = 3;

    path.lineTo(0, size.height * (1 - animation));

    for (int i = 0; i < waveCount; i++) {
      double waveStart = size.width / waveCount * i;
      path.quadraticBezierTo(
        waveStart + size.width / (waveCount * 2),
        size.height * (1 - animation) - waveHeight * (1 - animation),
        waveStart + size.width / waveCount,
        size.height * (1 - animation),
      );
    }
    path.lineTo(size.width, size.height * (1 - animation));
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
