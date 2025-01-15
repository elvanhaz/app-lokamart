import 'package:loka/detail_alamat.dart';
import 'package:loka/diskon.dart';
import 'package:flutter/material.dart';

class PemesananPage extends StatelessWidget {
  const PemesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Pemesanan(),
      routes: {
        '/detail_alamat': (context) => DetailAlamatPage(),
        '/diskon': (context) => DiskonPage(),
      },
    );
  }
}

class Pemesanan extends StatefulWidget {
  const Pemesanan({super.key});

  @override
  _PemesananState createState() => _PemesananState();
}

class _PemesananState extends State<Pemesanan> {
  bool isDeliverySelected = true;

  void _showModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih tipe pembelian',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            isDeliverySelected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          decoration: BoxDecoration(
                            color: isDeliverySelected
                                ? Colors.green[50]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDeliverySelected
                                  ? Colors.green
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDeliverySelected
                                      ? Colors.green
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.delivery_dining,
                                  color: isDeliverySelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delivery',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDeliverySelected
                                      ? Colors.green
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setModalState(() {
                            isDeliverySelected = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          decoration: BoxDecoration(
                            color: !isDeliverySelected
                                ? Colors.green[50]
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !isDeliverySelected
                                  ? Colors.green
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: !isDeliverySelected
                                      ? Colors.green
                                      : const Color.fromARGB(255, 54, 148, 65),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Icons.shopping_bag,
                                  color: !isDeliverySelected
                                      ? Colors.white
                                      : const Color.fromARGB(
                                          255, 253, 253, 253),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pickup',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: !isDeliverySelected
                                      ? Colors.green
                                      : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8), // Spasi antara ikon dan teks
                        Text(
                          'Ketersediaan promo tergantung pada tipe pembelian',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Gak jadi',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Aksi ketika tombol Konfirmasi ditekan
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  int _selectedDeliveryOption = 0;
  bool _isBalanceVisible = true;
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          'Bubur Ayam Cianjur Kang Adul, Cibin...',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.thumb_up_alt_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -25),
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Icon(Icons.calendar_today, color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(
                              bottom: 50.0), // Menyesuaikan jarak dari bawah
                          child: Text(
                            'Mau ngejadwalin delivery? Klik "Ganti"',
                            style: TextStyle(color: Colors.green, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -50),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(125, 207, 205, 205)),
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                                8.0), // Jarak di sekitar ikon
                            decoration: const BoxDecoration(
                              color: Colors.blue, // Warna latar belakang
                              shape: BoxShape.circle, // Bentuk lingkaran
                            ),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: Colors.white, // Warna ikon
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text('Delivery',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => _showModal(context),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 1, horizontal: 9),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.green),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Ganti ',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 34, 83, 36),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -25),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                            color: const Color.fromARGB(255, 236, 235, 235)),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Express',
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500)),
                                        SizedBox(width: 8),
                                        Text('25 min',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Color.fromARGB(
                                                    255, 215, 206, 206))),
                                      ],
                                    ),
                                    Text('Driver hanya antar pesanamu',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                const Text(' 22.500',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(width: 0),
                                Radio(
                                  value: 0,
                                  groupValue: _selectedDeliveryOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDeliveryOption = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                              color: Color.fromARGB(
                                  255, 227, 226, 226)), // Pemisah garis
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: [
                                const Row(
                                  children: [
                                    Text('Reguler',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500)),
                                    SizedBox(width: 8),
                                    Text('25 min',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Color.fromARGB(
                                                255, 215, 206, 206))),
                                  ],
                                ),
                                const Spacer(),
                                const Text(' 20.500',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                Radio(
                                  value: 1,
                                  groupValue: _selectedDeliveryOption,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDeliveryOption = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text('Alamat Pengantaran',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jl. Raya Bogor No.KM 46',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: ElevatedButton(
                                onPressed: () => _showLocationModal(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 1, horizontal: 16),
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(
                                      color: Color.fromARGB(255, 51, 126, 54)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Ganti alamat',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 34, 83, 36),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 232, 142, 7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info,
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                      'Isi detail alamat biar driver gampang cari lokasimu pas antar makanan.',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11))),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(255, 240, 238,
                                        238)), // Menambahkan garis border
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius untuk TextButton.icon pertama
                              ),
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, '/detail_alamat');
                                },
                                icon: const Icon(Icons.edit_location,
                                    color: Colors.black),
                                label: const Text('Isi detail alamat',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(
                                width: 8), // Jarak antara kedua TextButton.icon
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(255, 240, 238,
                                        238)), // Menambahkan garis border
                                borderRadius: BorderRadius.circular(
                                    30), // Border radius untuk TextButton.icon kedua
                              ),
                              child: TextButton.icon(
                                onPressed: () {},
                                icon:
                                    const Icon(Icons.note, color: Colors.black),
                                label: const Text('Catatan',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Element lainnya...
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sate Telor Puyuh',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('4.000',
                                      style: TextStyle(fontSize: 14)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 1,
                                        horizontal:
                                            2), // Atur padding sesuai kebutuhan
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 234, 233, 233)),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: TextButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.note,
                                          color: Colors.black),
                                      label: const Text('Catatan',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Image.network(
                                  'https://via.placeholder.com/50',
                                  width: 50,
                                  height: 50,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.green),
                                      onPressed: _decrementQuantity,
                                    ),
                                    Text('$_quantity',
                                        style: const TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline,
                                          color: Colors.green),
                                      onPressed: _incrementQuantity,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Element lainnya...
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Ringkasan pembayaran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Harga'),
                              Text('4.000'),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Biaya Penanganan dan Pengiriman'),
                              Text('20.500'),
                            ],
                          ),
                          Divider(height: 40.0, color: Colors.grey.shade400),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total pembayaran',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '24.500',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 20),
                          child: Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(125, 207, 205, 205)),
                              borderRadius: BorderRadius.circular(15),
                              color: const Color.fromARGB(255, 247, 243, 243),
                            ),
                            child: Row(
                              children: [
                                Transform.translate(
                                  offset: const Offset(0, -15),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(Icons.local_offer,
                                        color: Colors.red),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Diskon makanan 60%',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Promo terbaik untukmu',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Transform.translate(
                                  offset: const Offset(0, -10),
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side:
                                          const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Pasang',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        125, 207, 205, 205)),
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/diskon');
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'Cek promo lainnya',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(Icons.arrow_forward,
                                        color: Colors.green),
                                  ],
                                ),
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isBalanceVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black, // Background color
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Sisa Saldo: Rp 1000', // Replace with dynamic value
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _toggleBalanceVisibility,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 140,
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10),
              // Icons Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Align(
                      alignment: Alignment
                          .centerLeft, // Menempatkan teks di pojok kiri
                      child: Text(
                        'Pilih Pembayaran', // Teks di sebelah kiri
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: 210,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          _showPaymentOptions(context);
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        // Column(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: <Widget>[
                        //     Icon(Icons.monetization_on, color: Colors.blue),
                        //   ],
                        // ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        //     // Padding(
                        //     //   padding: const EdgeInsets.only(bottom: 1.0),
                        //     //   child: Text(
                        //     //     'Go Pay Coins',
                        //     //     style:
                        //     //         TextStyle(color: Colors.black, fontSize: 12),
                        //     //   ),
                        //     // ),
                        //     Padding(
                        //       padding: const EdgeInsets.only(bottom: 1.0),
                        //       child: Text(
                        //         '1',
                        //         style:
                        //             TextStyle(color: Colors.black, fontSize: 12),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(width: 12),
                        // Text(
                        //   '+',
                        //   style: TextStyle(color: Colors.black, fontSize: 12),
                        // ),
                        // SizedBox(width: 25),
                        // Column(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: <Widget>[
                        //     Icon(Icons.savings, color: Colors.blue),
                        //   ],
                        // ),
                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: <Widget>[
                        //     Padding(
                        //       padding: const EdgeInsets.only(bottom: 1.0),
                        //       child: Text(
                        //         'Go Pay Coins',
                        //         style:
                        //             TextStyle(color: Colors.black, fontSize: 12),
                        //       ),
                        //     ),
                        //     Padding(
                        //       padding: const EdgeInsets.only(bottom: 1.0),
                        //       child: Text(
                        //         '27',
                        //         style:
                        //             TextStyle(color: Colors.black, fontSize: 12),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Buy Now Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 62, 188, 56),
                      padding:
                          EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                    ),
                    child: Text(
                      'Beli dan antar sekarang',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.9, // Atur tinggi modal agar hampir full layar
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih lokasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(221, 219, 219, 219),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 0.1, horizontal: 10.0),
                  hintText: 'Cari alamat',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 189, 187, 187)),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.my_location,
                      size: 15,
                      color: Colors.orange,
                    ),
                    label: const Text(
                      'Lokasimu saat ini',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: Color.fromARGB(255, 230, 227, 227)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.map,
                      color: Colors.green,
                      size: 15,
                    ),
                    label: const Text(
                      'Pilih lewat peta',
                      style: TextStyle(color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: Color.fromARGB(255, 230, 227, 227)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alamat favorit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat semua',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildFavoriteAddress(context, 'qq',
                        'Jl. Raya Taman Pagelaran, Padasuka, Kec. Ciomas, Kabupaten Bogor, Jawa Barat, Indonesia'),
                    _buildFavoriteAddress(context, 'Rumah',
                        'Jl. Marjisyah No.109, RT.003/RW.2, Larangan Indah, Kec. Larangan, Kota Tangerang, Banten 15154, Indonesia'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoriteAddress(
      BuildContext context, String title, String address) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color.fromARGB(255, 202, 201, 201)),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Transform.translate(
                  offset: const Offset(0, 12),
                  child: const Icon(Icons.location_pin, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value) {
                          // Handle the selected option here
                          if (value == 'edit') {
                            // Edit action
                          } else if (value == 'delete') {
                            // Delete action
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Ubah'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.grey),
                                  SizedBox(width: 8),
                                  Text('Hapus'),
                                ],
                              ),
                            ),
                          ];
                        },
                        icon: const Icon(Icons.more_horiz),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 4.0),
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12),
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

  void _showPaymentOptions(BuildContext context) {
    bool? selectedPaymentMethod; // Variable to hold the selected payment method
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 450, // Adjusted height to fit new content
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Pilih Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Transfer Bank (Verifikasi Manual)',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Bank BCA'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Bank MANDIRI'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Bank BNI'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Bank BRI'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                const SizedBox(height: 16.0),
                const Text(
                  'Tunai di Gerai Retail',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Alfamart / Alfamidi / Lawson / Dan+Dan'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Indomaret / Ceriamart'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('JNE'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Image.asset('assets/1.jpg', width: 40),
                  title: const Text('Kantorpos'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Action when tapped
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.attach_money,
                      size: 40, color: Colors.green),
                  title: const Text('Tunai'),
                  trailing: Radio<bool?>(
                    value: true, // This will be the value for the radio button
                    groupValue: selectedPaymentMethod,
                    onChanged: (bool? value) {
                      // Handle radio button selection
                      selectedPaymentMethod = value;
                      Navigator.pop(context); // Close the modal after selection
                    },
                  ),
                  onTap: () {
                    // Handle when tapped
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(PemesananPage());
}
