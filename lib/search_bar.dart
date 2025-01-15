import 'package:loka/hasil_search.dart';
import 'package:flutter/material.dart';

class ppp extends StatelessWidget {
  const ppp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchBarScreen(),
      routes: {
        '/hasilsearch': (context) => SearchHasilPage(),
      },
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
    );
  }
}

class SearchBarScreen extends StatelessWidget {
  const SearchBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Kode untuk aksi kembali
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari di sini...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50.0),
                borderSide: BorderSide.none,
              ),
              prefixIcon: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/hasilsearch');
                },
                child: const Icon(Icons.search, color: Colors.black),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 20.0),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hasil pencarian kamu',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  _buildChip('holland'),
                  _buildChip(
                      'holand bakery jalan hos cokroaminoto no.158d kreo'),
                  _buildChip('bakwan malang'),
                  _buildChip('mie gac'),
                  _buildChip('mie'),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Baru aja kamu cari',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              _buildRecentSearchCard(
                'assets/1.jpg', // Ganti dengan gambar yang sesuai
                'Kopi Dua Belas, stadion pakansari ...',
                '0.8 km · 25-35 min',
              ),
              // Tambahkan elemen lain jika diperlukan

              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'loka dengan rating jempolan',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10.0)),
                                      child: Image.asset(
                                        'assets/1.jpg',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        color: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: const Text(
                                          '70% off',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'KABOBS - Premium Kebab, Cibinong ...',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.orange, size: 20),
                                      Text('4.9'),
                                      Spacer(),
                                      Text('2.6 km'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0), // Spacing between cards
                        Expanded(
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10.0)),
                                      child: Image.asset(
                                        'assets/1.jpg',
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      left: 8,
                                      child: Container(
                                        color: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 2),
                                        child: const Text(
                                          '70% off',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Ayam Koplo, Nasi Geprek, Cibinong',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.star,
                                          color: Colors.orange, size: 20),
                                      Text('4.9'),
                                      Spacer(),
                                      Text('2.1 km'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Paling banyak dicari',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    const Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        Chip(label: Text('mcd')),
                        Chip(label: Text('kfc')),
                        Chip(label: Text('sate')),
                        Chip(label: Text('pizza')),
                        Chip(label: Text('hokben')),
                        Chip(label: Text('seblak')),
                        Chip(label: Text('pempek')),
                        Chip(label: Text('martabak')),
                        Chip(label: Text('mie ayam')),
                        Chip(label: Text('nasi goreng')),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Eksplor aneka kuliner',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildCategoryItem('assets/1.jpg', 'Minuman'),
                        _buildCategoryItem('assets/1.jpg', 'Jajanan'),
                        _buildCategoryItem('assets/1.jpg', 'Sweets'),
                        _buildCategoryItem('assets/1.jpg', 'Aneka nasi'),
                        _buildCategoryItem('assets/1.jpg', 'Ayam & bebek'),
                        _buildCategoryItem('assets/1.jpg', 'Cepat saji'),
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
}

Widget _buildChip(String label) {
  return Chip(
    label: Text(
      label,
      style: const TextStyle(color: Colors.black),
    ),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Color.fromARGB(255, 223, 216, 216))),
  );
}

Widget _buildRecentSearchCard(String imagePath, String title, String subtitle) {
  return SizedBox(
    width: 200, // Tetapkan lebar tetap untuk kartu
    child: Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: AspectRatio(
                aspectRatio: 1.5, // Menjaga rasio aspek gambar
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
            const SizedBox(height: 4.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCategoryItem(String imagePath, String title) {
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Image.asset(
          imagePath,
          height: 80,
          width: 80,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(height: 8.0),
      Text(title),
    ],
  );
}
