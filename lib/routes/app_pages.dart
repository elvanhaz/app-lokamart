// routes/app_pages.dart
import 'package:loka/views/cabang.dart';
import 'package:loka/views/checkout.dart';
import 'package:loka/views/checkoutedit.dart';
import 'package:loka/views/detaillokasi.dart';
import 'package:loka/views/detailpembayaran.dart';
import 'package:loka/views/detailpembayaranstatus.dart';
import 'package:loka/views/detailproduk.dart';
import 'package:loka/views/favorite.dart';
import 'package:loka/views/kategory.dart';
import 'package:loka/views/login.dart';
import 'package:loka/views/opsipembayaran.dart';
import 'package:loka/views/pemesanan.dart';
import 'package:loka/views/otpverifikasi.dart';
import 'package:loka/views/pesanan.dart';
import 'package:loka/views/profile.dart';
import 'package:loka/views/statuspesanan.dart';
import 'package:loka/views/varian.dart';
import 'package:loka/views/varianedit.dart';
import 'package:flutter/material.dart';
import 'package:loka/routes/app_routes.dart';

Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.home: (context) => HomePage(),
  AppRoutes.cabang: (context) => CabangPage(),
  AppRoutes.kategory: (context) => KategoryPage(),
  AppRoutes.checkout: (context) => CheckoutPage(
        paymentData: const {},
      ),
  AppRoutes.pemesanan: (context) => PemesananPage(),
  AppRoutes.varian: (context) => VarianPage(),
  AppRoutes.otpVerification: (context) => OtpVerificationPage(),
  AppRoutes.favorite: (context) => FavoritePage(),
  AppRoutes.varianedit: (context) => VarianEditPage(),
  AppRoutes.checkoutedit: (context) => CheckoutEditPage(),
  AppRoutes.opsipembayaran: (context) => OpsipembayaranPage(),
  AppRoutes.profile: (context) => ProfileScreen(),
  AppRoutes.detaillokasi: (context) => DetailLokasiPage(),
  AppRoutes.detailproduk: (context) => DetailProduk(),
  AppRoutes.pesanan: (context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return PesananPage(orderId: arguments['orderId']);
  },
  AppRoutes.detailpembayaran: (context) => DetailPembayaranPage(),
  AppRoutes.detailpembayaranstatus: (context) => DetailPembayaranStatusPage(),
  AppRoutes.statuspesanan: (context) => StatusPesananPage(),
};
