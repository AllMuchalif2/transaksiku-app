import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import 'form_transaksi.dart';

class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({super.key});

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, child) {
        List<Transaksi> data = provider.getByJenisDanTanggal(
          'pengeluaran',
          _selectedDate,
        );
        int total = data.fold(0, (sum, item) => sum + item.jumlah);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pengeluaran'),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.red[100],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(total)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: data.isEmpty
                    ? const Center(child: Text('Tidak ada data'))
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, index) {
                          final t = data[index];
                          return ListTile(
                            title: Text(t.nama),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(t.tanggal),
                            ),
                            trailing: Text(
                              '- Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(t.jumlah)}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FormTransaksi(
                                    jenis: 'pengeluaran',
                                    transaksi: t,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Hapus?'),
                                  content: Text('Hapus ${t.nama}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm ?? false) {
                                provider.hapusTransaksi(t.id!);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormTransaksi(jenis: 'pengeluaran'),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
