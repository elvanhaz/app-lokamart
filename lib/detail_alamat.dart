import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

void main() {
  runApp(const DetailAlamatPage());
}

class DetailAlamatPage extends StatelessWidget {
  const DetailAlamatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DetailAlamat(),
    );
  }
}

class DetailAlamat extends StatefulWidget {
  const DetailAlamat({super.key});

  @override
  State<DetailAlamat> createState() => DetailAlamatState();
}

class DetailAlamatState extends State<DetailAlamat> {
  GoogleMapController? mapController;
  bool _isFavorite = false;
  String _addressType = 'Rumah';

  LatLng _currentPosition = const LatLng(-6.1751, 106.8650);
  String _address = 'Loading address...';
  final String _detailLokasi = 'Jl Beringin Raya Blok B12 No24 RT 04/RW 01';
  final String _patokan = 'Nama penerima erda no hp 08567542743';
  Marker? _marker;  
  final ValueNotifier<double> _sheetExtent = ValueNotifier(0.3);
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
  }

  _checkPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied || status.isRestricted) {
      if (await Permission.location.request().isGranted) {
        _getCurrentLocation();
      }
    } else {
      _getCurrentLocation();
    }
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng newPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = newPosition;
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentPosition,
      );
      _isLoading = true;
    });

    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 15.0),
      ),
    );

    _getAddressFromLatLng(_currentPosition);
  }

  _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);
      Placemark place = placemarks[0];
      setState(() {
        _address =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePosition(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      _marker = Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentPosition,
      );
      _isLoading = true;
    });

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () {
      _getAddressFromLatLng(_currentPosition);
    });
  }

  String _getStreetName(String address) {
    return address.split(',').first;
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
  body: Stack(
    children: [
      ValueListenableBuilder<double>(
        valueListenable: _sheetExtent,
        builder: (context, extent, child) {
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * (1 - extent),
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 15.0,
              ),
              onCameraMove: _updatePosition,
              myLocationEnabled: true,
              markers: _marker != null ? {_marker!} : {},
            ),
          );
        },
      ),
      NotificationListener<DraggableScrollableNotification>(
        onNotification: (notification) {
          _sheetExtent.value = notification.extent;
          _adjustMapCamera();
          return true;
        },
        child: DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detail alamat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Handle edit button press
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        child: const Text(
                          'Ubah',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 20.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _getStreetName(_address),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            const SizedBox(height: 5),
                            _isLoading
                                ? Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 20.0,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _address,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Detail lokasi (opsional)',
                      hintText: _detailLokasi,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Patokan (opsional)',
                      hintText: _patokan,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isFavorite,
                        onChanged: (value) {
                          setState(() {
                            _isFavorite = value ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Simpan alamat ini jadi favorit',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Simpan alamat sebagai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAddressTypeButton(
                        icon: Icons.home,
                        label: 'Rumah',
                        isSelected: _addressType == 'Rumah',
                        onTap: () {
                          setState(() {
                            _addressType = 'Rumah';
                          });
                        },
                      ),
                      _buildAddressTypeButton(
                        icon: Icons.business,
                        label: 'Kantor',
                        isSelected: _addressType == 'Kantor',
                        onTap: () {
                          setState(() {
                            _addressType = 'Kantor';
                          });
                        },
                      ),
                      _buildAddressTypeButton(
                        icon: Icons.other_houses,
                        label: 'Lainnya',
                        isSelected: _addressType == 'Lainnya',
                        onTap: () {
                          setState(() {
                            _addressType = 'Lainnya';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle Konfirmasi button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Konfirmasi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 10,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Handle back button press
            },
          ),
        ),
      ),
    ],
  ),
);

  }

 
  Widget _buildAddressTypeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: isSelected ? Colors.white : Colors.green),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.green,
        ),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        backgroundColor: isSelected ? Colors.green : Colors.white,
        side: const BorderSide(color: Colors.green),
      ),
    );
  }


void _adjustMapCamera() async {
    if (mapController != null) {

      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

}

