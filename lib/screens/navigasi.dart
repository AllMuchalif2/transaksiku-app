import 'package:app_uang/providers/transaksi_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'beranda.dart';
import 'pengeluaran.dart';
import 'pemasukan.dart';
import 'pengaturan.dart';

/// Widget utama yang mengatur navigasi antar layar menggunakan BottomNavigationBar.
class NavigasiScreen extends StatefulWidget {
  const NavigasiScreen({Key? key}) : super(key: key);

  @override
  State<NavigasiScreen> createState() => _NavigasiScreenState();
}

class _NavigasiScreenState extends State<NavigasiScreen> {
  int _index = 0; // Indeks layar yang sedang aktif.

  // Daftar layar yang akan ditampilkan.
  final List<Widget> _pages = [
    const BerandaScreen(),
    const PengeluaranScreen(),
    const PemasukanScreen(),
    const PengaturanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Memuat data transaksi saat aplikasi pertama kali dijalankan.
    Future.microtask(
      () => Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).loadTransaksi(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Pengeluaran',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Pemasukan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
