import 'dart:async';
import 'package:loka/providers/GetOutletsProvider.dart';
import 'package:loka/providers/OutletProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class CabangPage extends StatefulWidget {
  const CabangPage({super.key});

  @override
  _CabangPageState createState() => _CabangPageState();
}

class _CabangPageState extends State<CabangPage> {
  TextEditingController searchController = TextEditingController();
  String userAddress = 'Loading location...';
  Timer? _typingTimer;
  bool isLoading = true;
  final String fullText = 'Hallo Pelanggan';
  String currentText = '';
  int currentCharIndex = 0;
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    final outletProvider =
        Provider.of<GetOutletProvider>(context, listen: false);
    outletProvider.checkLocationPermission();

    searchController.addListener(() {
      outletProvider.filterOutlets(searchController.text);
    });

    startTypingAnimation();
  }

  @override
  void dispose() {
    searchController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void startTypingAnimation() {
    _typingTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (currentCharIndex < fullText.length) {
        if (mounted) {
          setState(() {
            currentText += fullText[currentCharIndex];
            currentCharIndex++;
            opacity = 1.0;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('sanctumToken');
    await prefs.remove('phoneNumber');
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(
        context, '/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final outletProvider = Provider.of<GetOutletProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 5,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: AnimatedOpacity(
          opacity: opacity,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: currentText,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (currentCharIndex == fullText.length)
                    const WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Icon(
                          Icons.fastfood,
                          size: 24,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: outletProvider.fetchOutlets,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            outletProvider.userAddress ?? userAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: "Cari cabang dimanapun ....",
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Cabang Terdekat",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildOutletListSliver(outletProvider.isLoading),
            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutletListSliver(bool isLoading) {
    final outletProvider = Provider.of<GetOutletProvider>(context);
    final filteredOutlets = outletProvider.filteredOutlets;

    if (isLoading) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverGrid(
          gridDelegate: SliverWovenGridDelegate.count(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            pattern: [
              const WovenGridTile(0.7),
              const WovenGridTile(0.85),
            ],
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(8.0),
                  height: 150,
                  width: double.infinity,
                ),
              );
            },
            childCount: 6,
          ),
        ),
      );
    }

    if (filteredOutlets.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No outlets found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: outletProvider.fetchOutlets,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    // Sort the filteredOutlets list, handling null distance values
    filteredOutlets.sort((a, b) {
      final distanceA =
          double.tryParse(a['distance']?.toString() ?? '') ?? double.infinity;
      final distanceB =
          double.tryParse(b['distance']?.toString() ?? '') ?? double.infinity;
      return distanceA.compareTo(distanceB);
    });

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      sliver: SliverGrid(
        gridDelegate: SliverWovenGridDelegate.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          pattern: [
            const WovenGridTile(0.7),
            const WovenGridTile(0.85),
          ],
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final outlet = filteredOutlets[index];
            final distance = outlet['distance'] ?? 'N/A';

            return AnimationLimiter(
              child: AnimationConfiguration.staggeredList(
                position: index,
                duration: Duration(milliseconds: 700 + index * 200),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  curve: Curves.easeInOut,
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<OutletProvider>()
                            .setOutletId(outlet['id']);
                        Navigator.pushNamed(context, '/kategory');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                outlet['gambar'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  distance == 'N/A' ? 'N/A' : '$distance km',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  outlet['nama'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0.5, 0.5),
                                        blurRadius: 3,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: filteredOutlets.length,
        ),
      ),
    );
  }
}
