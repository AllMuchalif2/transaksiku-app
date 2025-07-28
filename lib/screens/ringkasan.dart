import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/transaksi_provider.dart';
import '../models/transaksi.dart';

class RingkasanScreen extends StatefulWidget {
  const RingkasanScreen({super.key});

  @override
  State<RingkasanScreen> createState() => _RingkasanScreenState();
}

class _RingkasanScreenState extends State<RingkasanScreen> {
  DateTime _today = DateTime.now();
  String _filter = 'Harian'; // opsi: Harian atau Bulanan

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
        List<Transaksi> pemasukan = _filter == 'Harian'
            ? provider.getByJenisHariIni('pemasukan')
            : provider.getByJenisBulanIni('pemasukan');

        List<Transaksi> pengeluaran = _filter == 'Harian'
            ? provider.getByJenisHariIni('pengeluaran')
            : provider.getByJenisBulanIni('pengeluaran');

        int totalPemasukan = pemasukan.fold(0, (sum, t) => sum + t.jumlah);
        int totalPengeluaran = pengeluaran.fold(0, (sum, t) => sum + t.jumlah);
        int selisih = totalPemasukan - totalPengeluaran;

        return Scaffold(
          appBar: AppBar(title: const Text('Beranda')),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔘 Filter Harian / Bulanan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('Tampilkan: '),
                      DropdownButton<String>(
                        value: _filter,
                        items: const [
                          DropdownMenuItem(
                            value: 'Harian',
                            child: Text('Harian'),
                          ),
                          DropdownMenuItem(
                            value: 'Bulanan',
                            child: Text('Bulanan'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _filter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 🕓 Jam & Tanggal
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _filter == 'Harian'
                              ? DateFormat(
                                  'EEEE, dd MMMM yyyy',
                                  'id_ID',
                                ).format(_today)
                              : DateFormat('MMMM yyyy', 'id_ID').format(_today),
                          style: const TextStyle(fontSize: 18),
                        ),
                        if (_filter == 'Harian') ...[
                          const SizedBox(height: 10),
                          Text(
                            DateFormat('HH:mm').format(_today),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 💸 Ringkasan
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          RingkasanItem(
                            label: 'Pemasukan',
                            value: totalPemasukan,
                            color: Colors.green,
                          ),
                          RingkasanItem(
                            label: 'Pengeluaran',
                            value: totalPengeluaran,
                            color: Colors.red,
                          ),
                          const Divider(),
                          RingkasanItem(
                            label: 'Selisih',
                            value: selisih,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📊 Grafik batang
                  Text(
                    'Grafik ${_filter == 'Harian' ? 'Hari Ini' : 'Bulan Ini'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceBetween,
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    formatRupiah(value.toInt()),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Pemasukan');
                                    case 1:
                                      return const Text('Pengeluaran');
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: totalPemasukan.toDouble(),
                                  color: Colors.green,
                                  width: 30,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: totalPengeluaran.toDouble(),
                                  color: Colors.red,
                                  width: 30,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

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
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Text(format, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
