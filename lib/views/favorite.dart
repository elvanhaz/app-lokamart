import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();
  double _currentPage = 0.0;

  late AnimationController _rotationController;
  late AnimationController _blobController;
  late Animation<double> _blobScale;

  List<dynamic> _favorites = []; // List to store favorite items

  @override
  void initState() {
    super.initState();

    // Fetch data from API
    _fetchFavorites();

    // Controller for PageView
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page ?? 0.0;
      });
    });

    // Animation controller for the blob's "pulsing" effect
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Blob scale animation
    _blobScale = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _blobController, curve: Curves.easeInOut),
    );

    // Animation controller for rotation effect
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Duration for a full rotation
    )..repeat(); // Repeats indefinitely
  }

  // Fetch data from API
  Future<void> _fetchFavorites() async {
    try {
      // Ambil token dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs
          .getString('sanctumToken'); // Ganti 'token' dengan kunci yang sesuai

      if (token == null) {
        print('Token tidak ditemukan');
        return;
      }

      // Lakukan permintaan HTTP dengan token
      final response = await http.get(
        Uri.parse('https://loka-mart.demoaplikasi.web.id/api/v1/favorit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _favorites = json.decode(
              response.body)['data']; // Parse response and store in _favorites
        });
      } else {
        print(
            'Gagal memuat item. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _blobController.dispose();

    // Dispose of the rotation controller if it is initialized
    if (_rotationController.isAnimating) {
      _rotationController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _favorites.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading if data is not yet fetched
          : PageView.builder(
              controller: _controller,
              itemCount: _favorites
                  .length, // Dynamically set the item count based on API response
              itemBuilder: (context, index) {
                return _buildPage(index);
              },
            ),
    );
  }

  // Background Gradient Animation with AnimatedContainer
  Widget _buildPage(int index) {
    // Get current favorite item
    final favorite = _favorites[index];

    List<List<Color>> gradientColors = [
      [Colors.pink[100]!, Colors.pink[300]!], // Slide 0
      [Colors.lightBlue[100]!, Colors.lightBlue[300]!], // Slide 1
      [Colors.green[100]!, Colors.green[300]!], // Slide 2
      [Colors.orange[100]!, Colors.orange[300]!], // Slide 3
      [Colors.purple[100]!, Colors.purple[300]!], // Slide 4
      [Colors.teal[100]!, Colors.teal[300]!], // Slide 5
      [Colors.yellow[100]!, Colors.yellow[300]!], // Slide 6
      [Colors.red[100]!, Colors.red[300]!], // Slide 7
      [Colors.indigo[100]!, Colors.indigo[300]!], // Slide 8
      [Colors.cyan[100]!, Colors.cyan[300]!], // Slide 9
    ];

// Different background colors for each slide
    BoxDecoration backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors[
            index % gradientColors.length], // Get colors based on index
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    // Calculate delta for Y-axis rotation and parallax effect
    double delta = index - _currentPage;
    double rotationY = (delta * 0.6).clamp(-1.0, 1.0);
    double scale = 1 - (rotationY.abs() * 0.1);
    double parallaxOffset = (delta * 70).clamp(-70.0, 70.0);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(rotationY * 1.2),
      alignment: Alignment.center,
      child: Stack(
        children: [
          // Full background for each slide
          Container(
            decoration: backgroundDecoration,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Blob shape behind the image with "pulsing" and subtle rotation animation
                      Align(
                        alignment: Alignment.center,
                        child: AnimatedBuilder(
                          animation: _blobScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _blobScale.value,
                              child: Transform.rotate(
                                angle: delta * 0.2, // Subtle rotation
                                child: Image.asset(
                                  'assets/effect.png',
                                  width: 350,
                                  height: 350,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Text behind the image, positioned in the center with parallax effect
                      Align(
                        alignment: Alignment.topCenter,
                        child: Transform.translate(
                          offset: Offset(parallaxOffset, 150),
                          child: Text(
                            favorite['nama'], // Dynamically display item name
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Image in the center with scale effect and rotation
                      Align(
                        alignment: Alignment.center,
                        child: Transform.scale(
                          scale: scale,
                          child: RotationTransition(
                            turns: _rotationController,
                            child: Image.network(
                              favorite[
                                  'gambar'], // Dynamically load the image from API
                              width: 250,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Task box with fade-in effect
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: AnimatedOpacity(
                    opacity: _currentPage.round() == index ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Transform.scale(
                      scale: _currentPage.round() == index ? 1.0 : 0.8,
                      child: _buildTaskBox(
                          favorite), // Pass the favorite item to the task box
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Plus icon in the top left
          const Positioned(
            top: 30,
            left: 16,
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Task Box Widget with icons and text
  Widget _buildTaskBox(dynamic favorite) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fastfood,
                size: 24,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(
                favorite['nama'], // Dynamically display item name
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Space between task rows
          Row(
            children: [
              const Icon(
                Icons.price_change_outlined,
                size: 24,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 10),
              Text(
                'Harga: ${favorite['alt_harga']}', // Dynamically display item price
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
