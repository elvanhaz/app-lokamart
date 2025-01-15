// import 'dart:async';
// import 'package:loka/customP.dart';
// import 'package:loka/pemesanan.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

// class ScrollToHideWidget extends StatefulWidget {
//   final Widget child;
//   final ScrollController controller;
//   final Duration duration;

//   ScrollToHideWidget({
//     required this.child,
//     required this.controller,
//     this.duration = const Duration(milliseconds: 100),
//   });

//   @override
//   _ScrollToHideWidgetState createState() => _ScrollToHideWidgetState();
// }


// class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
//   bool isVisible = true;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     widget.controller.removeListener(_scrollListener);
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _scrollListener() {
//     _timer?.cancel();

//     if (widget.controller.position.userScrollDirection ==
//         ScrollDirection.reverse) {
//       if (isVisible) {
//         setState(() {
//           isVisible = false;
//         });
//       }
//     } else if (widget.controller.position.userScrollDirection ==
//         ScrollDirection.forward) {
//       if (!isVisible) {
//         setState(() {
//           isVisible = true;
//         });
//       }
//     }

//     _timer = Timer(const Duration(seconds: 2), () {
//       setState(() {
//         isVisible = true;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: widget.duration,
//       height:
//           isVisible ? kBottomNavigationBarHeight + 10 : 0, // Menambahkan tinggi
//       child: Container(
//         margin: EdgeInsets.only(
//             bottom:
//                 00.0), // Menambahkan margin bawah untuk jarak dari bawah layar
//         child: widget.child,
//       ),
//     );
//   }
// }

// void main() {
//   runApp(CheckoutPage());
// }

// class CheckoutPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CheckoutScreen(),
//       routes: {
//         '/customP': (context) => CustomPurchaseApp(),
//                 '/pemesanan': (context) => PemesananPage(),

//       },
//       theme: ThemeData(
//         primarySwatch: Colors.grey,
//       ),
//     );
//   }
// }

// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//    int _itemCount = 0;
//      bool _isBottomBarVisible = false; // Variable to track visibility
//   final ScrollController _scrollController = ScrollController();
//  int _count = 0;
//   Color _appBarColor = const Color.fromRGBO(229, 36, 53, 1);
//   bool _showTitle = false;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(() {
//       setState(() {
//         _showTitle = _scrollController.offset > 100;
//         if (_scrollController.offset > 100) {
//           _appBarColor = Colors.white;
//         } else {
//           _appBarColor = const Color.fromRGBO(229, 36, 53, 1);
//         }
//       });
//     });
//   }
//   void _toggleBottomBarVisibility() {
//     if (!_isBottomBarVisible) {
//       setState(() {
//         _isBottomBarVisible = true;
//       });
//     }
//   }
//   void _toggleBottomBarVisibilit() {
//     if (!_isBottomBarVisible) {
//       setState(() {
//         _isBottomBarVisible = false;
//       });
//     }
//   }
//  void _incrementItemCount() {
//     setState(() {
//       _itemCount++;
//       if (_itemCount > 0) {
//         _isBottomBarVisible = true;
//       }
//     });
//   }

//   void _decrementItemCount() {
//     setState(() {
//       if (_itemCount > 0) _itemCount--;
//       if (_itemCount == 0) {
//         _isBottomBarVisible = false;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: <Widget>[
//           SliverAppBar(
//             floating: true,
//             pinned: true,
//             backgroundColor: _appBarColor,
//             elevation: 0,
//             title: _showTitle
//                 ? Text(
//                     'McDonald\'s, Sukahati',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: _appBarColor == Colors.white
//                           ? Colors.black
//                           : Colors.white,
//                     ),
//                   )
//                 : null,
//             actions: [
//              Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white, // Warna fill putih
//       ),
//       child: IconButton(
//         icon: Icon(Icons.search, color: Colors.black.withOpacity(0.5)),
//         onPressed: () {},
//       ),
//     ),
//     SizedBox(width: 5,),
//                Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white, // Warna fill putih
//       ),
//       child: IconButton(
//         icon: Icon(Icons.favorite, color: Colors.black.withOpacity(0.5)),
//         onPressed: () {},
//       ),
//     ),
//                  SizedBox(width: 5,),
//                Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.white, // Warna fill putih
//       ),
//       child: IconButton(
//         icon: Icon(Icons.share, color: Colors.black.withOpacity(0.5)),
//         onPressed: () {},
//       ),
//     ),

//             ],
//           ),
//           SliverList(
//             delegate: SliverChildListDelegate(
//               [
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color.fromRGBO(229, 36, 53, 1),
//                     borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(150),
//                       bottomRight: Radius.circular(150),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Transform.translate(
//                         offset: Offset(0, 20),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.3),
//                                 spreadRadius: 1,
//                                 blurRadius: 0,
//                                 offset: Offset(0, 0),
//                               ),
//                             ],
//                           ),
//                           padding: EdgeInsets.all(12),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Image.asset(
//                                           'assets/1.jpg',
//                                           height: 30,
//                                           width: 30,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'McDonald\'s, Sukahati',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Cibinong',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Text(
//                                               'Cepat saji, Sweets, Jajanan',
//                                               style:
//                                                   TextStyle(color: Colors.grey),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 15),
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Icon(Icons.motorcycle,
//                                             size: 25, color: Colors.red),
//                                         SizedBox(width: 8),
//                                         Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               'Delivery',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                             ),
//                                             Row(
//                                               children: [
//                                                 Text(
//                                                   'tiba 25-35 min  (4.33 km)',
//                                                   style: TextStyle(
//                                                       color: Colors.grey),
//                                                 ),
//                                                 SizedBox(width: 10),
//                                                 Icon(Icons.arrow_forward_ios,
//                                                     size: 12,
//                                                     color: Colors.grey),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.end,
//                                 children: [
//                                   Container(
//                                     width:
//                                         100, // Adjusted width to make the box longer
//                                     decoration: BoxDecoration(
//                                       color:
//                                           const Color.fromRGBO(0, 136, 12, 1),
//                                       borderRadius: BorderRadius.only(
//                                         topLeft: Radius.circular(12),
//                                         topRight: Radius.circular(12),
//                                       ),
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 4),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           padding: const EdgeInsets.only(
//                                               left: 10.0, right: 5.0),
//                                           child: Text(
//                                             '4.8',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 13,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         Icon(Icons.star,
//                                             color: Colors.white, size: 20),
//                                       ],
//                                     ),
//                                   ),
//                                   Container(
//                                     width:
//                                         100, // Adjusted width to make the box longer
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(12),
//                                         bottomRight: Radius.circular(12),
//                                       ),
//                                       border: Border.all(
//                                           color: Colors.grey.shade300),
//                                     ),
//                                     padding: EdgeInsets.symmetric(
//                                         horizontal: 8, vertical: 4),
//                                     child: Text(
//                                       '103rb+ ratings',
//                                       style: TextStyle(
//                                           color: Colors.grey,
//                                           fontSize: 11,
//                                           fontWeight: FontWeight.bold),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     padding: EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.3),
//                           spreadRadius: 1,
//                           blurRadius: 0,
//                           offset: Offset(0, 0), // changes position of shadow
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             CircleAvatar(
//                               backgroundColor: Colors.yellow,
//                               radius: 24,
//                               child: Icon(Icons.local_offer,
//                                   color: Colors.red, size: 24),
//                             ),
//                             SizedBox(width: 16),
//                             Expanded(
//                               child: Text(
//                                 'Ada 5 promo nganggur',
//                                 style: TextStyle(
//                                     color: Colors.black,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Container(
//                               height: 39,
//                               width: 39,
//                               padding:
//                                   EdgeInsets.all(8), // Adjust padding as needed
//                               child: CircleAvatar(
//                                 backgroundColor:
//                                     Colors.red, // Icon background color
//                                 child: Icon(
//                                   Icons.arrow_forward,
//                                   color: Colors.white,
//                                   size: 15, // Icon color white
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 16),
//                         _buildPromoText(
//                             'Diskon makanan s.d. 50rb. Min. pembelian 300rb'),
//                         _buildPromoText(
//                             'Diskon makanan 50%, maks. 50rb. Min. pembelian 50rb'),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Padding(
//                   padding: const EdgeInsets.only(
//                       left: 16.0), // Adjust padding as needed
//                   child: Text(
//                     'Promosi',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 PromoItem(
//                   title: 'Iced Coffee Macadamia Float',
//                   price: '25.000',
//                   imageAsset: 'assets/minumans.png', // Replace with your image
//                   hasCustomOption: true,
//                 ),
//                 SizedBox(height: 12),
//                 PromoItem(
//                   title: 'Iced Coffee Macadamia with Jelly',
//                   price: '21.500',
//                   imageAsset: 'assets/minumans.png', // Replace with your image
//                   hasCustomOption: true,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar:  _isBottomBarVisible
//           ? ScrollToHideWidget(
//         controller: _scrollController,
//           child: GestureDetector(
//           onTap: () {
//               Navigator.pushNamed(context, '/pemesanan');
//           },
//         child: BottomAppBar(
//           color: Colors.white,
//           shape: null,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 10.0),
//             decoration: BoxDecoration(
              
//               color: const Color.fromARGB(
//                   255, 59, 137, 61), // Green background color
//               borderRadius: BorderRadius.circular(30.0), // Rounded corners
           
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '1 item\nDiantar dari McDonald\'s, Sukahati Ci...',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 Text(
//                   '28.000',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Icon(
//                   Icons.lock,
//                   color: Colors.white,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       )
//           )
//           : null,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 20.0),
//         child: Container(
//           width: 100, // Adjust the width as needed
//           height: 35, // Adjust the height as needed
//           child: FloatingActionButton(
//             onPressed: () {
//               Navigator.pushNamed(context, '/customP');

//               // Handle menu button press
//             },
//             backgroundColor: Colors.red,
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(50), // Adjust the radius as needed
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center, // Center the content
//               children: [
//                 Icon(Icons.menu, size: 15, color: Colors.white),
//                 SizedBox(width: 10),
//                 Text('Menu',
//                     style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPromoText(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(Icons.check, color: Colors.green),
//           SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;

//   _SliverAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return SizedBox.expand(child: child);
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }

// class PromoItem extends StatefulWidget {
//   final String title;
//   final String price;
//   final String imageAsset;
//   final bool hasCustomOption;

//   PromoItem({
//     required this.title,
//     required this.price,
//     required this.imageAsset,
//     required this.hasCustomOption,
//   });

//   @override
//   _PromoItemState createState() => _PromoItemState();
// }

// class _PromoItemState extends State<PromoItem> {
//   int _count = 0;

//  void _incrementCount() {
//     setState(() {
//       _count++;
//       final parentState = context.findAncestorStateOfType<_CheckoutScreenState>();
//       parentState?._incrementItemCount();
//     });
//   }

//   void _decrementCount() {
//     setState(() {
//       if (_count > 0) _count--;
//       final parentState = context.findAncestorStateOfType<_CheckoutScreenState>();
//       parentState?._decrementItemCount();
//     });
//   }
//   Color _containerColor = Colors.white;
//   int count = 0;

//   void _toggleColor() {
//     setState(() {
//       _containerColor = Colors.grey;
//     });

//     Future.delayed(Duration(milliseconds: 200), () {
//       setState(() {
//         _containerColor = Colors.white;
//       });
//     });
//   }

//   void _showBottomSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) {
//         return FractionallySizedBox(
//           heightFactor:
//               0.6, // Mengatur tinggi bottom sheet menjadi 90% dari tinggi layar
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   elevation: 2,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.asset(
//                       widget.imageAsset,
//                       height: 320,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 Text(
//                   widget.title,
//                   style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   widget.price,
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     _buildIconWithText(
//                       icon: Icons.favorite_border,
//                       text: 'Favorit',
//                       onTap: () {
//                         // Tambahkan aksi ketika ikon Favorit diklik
//                       },
//                     ),
//                     Row(
//                       children: [
//                         _buildIconWithText(
//                           icon: Icons.report,
//                           text: 'Lapor',
//                           onTap: () {
//                             // Tambahkan aksi ketika ikon Laporkan diklik
//                           },
//                         ),
//                         SizedBox(width: 16),
//                         _buildIconWithText(
//                           icon: Icons.share,
//                           text: 'Bagikan',
//                           onTap: () {
//                             // Tambahkan aksi ketika ikon Bagikan diklik
//                             print('berhasil');
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 Spacer(),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _incrementCount,
//                     child: Text(
//                       'Tambah pembelian',
//                       style: TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: const Color.fromARGB(255, 60, 151, 63),
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         _toggleColor();
//         _showBottomSheet(context);
//       },
//       child: Transform.translate(offset: Offset(0, 0),
//       child: Container(
//         padding: EdgeInsets.all(16),
//         height: 200,
//         decoration: BoxDecoration(
//           color: _containerColor,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 1,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//                       Transform.translate(offset: Offset(0, 0),

//             child: Padding(
//               padding: const EdgeInsets.only(
//                   right: 150), // Adjust with image width + padding
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.title,
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     widget.price,
//                     style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black),
//                   ),
//                   SizedBox(height: 16),
//                 ],
//               ),
//             ),
//                       ),
//             Positioned(
//               right: 0,
//               top: 0,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
                
//                 children: [
//                   Transform.translate(offset: Offset(0, -25),
//                   child: GestureDetector(
//                     onTap: () {
//                       // Handle card tap
//                       print("Card tapped!");
//                     },
//                     child: Card(
//                       color: Colors.white,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: Image.asset(
//                           widget.imageAsset,
//                           height: 130,
//                           width: 140,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                   ),
//                   Transform.translate(
//                     offset: Offset(0, -40),
//                     child: Column(
//                       children: [
//                         if (_count == 0)
//                           OutlinedButton(
//                            onPressed: () {
//                               _incrementCount();
//                               // Call the visibility toggle function here
//                               final parentState = context.findAncestorStateOfType<_CheckoutScreenState>();
//                               parentState?._toggleBottomBarVisibility();
//                             },
//                             child: Text(
//                               'Tambah',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color.fromRGBO(21, 85, 41, 1),
//                               ),
//                             ),
//                             style: OutlinedButton.styleFrom(
//                               side: BorderSide(
//                                   color: const Color.fromRGBO(21, 85, 41, 1)),
//                               backgroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 50, vertical: 0),
//                             ),
//                           ),
//                         if (_count > 0)
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(50),
//                               border: Border.all(
//                                 color: const Color.fromARGB(255, 75, 170, 105),
//                                 width: 1.2,
//                               ),
//                             ),
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 1, vertical: 4),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Container(
//                                   margin: EdgeInsets.symmetric(
//                                       horizontal: 12, vertical: 0),
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.white,
//                                     border: Border.all(
//                                       color: Colors.green,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(Icons.remove,
//                                         color: Colors.green, size: 20),
//                                      onPressed: () {
//                               _decrementCount();
//                               // Call the visibility toggle function here
//                               final parentState = context.findAncestorStateOfType<_CheckoutScreenState>();
//                               parentState?._toggleBottomBarVisibilit();
//                             },
//                                   ),
//                                 ),
//                                 Text(
//                                   '$_count',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Container(
//                                   margin: EdgeInsets.symmetric(horizontal: 12),
//                                   width: 40,
//                                   height: 40,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.white,
//                                     border: Border.all(
//                                       color: Colors.green,
//                                       width: 1.5,
//                                     ),
//                                   ),
//                                   child: IconButton(
//                                     icon: Icon(Icons.add,
//                                         color: Colors.green, size: 20),
//                                     onPressed: _incrementCount,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       ),
//     );
    
//   }
// }

// Widget _buildIconWithText({
//   required IconData icon,
//   required String text,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: Row(
//         mainAxisSize:
//             MainAxisSize.min, // Pastikan ukuran Row hanya sebesar konten
//         children: [
//           Icon(
//             icon,
//             color: Colors.black, // Warna ikon
//             size: 17, // Ukuran ikon
//           ),
//           SizedBox(width: 4),
//           Text(
//             text,
//             style: TextStyle(
//               fontWeight: FontWeight.bold, // Membuat teks menjadi bold
//               fontSize: 15, // Ukuran teks
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
