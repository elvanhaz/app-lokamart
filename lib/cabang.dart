import 'package:loka/kategory.dart';
import 'package:flutter/material.dart';

class CabangPage extends StatelessWidget {
  const CabangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: cabang(),
    );
  }
}

class cabang extends StatelessWidget {
  final List<Map<String, dynamic>> outlets = [
    {
      'name': 'Melawai',
      'address': 'Jl. Melawai Raya No. 3, Jakarta Selatan',
      'hours': '09:30 - 19:30',
      'image': 'assets/150.png', // Replace with actual image path
      'onPressed': (context) {
        // Define what happens when this outlet is pressed
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KategoryPage()));
      },
    },
    {
      'name': 'Soho Pancoran',
      'address':
          'Soho Pancoran, Lantai GF unit GF-07. Jl. MT Haryono Street No. Kav. 2-3, Jakarta Selatan',
      'hours': '09:30 - 20:30',
      'image': 'assets/150.png', // Replace with actual image path
      'onPressed': (context) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KategoryPage()));
      },
    },
    {
      'name': 'Electronic City',
      'address': 'Gedung EC Lt. 2 SCBD Sudirman, Jakarta Selatan',
      'hours': '09:50 - 20:00',
      'image': 'assets/150.png', // Replace with actual image path
      'onPressed': (context) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KategoryPage()));
      },
    },
    {
      'name': 'Gramedia Matraman',
      'address':
          'Gramedia Matraman Lantai GF, Jl. Matraman Raya No.46-50, Jakarta 13150',
      'hours': '09:00 - 20:30',
      'image': 'assets/150.png', // Replace with actual image path
      'onPressed': (context) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KategoryPage()));
      },
    },
    {
      'name': 'Grand Indonesia',
      'address':
          'Grand Indonesia Food Street Lantai 5, Jalan M.H. Thamrin No.1, Kebon Melati, Tanah Abang, Kota Jakarta Pusat',
      'hours': '10:00 - 21:00',
      'image': 'assets/150.png', // Replace with actual image path
      'onPressed': (context) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const KategoryPage()));
      },
    },
  ];

  cabang({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('South Tangerang City'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Outlet',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: outlets.length,
              itemBuilder: (context, index) {
                final outlet = outlets[index];
                return ListTile(
                  leading: Image.asset(
                    outlet['image']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(outlet['name']!),
                  isThreeLine: true,
                  onTap: () {
                    outlet['onPressed']!(
                        context); // Call the onPressed function
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final String name;

  const DetailsPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Text('Details for $name'),
      ),
    );
  }
}
