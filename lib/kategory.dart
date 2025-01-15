import 'dart:async';
import 'package:loka/search_bar.dart';
import 'package:loka/views/checkout.dart';
import 'package:flutter/material.dart';
import 'package:loka/checkout.dart';

class KategoryPage extends StatelessWidget {
  const KategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Kategory(),
      routes: {
        '/checkout': (context) => const CheckoutPage(
              paymentData: {},
            ),
        // '/searchbar': (context) => SearchPage(),
      },
    );
  }
}

class Kategory extends StatefulWidget {
  const Kategory({super.key});

  @override
  _KategoryState createState() => _KategoryState();
}

class _KategoryState extends State<Kategory> {
  final PageController _pageController = PageController();
  late Timer _timer;
  final List<Map<String, String>> items = [
    {
      'image': 'assets/slide7.jpeg',
      'label': 'Ayam Koplo, Nasi Geprek, Cibinong',
      'distance': '1.30 km',
      'rating': '4.9',
      'discount': '50% off',
    },
    {
      'image': 'assets/slide7.jpeg',
      'label': 'Ayam Koplo, Nasi Geprek, Cibinong',
      'distance': '1.30 km',
      'rating': '4.9',
      'discount': '50% off',
    },
    {
      'image': 'assets/slide6.jpeg',
      'label': 'Moon Chicken (Ayam Goreng Kor...)',
      'distance': '1.30 km',
      'rating': '4.8',
      'discount': '50% off',
    },
    {
      'image': 'assets/slide2.jpeg',
      'label': 'Nasi Goreng Gila, Depok',
      'distance': '1.50 km',
      'rating': '4.7',
      'discount': '30% off',
    },
    {
      'image': 'assets/slide4.jpg',
      'label': 'Bakso Granat, Jakarta',
      'distance': '2.00 km',
      'rating': '4.6',
      'discount': '40% off',
    },
    {
      'image': 'assets/slide3.jpeg',
      'label': 'Sate Ayam, Bogor',
      'distance': '2.50 km',
      'rating': '4.5',
      'discount': '20% off',
    },
    {
      'image': 'assets/slide2.jpeg',
      'label': 'Pecel Lele, Tangerang',
      'distance': '3.00 km',
      'rating': '4.4',
      'discount': '10% off',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.page == 2) {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      } else {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
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
                  const Text(
                    'Pilih Lokasi',
                    style: TextStyle(
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
                        label: const Text(
                          'Lokasimu saat ini',
                          style: TextStyle(color: Color.fromARGB(162, 0, 0, 0)),
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
                        label: const Text(
                          'Pilih lewat peta',
                          style: TextStyle(color: Color.fromARGB(162, 0, 0, 0)),
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
                  const Text(
                    'Alamat favorit',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: PageView(
                controller: _pageController,
                children: [
                  Image.asset('assets/slide1.jpeg', fit: BoxFit.cover),
                  Image.asset('assets/slide4.jpg', fit: BoxFit.cover),
                  Image.asset('assets/slide3.jpeg', fit: BoxFit.cover),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            actions: [
              GestureDetector(
                onTap: () => _showLocationModal(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  margin: const EdgeInsets.only(
                      right: 16.0, top: 12.0, bottom: 7.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 20.0),
                      SizedBox(width: 4.0),
                      Text(
                        'Jl. Raya Bogor, No.KM 46',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Warna fill putih
                ),
                child: IconButton(
                  icon: Icon(Icons.favorite,
                      color: Colors.black.withOpacity(0.5)),
                  onPressed: () {},
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // Warna fill putih
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart,
                      color: Colors.black.withOpacity(0.5)),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 60.0,
              maxHeight: 60.0,
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.fromLTRB(
                    16, 10, 16, 5), // Adjust top margin to raise the position
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
                          Navigator.pushNamed(context, '/searchbar');
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
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(height: 20), // Adjust height as needed
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CategoryButton(
                        label: 'Driver\nCabang',
                        icon: 'assets/gojekk.png',
                      ),
                      CategoryButton(
                        label: 'Cabang\nTerdekat',
                        icon: 'assets/maps.png',
                      ),
                      CategoryButton(
                        label: 'Paling\nAndalan',
                        icon: 'assets/award1.png',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Menu Paling Andalan',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: PageView.builder(
                          itemCount: (items.length / 2).ceil(),
                          itemBuilder: (context, pageIndex) {
                            int firstIndex = pageIndex * 2;
                            int secondIndex = firstIndex + 1;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child:
                                        buildCard(context, items[firstIndex]),
                                  ),
                                  if (secondIndex < items.length)
                                    const SizedBox(width: 8),
                                  if (secondIndex < items.length)
                                    Expanded(
                                      child: buildCard(
                                          context, items[secondIndex]),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aneka kuliner menarik',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CategoryIcon(
                              label: 'Minuman',
                              imagePath: 'assets/minuman.png'),
                          CategoryIcon(
                              label: 'Jajanan',
                              imagePath: 'assets/cemilan.jpg'),
                          CategoryIcon(
                              label: 'Sweets',
                              imagePath: 'assets/makanan.jpeg'),
                          CategoryIcon(
                              label: 'Aneka nasi',
                              imagePath: 'assets/anekanasi.jpg'),
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
    );
  }
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
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

Widget buildCard(BuildContext context, Map<String, String> item) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, '/checkout');
    },
    child: Transform.translate(
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: Image.asset(
                    item['image']!, // Replace with your image path
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 220,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.red,
                    child: Text(
                      item['discount']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  10, 10, 1, 10), // Adjust bottom padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['label']!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(item['distance']!),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      Text(item['rating']!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
            style: const TextStyle(
              fontSize: 15, // Adjust the font size
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
