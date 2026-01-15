import 'package:flutter/material.dart';

import 'transaksi_list_screen.dart';

class PemasukanScreen extends StatelessWidget {
  const PemasukanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransaksiListScreen(
      title: 'Pemasukan',
      jenis: 'pemasukan',
      primaryColor: Colors.green,
      appBarColor: Colors.teal,
      floatingActionButtonColor: Colors.green[100]!,
    );
  }
}
