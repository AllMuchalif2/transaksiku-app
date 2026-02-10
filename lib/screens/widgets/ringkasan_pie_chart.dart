import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RingkasanPieChart extends StatelessWidget {
  final int totalPemasukan;
  final int totalPengeluaran;

  const RingkasanPieChart({
    super.key,
    required this.totalPemasukan,
    required this.totalPengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    double totalPie = (totalPemasukan + totalPengeluaran).toDouble();
    double persentaseMasuk = totalPie == 0
        ? 0
        : (totalPemasukan / totalPie) * 100;
    double persentaseKeluar = totalPie == 0
        ? 0
        : (totalPengeluaran / totalPie) * 100;

    if (totalPie == 0) return const SizedBox.shrink();

    return Column(
      children: [
        const Text(
          'Ringkasan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  color: Colors.green,
                  value: totalPemasukan.toDouble(),
                  title: '${persentaseMasuk.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.red,
                  value: totalPengeluaran.toDouble(),
                  title: '${persentaseKeluar.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Pemasukan'),
              ],
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Pengeluaran'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
