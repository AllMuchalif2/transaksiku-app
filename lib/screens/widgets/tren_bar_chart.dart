import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaksi.dart';

class TrenBarChart extends StatefulWidget {
  final List<Transaksi> daftarTransaksi;
  final String filter;

  const TrenBarChart({
    super.key,
    required this.daftarTransaksi,
    required this.filter,
  });

  @override
  State<TrenBarChart> createState() => _TrenBarChartState();
}

class _TrenBarChartState extends State<TrenBarChart> {
  String _jenisTren = 'pengeluaran'; // Default

  String formatRupiah(int jumlah) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(jumlah);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> barData = [];
    DateTime now = DateTime.now();

    if (widget.filter == 'Harian' || widget.filter == 'Semua') {
      // Ambil 7 hari terakhir
      for (int i = 6; i >= 0; i--) {
        DateTime date = now.subtract(Duration(days: i));
        int sum = widget.daftarTransaksi
            .where(
              (Transaksi t) =>
                  t.jenis == _jenisTren &&
                  t.tanggal.year == date.year &&
                  t.tanggal.month == date.month &&
                  t.tanggal.day == date.day,
            )
            .fold<int>(
              0,
              (int prev, Transaksi element) => prev + element.jumlah,
            );
        barData.add({
          'label': DateFormat('EEE', 'id_ID').format(date),
          'value': sum,
        });
      }
    } else if (widget.filter == 'Bulanan') {
      // Ambil 5 bulan terakhir
      for (int i = 4; i >= 0; i--) {
        DateTime date = DateTime(now.year, now.month - i, 1);
        int sum = widget.daftarTransaksi
            .where(
              (Transaksi t) =>
                  t.jenis == _jenisTren &&
                  t.tanggal.year == date.year &&
                  t.tanggal.month == date.month,
            )
            .fold<int>(
              0,
              (int prev, Transaksi element) => prev + element.jumlah,
            );
        barData.add({
          'label': DateFormat('MMM', 'id_ID').format(date),
          'value': sum,
        });
      }
    } else if (widget.filter == 'Tahunan') {
      // Ambil 5 tahun terakhir
      for (int i = 4; i >= 0; i--) {
        int year = now.year - i;
        int sum = widget.daftarTransaksi
            .where(
              (Transaksi t) => t.jenis == _jenisTren && t.tanggal.year == year,
            )
            .fold<int>(
              0,
              (int prev, Transaksi element) => prev + element.jumlah,
            );
        barData.add({'label': year.toString(), 'value': sum});
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tren ${_jenisTren == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButton<String>(
                value: _jenisTren,
                items: const [
                  DropdownMenuItem(
                    value: 'pengeluaran',
                    child: Text('Pengeluaran'),
                  ),
                  DropdownMenuItem(
                    value: 'pemasukan',
                    child: Text('Pemasukan'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _jenisTren = val;
                    });
                  }
                },
                underline: Container(),
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  barData
                      .fold<int>(
                        0,
                        (max, e) => e['value'] > max ? e['value'] : max,
                      )
                      .toDouble() *
                  1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      formatRupiah(rod.toY.toInt()),
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < barData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            barData[index]['label'],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: (entry.value['value'] as int).toDouble(),
                      color: _jenisTren == 'pemasukan'
                          ? Colors.green
                          : Colors.red,
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
