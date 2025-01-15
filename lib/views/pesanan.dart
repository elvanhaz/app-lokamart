import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class PesananPage extends StatefulWidget {
  final String orderId;

  const PesananPage({super.key, required this.orderId});

  @override
  _PesananPageState createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  Map<String, dynamic>? pesananData;
  late DatabaseReference _firebaseRef;
  final MapController _mapController = MapController();
  LatLng _currentLocation = LatLng(-6.2088, 106.8456); // Default to Jakarta
  final LatLng _destinationLocation =
      LatLng(-6.2000, 106.8200); // Example destination
  final List<LatLng> _routePoints = [];
  String _estimatedArrivalTime = "Calculating...";
  final List<Marker> _markers = [];
  bool _mapLoaded = false;

  bool isOrderCompleted() {
    return pesananData?['status_pesanan'] == 'selesai';
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndLocation();
  }

  Future<void> _initializeFirebaseAndLocation() async {
    await Firebase.initializeApp();
    _firebaseRef = FirebaseDatabase.instance.ref().child('locations');
    await _fetchPesananData();
    _initializeMap();
    _listenToLocationChanges();
  }

  void _initializeMap() async {
    await _createMarkers();
    await _createRoute();
    _updateEstimatedTime();
  }

  Future<void> _createMarkers() async {
    _markers.add(Marker(
      point: _currentLocation,
      child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
    ));
    _markers.add(Marker(
      point: _destinationLocation,
      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
    ));
  }

  Future<void> _createRoute() async {
    // In a real app, you would use a routing service here
    // For this example, we'll just draw a straight line
    _routePoints.add(_currentLocation);
    _routePoints.add(_destinationLocation);
  }

  void _updateEstimatedTime() {
    // In a real app, you would calculate this based on distance and average speed
    // This is a placeholder implementation
    int estimatedMinutes = 30; // Example fixed time
    setState(() {
      _estimatedArrivalTime = "$estimatedMinutes minutes";
    });
  }

  void _listenToLocationChanges() {
    _firebaseRef.child(widget.orderId).onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> locationData =
            event.snapshot.value as Map<dynamic, dynamic>;
        double lat = locationData['latitude'];
        double lng = locationData['longitude'];
        setState(() {
          _currentLocation = LatLng(lat, lng);
          if (_mapLoaded) {
            _updateMapLocation();
            _updateMarkerPosition();
            _createRoute(); // Update route with new current location
          }
        });
      }
    });
  }

  void _updateMarkerPosition() {
    setState(() {
      _markers.removeAt(0);
      _markers.insert(
          0,
          Marker(
            point: _currentLocation,
            child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
          ));
    });
  }

  void _updateMapLocation() {
    _mapController.move(_currentLocation, 14);
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Location permission blocked permanently, provide guidance to user
      print('Location permission blocked.');
    }
  }

  Color _getIconColor(int index) {
    String status = pesananData?['status_pesanan'] ?? '';
    if (status == 'diproses' && index <= 1) return Colors.blue;
    if (status == 'diantarkan' && index <= 2) return Colors.blue;
    if (status == 'selesai' && index <= 3) return Colors.blue;

    return Colors.grey;
  }

  Color _getDividerColor(int index) {
    String status = pesananData?['status_pesanan'] ?? '';
    if (status == 'diproses' && index <= 1) return Colors.blue;
    if (status == 'diantarkan' && index <= 2) return Colors.blue;
    if (status == 'selesai' && index <= 3) return Colors.blue;

    return Colors.grey;
  }

  double _getDividerThickness(int index) {
    String status = pesananData?['status_pesanan'] ?? '';
    if (status == 'diproses' && index <= 1) return 2;
    if (status == 'diantarkan' && index <= 2) return 2;
    if (status == 'selesai' && index <= 3) return 3;

    return 1;
  }

  Future<void> _fetchPesananData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('sanctumToken');

    try {
      final response = await http.get(
        Uri.parse(
            'https://loka-mart.demoaplikasi.web.id/api/v1/pesanan/detail/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          pesananData = json.decode(response.body)['data'];
        });
      } else {
        print('Gagal mengambil data pesanan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil data pesanan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isOrderCompleted()
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memproses',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Text('Melanjutkan pesananmu...',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              actions: [
                TextButton(
                  child:
                      const Text('Batal', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    // Implementasi fungsi batal
                  },
                ),
              ],
            ),
      body: pesananData == null
          ? const Center(child: CircularProgressIndicator())
          : isOrderCompleted()
              ? _buildCompletedOrderUI()
              : Stack(
                  children: [
                    _buildContent(),
                    if (pesananData?['status_pesanan'] == 'diantarkan')
                      _buildDraggableScrollableSheet(),
                  ],
                ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatusIndicator(),
          if (pesananData?['status_pesanan'] == 'diantarkan')
            _buildDeliveryMap(),
          if (pesananData?['status_pesanan'] == 'diproses')
            _buildProcessingStatus(),
          _buildOrderDetails(),
          _buildRestaurantInfo(),
          _buildDeliveryAddress(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, color: _getIconColor(0)),
          Expanded(
              child: Divider(
                  color: _getDividerColor(0),
                  thickness: _getDividerThickness(0))),
          Icon(Icons.shopping_cart_outlined, color: _getIconColor(1)),
          Expanded(
              child: Divider(
                  color: _getDividerColor(1),
                  thickness: _getDividerThickness(1))),
          Icon(Icons.motorcycle_outlined, color: _getIconColor(2)),
          Expanded(
              child: Divider(
                  color: _getDividerColor(2),
                  thickness: _getDividerThickness(2))),
          Icon(Icons.home_outlined, color: _getIconColor(3)),
        ],
      ),
    );
  }

  Widget _buildProcessingStatus() {
    return Column(
      children: [
        Image.asset('assets/masak.gif', width: 200, height: 200),
        const SizedBox(height: 10),
        const Text('Sedang dikemas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDeliveryMap() {
    return SizedBox(
      height: 300,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _currentLocation,
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }

  Widget _buildDraggableScrollableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const SizedBox(height: 12),
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
              const SizedBox(height: 20),
              _buildDriverInfo(),
              _buildOrderStatusInfo(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedOrderUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'Orderan Sukses!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Metode Pembayaran: ${pesananData?['channel_pembayaran'] ?? 'CASH'}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            pesananData?['email'] ?? '08960712121',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/kategory');
            },
            child: Text('BUAT PESANAN BARU'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pesananData?['nama_lengkap'] ?? 'Nama lokaran',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Harga'),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pesananData?['channel_pembayaran'] ??
                            'Metode Pembayaran',
                        style:
                            const TextStyle(color: Colors.purple, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rp${pesananData?['alt_total'] ?? '0'}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'Rp${pesananData?['alt_potongan_voucher'] ?? '0'}',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildMenuItems(),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return ListTile(
      leading: const Icon(Icons.store, color: Colors.blue),
      title: Text(
        pesananData?['kurir'] ?? 'Nama lokaran - Lokasi',
        overflow: TextOverflow.ellipsis,
      ),
      minLeadingWidth: 20,
    );
  }

  Widget _buildDeliveryAddress() {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Colors.red),
      title: Text(pesananData?['alamat'] ?? 'Alamat Pengiriman'),
      minLeadingWidth: 20,
    );
  }

  List<Widget> _buildMenuItems() {
    final List<dynamic> items = pesananData?['data_item_menu'] ?? [];
    return items.map((item) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${item['kuantitas']}x   ${item['nama_item_menu']} ${item['nama_varian'] ?? ''}'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item['alt_subtotal']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('${item['alt_harga']}',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  Widget _buildDriverInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
                pesananData?['foto_kurir'] ?? 'https://via.placeholder.com/60'),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pesananData?['nama_kurir'] ?? 'Nama Kurir',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  pesananData?['kendaraan_kurir'] ?? 'Kendaraan Kurir',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () {
              // Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () {
              // Implement message functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status Pesanan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 12),
              const SizedBox(width: 8),
              Text(
                pesananData?['status_pesanan'] ?? 'Status Tidak Diketahui',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Estimated arrival time: $_estimatedArrivalTime',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
