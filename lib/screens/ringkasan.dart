import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaksi_provider.dart';
import '../models/transaksi.dart';

// ===================== RINGKASAN SCREEN =====================
class RingkasanScreen extends StatefulWidget {
  const RingkasanScreen({super.key});

  @override
  State<RingkasanScreen> createState() => _RingkasanScreenState();
}

// ===================== STATE RINGKASAN SCREEN =====================
class _RingkasanScreenState extends State<RingkasanScreen> {
  DateTime _today = DateTime.now();
  String _filter = 'Harian';

  // ===================== FORMAT RUPIAH =====================
  String formatRupiah(int jumlah) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(jumlah);
  }
  // ===================== END FORMAT RUPIAH =====================

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, _) {
        List<Transaksi> pemasukan;
        List<Transaksi> pengeluaran;

        if (_filter == 'Harian') {
          pemasukan = provider.getByJenisHariIni('pemasukan');
          pengeluaran = provider.getByJenisHariIni('pengeluaran');
        } else if (_filter == 'Bulanan') {
          // Ambil semua data pemasukan dan pengeluaran
          pemasukan = provider.getByJenisBulanIni('pemasukan');
          pengeluaran = provider.getByJenisBulanIni('pengeluaran');
        } else if (_filter == 'Tahunan') {
          // Ambil semua data pemasukan dan pengeluaran
          pemasukan = provider.getByJenisTahunIni('pemasukan');
          pengeluaran = provider.getByJenisTahunIni('pengeluaran');
        } else {
          // semua data
          pemasukan = provider.getByJenis('pemasukan');
          pengeluaran = provider.getByJenis('pengeluaran');
        }

        int totalPemasukan = pemasukan.fold(0, (sum, t) => sum + t.jumlah);
        int totalPengeluaran = pengeluaran.fold(0, (sum, t) => sum + t.jumlah);
        int selisih = totalPemasukan - totalPengeluaran;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Beranda'),
            actions: [
              // ===================== FILTER MENU =====================
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
              // ===================== END FILTER MENU =====================
            ],
          ),

          // ===================== BODY =====================
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===================== TANGGAL & WAKTU =====================
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
                              : 'Semua Data', // untuk filter 'Semua'
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

                  // ===================== END TANGGAL & WAKTU =====================
                  const SizedBox(height: 24),

                  // ===================== RINGKASAN =====================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RingkasanItem(
                            label: 'Pemasukan',
                            value: totalPemasukan,
                            color: Colors.black,
                          ),
                          RingkasanItem(
                            label: 'Pengeluaran',
                            value: totalPengeluaran,
                            color: Colors.black,
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

                  // ===================== END RINGKASAN =====================
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ===================== END BODY =====================
        );
      },
    );
  }

  // ===================== END BUILD =====================
}

// ===================== RINGKASAN ITEM =====================
class RingkasanItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const RingkasanItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
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
          Text(format, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}

// ===================== END RINGKASAN ITEM =====================
