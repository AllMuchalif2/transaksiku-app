import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaksi_provider.dart';
import '../models/transaksi.dart';
import 'chatbot.dart';

/// Layar utama yang menampilkan ringkasan keuangan.
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  DateTime _today = DateTime.now();
  String _filter = 'Harian'; // Filter default adalah 'Harian'.

  @override
  void initState() {
    super.initState();
    // Memuat data transaksi saat layar pertama kali dibuka.
    Future.microtask(
      () => Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).loadTransaksi(),
    );
  }

  /// Memformat angka integer menjadi format mata uang Rupiah.
  String formatRupiah(int jumlah) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(jumlah);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, _) {
        // Memfilter data transaksi berdasarkan pilihan filter.
        List<Transaksi> pemasukan;
        List<Transaksi> pengeluaran;

        if (_filter == 'Harian') {
          pemasukan = provider.getByJenisHariIni('pemasukan');
          pengeluaran = provider.getByJenisHariIni('pengeluaran');
        } else if (_filter == 'Bulanan') {
          pemasukan = provider.getByJenisBulanIni('pemasukan');
          pengeluaran = provider.getByJenisBulanIni('pengeluaran');
        } else if (_filter == 'Tahunan') {
          pemasukan = provider.getByJenisTahunIni('pemasukan');
          pengeluaran = provider.getByJenisTahunIni('pengeluaran');
        } else {
          pemasukan = provider.getByJenis('pemasukan');
          pengeluaran = provider.getByJenis('pengeluaran');
        }

        // Menghitung total dari data yang sudah difilter.
        int totalPemasukan = pemasukan.fold(0, (sum, t) => sum + t.jumlah);
        int totalPengeluaran = pengeluaran.fold(0, (sum, t) => sum + t.jumlah);
        int selisih = totalPemasukan - totalPengeluaran;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Beranda'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            actions: [
              // Tombol untuk memilih filter data.
              PopupMenuButton<String>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _filter = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Harian',
                    child: Text('Filter Harian'),
                  ),
                  const PopupMenuItem(
                    value: 'Bulanan',
                    child: Text('Filter Bulanan'),
                  ),
                  const PopupMenuItem(
                    value: 'Tahunan',
                    child: Text('Filter Tahunan'),
                  ),
                  const PopupMenuItem(
                    value: 'Semua',
                    child: Text('Semua Data'),
                  ),
                ],
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatBotScreen()),
              );
            },
            tooltip: 'Tanya AI',
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            child: const Icon(Icons.smart_toy, color: Colors.white),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menampilkan tanggal dan waktu saat ini.
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _filter == 'Harian'
                              ? DateFormat(
                                  'EEEE, dd MMMM yyyy',
                                  'id_ID',
                                ).format(_today)
                              : _filter == 'Bulanan'
                              ? 'Bulan ' +
                                    DateFormat(
                                      'MMMM yyyy',
                                      'id_ID',
                                    ).format(_today)
                              : _filter == 'Tahunan'
                              ? 'Tahun ' +
                                    DateFormat('yyyy', 'id_ID').format(_today)
                              : 'Semua Data',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          DateFormat('HH:mm').format(_today),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kartu yang menampilkan ringkasan pemasukan, pengeluaran, dan selisih.
                  Card(
                    color: Theme.of(context).cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RingkasanItem(
                            label: 'Pemasukan',
                            value: totalPemasukan,
                          ),
                          RingkasanItem(
                            label: 'Pengeluaran',
                            value: totalPengeluaran,
                          ),
                          const Divider(),
                          RingkasanItem(
                            label: 'Selisih',
                            value: selisih,
                            color: selisih >= 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget untuk menampilkan satu baris item pada kartu ringkasan.
class RingkasanItem extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const RingkasanItem({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            format,
            style: TextStyle(
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
