import 'package:flutter/material.dart';

class DiskonPage extends StatelessWidget {
  const DiskonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Diskon(),
    );
  }
}

class Diskon extends StatefulWidget {
  const Diskon({super.key});

  @override
  _DiskonState createState() => _DiskonState();
}

class _DiskonState extends State<Diskon> {
  bool _isUsed = false; // State untuk melacak apakah promo sudah dipakai

  void _togglePromo() {
    setState(() {
      _isUsed = !_isUsed; // Toggle state ketika tombol diklik
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: Colors.white,
      appBar: AppBar(
backgroundColor: Colors.white,        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Promo delivery',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.black),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pilih satu yang kamu mau',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Promo terbaik buat pesananmu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 10),
          _buildPromoCard(
            title: 'Diskon makanan 45%, maks. 36rb',
            subtitle: 'Min. pembelian 45rb',
            isBest: true,
            actionText: _isUsed ? 'Batalin' : 'Pakai',
          ),
          const SizedBox(height: 50),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.green,
                borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1 item',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Diantar dari Payung Hujan Ayam Gepr...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '50.000',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoCard({
    required String title,
    required String subtitle,
    bool isBest = false,
    String? actionText,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Box hijau (Layer 2) hanya muncul jika promo sudah dipakai
        if (_isUsed)
          Positioned(
            bottom: -25, // Offset the green box upwards
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16), // Adjust padding to control position
                height: 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Terpasang',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _togglePromo, // Toggle state ketika tombol diklik
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.red), // Tambahkan side pada Batalin
                          ),
                        ),
                        child: const Text('Batalin', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // Box putih utama (Layer 1)
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Kotak hijau berada di belakang
            if (!_isUsed)
              Positioned(
                top: 105, // Sesuaikan posisi agar terlihat tenggelam di belakang
                left: 0,
                right: 0,
                child: Container(
                  height: 75,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(112, 113, 212, 171),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              SizedBox(width: 4),
                              Text(
                                'Siap Pakai',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _togglePromo, // Toggle state ketika tombol diklik
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Colors.black), // Tambahkan side pada Batalin
                              ),
                            ),
                            child: const Text(
                              'Pakai',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Kotak utama berada di depan
            Container(
              height: 130,
              margin: const EdgeInsets.only(bottom: 24), // Space for the green box
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: _isUsed ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
