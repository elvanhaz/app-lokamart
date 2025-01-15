import 'package:loka/providers/CartProvider.dart';
import 'package:loka/providers/FavoritProvider.dart';
import 'package:loka/providers/GetOutletsProvider.dart';
import 'package:loka/providers/KategoryProvider.dart'; // Provider untuk kategori
import 'package:loka/providers/LocationProvider.dart'; // Provider untuk lokasi
import 'package:loka/providers/MenuProvider.dart';
import 'package:loka/providers/OutletProvider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan token Sanctum
import 'package:flutter/material.dart'; // Flutter UI framework
import 'package:loka/routes/app_routes.dart'; // Rute aplikasi yang sudah ditentukan
import 'package:provider/provider.dart'; // Library untuk state management
import 'providers/otp_provider.dart'; // Provider untuk OTP
import 'routes/app_pages.dart'; // Halaman-halaman aplikasi
import 'package:firebase_core/firebase_core.dart'; // Firebase core untuk inisialisasi

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Penting untuk memastikan inisialisasi berjalan dengan benar
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? sanctumToken = prefs.getString('sanctumToken');

  // Menyimpan token di state management atau langsung diakses secara global
  runApp(MyApp(sanctumToken: sanctumToken));
}

class MyApp extends StatefulWidget {
  final String? sanctumToken; // Tambahkan parameter sanctumToken

  // Tambahkan parameter sanctumToken ke dalam constructor
  const MyApp({super.key, this.sanctumToken});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? initialRoute; // Untuk menyimpan rute awal berdasarkan status login

  @override
  void initState() {
    super.initState();
    // Mengecek status login saat aplikasi diinisialisasi
    _checkLoginStatus();
  }
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs
        .getString('sanctumToken'); // Mengambil token dari SharedPreferences

    // Jika token tersedia dan tidak kosong, arahkan ke halaman cabang
    if (token != null && token.isNotEmpty) {
      setState(() {
        initialRoute = '/cabang'; // Halaman utama setelah login
      });
    } else {
      setState(() {
        initialRoute = AppRoutes.home; // Halaman login atau OTP verification
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialRoute == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Menampilkan loading spinner
          ),
        ),
      );
    }

    // Menggunakan MultiProvider untuk mengatur state management pada seluruh aplikasi
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => OtpProvider()), // Provider untuk OTP
        ChangeNotifierProvider(
            create: (_) => LocationProvider()), // Provider untuk lokasi
        ChangeNotifierProvider(
            create: (_) => CategoryProvider()), // Provider untuk kategori
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => OutletProvider()),
        ChangeNotifierProvider(create: (_) => FavoritProvider()),

        ChangeNotifierProvider(
            create: (_) => GetOutletProvider(widget.sanctumToken)),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Menyembunyikan banner debug
        initialRoute:
            initialRoute!, // Menggunakan rute awal yang sudah ditentukan
        routes:
            appRoutes, // Menggunakan rute yang telah didefinisikan di appRoutes
      ),
    );
  }
}
