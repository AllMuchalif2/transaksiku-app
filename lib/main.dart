import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // ← Tambahkan ini
import 'package:provider/provider.dart';

import 'providers/transaksi_provider.dart';
import 'screens/navigasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data lokal
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransaksiProvider()..loadTransaksi(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Pencatatan Keuangan',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const NavigasiScreen(),
      ),
    );
  }
}
