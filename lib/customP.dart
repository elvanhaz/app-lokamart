import 'package:flutter/material.dart';

void main() {
  runApp(const CustomPurchaseApp());
}

class CustomPurchaseApp extends StatelessWidget {
  const CustomPurchaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SambalSelectionScreen(),
    );
  }
}

class SambalSelectionScreen extends StatefulWidget {
  const SambalSelectionScreen({super.key});

  @override
  _SambalSelectionScreenState createState() => _SambalSelectionScreenState();
}

class _SambalSelectionScreenState extends State<SambalSelectionScreen> {
  String? _selectedSambal;
  int _quantity = 1;
  final int _pricePerItem = 50000;
  final TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Custom Pembelian', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Handle back button press
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Transform.translate(
              offset: const Offset(0, 20),
            ),
            Container(
              width: double.infinity,
              height: 70,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(229, 36, 53, 1),
              ),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Paket Gajian 2 Nasi Geprek',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '25.000',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow offset
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Pilihan Sambal Makanan 1',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87, // Text color for better readability
                        ),
                      ),
                    ),
                    const SizedBox(height: 4), // Space between texts
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Harus dipilih - Pilih 1',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    const Divider(),
                    Column(
                      children: [
                        _buildOption('Sambal Korek Jontor'),
                        _buildOption('Sambal Matah'),
                        _buildOption('Sambal Ori'),
                        _buildOption('Sambal Kecombrang'),
                        _buildOption('Sambal Kacang Goyang Lidah'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
           Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow offset
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text(
      'Catatan Tambahan',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87, // Text color for better readability
      ),
    ),
    const SizedBox(height: 2), // Spasi antara teks
    const Text(
      'Opsional',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.black54, // Text color for less emphasis
      ),
    ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLength: 200,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.note),
                          hintText: 'Contoh: banyakin porsinya, ya',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.grey),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah pembelian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 30, color: Colors.green,),
                        onPressed: _quantity > 1
                            ? () {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            : null,
                      ), 
                      Text(
                        _quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 30, color: Colors.green,),
                        onPressed: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 50,
              margin: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(193, 31, 134, 34),
                ),
                onPressed: () {
                  // Handle add to cart
                },
                child: Text(
                  'Tambah pembelian - ${_quantity * _pricePerItem}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0), // Align text to right
          title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black), ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gratis', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(width: 0), // Adjust the space between text and radio button
              Radio<String>(
                value: title,
                groupValue: _selectedSambal,
                onChanged: (String? value) {
                  setState(() {
                    _selectedSambal = value;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
