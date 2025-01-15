import 'package:flutter/material.dart';

class SearchHasilPage extends StatelessWidget {
  const SearchHasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HasilSearch(),
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
    );
  }
}

class HasilSearch extends StatelessWidget {
  const HasilSearch({super.key});

  @override
  Widget build(BuildContext context) {
    void showFilterModal(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return const FilterModal();
        },
      );
    }

    Widget buildListItem({
      required String imagePath,
      required String title,
      required String rating,
      required String category,
      required String deliveryTime,
      required String distance,
      Widget? additionalWidget,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Box Direction (70% off)
                    Positioned(
                      bottom: -40,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          const SizedBox(
                              height: 10), // Adding space between elements
                          Transform.translate(
                            offset: const Offset(0, 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.3, // Responsive width
                              height: 70, // Adjust height to your preference
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 231, 133, 6),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20.0),
                                  bottomRight: Radius.circular(20.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, -3),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              alignment: Alignment
                                  .bottomCenter, // Align the text to the bottom center
                              child: const Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        5.0), // Adjust bottom padding as needed
                                child: Text(
                                  '70% off',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Image
                    Transform.translate(
                      offset: const Offset(0, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          imagePath,
                          width: MediaQuery.of(context).size.width *
                              0.3, // Responsive width
                          height: MediaQuery.of(context).size.width *
                              0.2, // Responsive height
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Rating
                    Positioned(
                      top: MediaQuery.of(context).size.width * 0.2 -
                          12, // Adjust position to align with the bottom of the image
                      left: 37,
                      right: 37,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.1, // Responsive width
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0.0, vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 0.0),
                            Text(
                              rating,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0), // Adjusted space
                      Text(
                        category,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8.0), // Adjusted space
                      Text(
                        'Diantar dalam $deliveryTime • $distance',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8.0), // Adjusted space
                      const Text(
                        'Diskon 70%, maks. 40rb',
                        style: TextStyle(color: Colors.black),
                      ),
                      if (additionalWidget != null) ...[
                        const SizedBox(height: 8.0),
                        additionalWidget,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0), // Space between list items
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      appBar: AppBar(
        backgroundColor: Colors.white, // Set AppBar background color to white
        automaticallyImplyLeading: false, // Remove the default back button
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.black), // Back arrow icon
              onPressed: () {},
            ),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(20.0), // Rounded border
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 11, 11,
                            11)), // Add border around the container
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'holland',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(48.0), // Desired height for chip row
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.tune,
                        color: Colors.black), // Filter icon
                    onPressed: () {
                      showFilterModal(context);
                    },
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: const Text('Terdekat'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: const Text('Bintang 4.5+'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Chip(
                    label: const Text('Kuliner'),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildListItem(
              imagePath: 'assets/1.jpg',
              title: 'PISANG GORENG LAURENSI...',
              rating: '4.7',
              category: 'Jajanan, Sweets',
              deliveryTime: '35-45 min',
              distance: '4.0 km',
            ),
            buildListItem(
              imagePath: 'assets/1.jpg',
              title: 'Holland Bakery, Cibinong',
              rating: '4.7',
              category: 'Roti, Jajanan',
              deliveryTime: '30-40 min',
              distance: '5.2 km',
              additionalWidget: ElevatedButton(
                onPressed: () {},
                child: const Text('Lihat cabang lain'),
              ),
            ),
            buildListItem(
              imagePath: 'assets/1.jpg',
              title: 'ARS Bolu Klapertart & Lekker ...',
              rating: '4.5',
              category: 'Sweets, Jajanan, Roti',
              deliveryTime: '35-45 min',
              distance: '6.1 km',
            ),
            buildListItem(
              imagePath: 'assets/1.jpg',
              title: 'Hofland Cafe & loka',
              rating: '4.4',
              category: 'Ayam & bebek, Pizza & pasta, Barat',
              deliveryTime: '40-50 min',
              distance: '10.6 km',
            ),
            buildListItem(
              imagePath: 'assets/1.jpg',
              title: 'Zaro Bakery, Duren Baru',
              rating: '4.5',
              category: 'Roti',
              deliveryTime: '35-45 min',
              distance: '6.2 km',
            ),
          ],
        ),
      ),
    );
  }
}

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  int _selectedCuisine = -1; // No radio button selected initially
  bool _isCheckedBelow16 = false;
  bool _isChecked16to40 = false;
  bool _isChecked40to100 = false;
  bool _isCheckedAbove100 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 4,
        child: Container(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Action for "Hapus filter" button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Hapus filter',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Action for "Pasang" button
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Pasang',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -3),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Filter loka',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Urutkan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: [
                  ChoiceChip(
                    label: const Text('Terdekat'),
                    selected: true,
                    onSelected: (bool selected) {},
                    selectedColor: Colors.grey[200],
                    backgroundColor: Colors.grey[200],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Rentang harga',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Di bawah Rp16.000'),
                      ),
                      Checkbox(
                        value: _isCheckedBelow16,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCheckedBelow16 = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Rp16.000 sampai Rp40.000'),
                      ),
                      Checkbox(
                        value: _isChecked16to40,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked16to40 = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Rp40.000 sampai Rp100.000'),
                      ),
                      Checkbox(
                        value: _isChecked40to100,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked40to100 = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Di atas Rp100.000'),
                      ),
                      Checkbox(
                        value: _isCheckedAbove100,
                        onChanged: (bool? value) {
                          setState(() {
                            _isCheckedAbove100 = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Rating loka',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Bintang 4.0+'),
                      selected: false,
                      onSelected: (bool selected) {},
                      selectedColor: Colors.grey[200],
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Bintang 4.5+'),
                      selected: false,
                      onSelected: (bool selected) {},
                      selectedColor: Colors.grey[200],
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Diskonan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Promo makanan'),
                    selected: false,
                    onSelected: (bool selected) {},
                  ),
                  FilterChip(
                    label: const Text('Gojek PLUS'),
                    selected: false,
                    onSelected: (bool selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Lainnya',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Buka sekarang'),
                    selected: false,
                    onSelected: (bool selected) {},
                  ),
                  FilterChip(
                    label: const Text('Pickup'),
                    selected: false,
                    onSelected: (bool selected) {},
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Add the new section for "Jenis kuliner"
              const SizedBox(height: 8.0),
              const Text(
                'Jenis kuliner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    title: const Text('Semua kuliner'),
                    trailing: Radio<int>(
                      value: 0,
                      groupValue: _selectedCuisine,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedCuisine = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                    title: const Text('Minuman'),
                    trailing: Radio<int>(
                      value: 1,
                      groupValue: _selectedCuisine,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedCuisine = value!;
                        });
                      },
                    ),
                  ),
                  // Tambahkan item lainnya dengan pola yang sama
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
