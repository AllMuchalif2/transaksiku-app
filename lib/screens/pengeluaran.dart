import 'package:flutter/material.dart';

import 'transaksi_list_screen.dart';

class PengeluaranScreen extends StatelessWidget {
  const PengeluaranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransaksiListScreen(
      title: 'Pengeluaran',
      jenis: 'pengeluaran',
      primaryColor: Colors.red,
      appBarColor: Colors.teal,
      floatingActionButtonColor: Colors.red[100]!,
    );
  }
}
