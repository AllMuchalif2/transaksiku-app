import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import 'form_transaksi.dart';

// START: Enum filter mode dengan tambahan tahunan
enum FilterMode { harian, bulanan, tahunan, semua }
// END: Enum filter mode dengan tambahan tahunan

class PengeluaranScreen extends StatefulWidget {
  const PengeluaranScreen({super.key});

  @override
  State<PengeluaranScreen> createState() => _PengeluaranScreenState();
}

class _PengeluaranScreenState extends State<PengeluaranScreen> {
  // START: State untuk tanggal dan mode filter (default harian)
  DateTime _selectedDate = DateTime.now();
  FilterMode _filterMode = FilterMode.harian;
  // END: State untuk tanggal dan mode filter (default harian)

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, child) {
        // START: Ambil dan filter data pengeluaran dengan tambahan filter tahunan
        List<Transaksi> data;

        if (_filterMode == FilterMode.semua) {
          data = provider.getByJenis('pengeluaran');
        } else if (_filterMode == FilterMode.bulanan) {
          data = provider
              .getByJenis('pengeluaran')
              .where(
                (t) =>
                    t.tanggal.month == _selectedDate.month &&
                    t.tanggal.year == _selectedDate.year,
              )
              .toList();
        } else if (_filterMode == FilterMode.tahunan) {
          data = provider
              .getByJenis('pengeluaran')
              .where((t) => t.tanggal.year == _selectedDate.year)
              .toList();
        } else {
          data = provider.getByJenisDanTanggal('pengeluaran', _selectedDate);
        }

        int total = data.fold(0, (sum, item) => sum + item.jumlah);
        // END: Ambil dan filter data pengeluaran dengan tambahan filter tahunan

        return Scaffold(
          // START: AppBar dengan dropdown filter dan date picker yang spesifik
          appBar: AppBar(
            title: const Text('Pengeluaran'), // atau 'Pengeluaran'
            actions: [
              PopupMenuButton<FilterMode>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _filterMode = value;
                    final now = DateTime.now();
                    // Auto select sesuai filter yang dipilih
                    if (value == FilterMode.harian) {
                      _selectedDate = now; // Auto select today
                    } else if (value == FilterMode.bulanan) {
                      _selectedDate = DateTime(
                        now.year,
                        now.month,
                        1,
                      ); // Auto select bulan ini
                    } else if (value == FilterMode.tahunan) {
                      _selectedDate = DateTime(
                        now.year,
                        1,
                        1,
                      ); // Auto select tahun ini
                    }
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: FilterMode.harian,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _filterMode == FilterMode.harian
                              ? Colors.blue
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Harian',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.harian
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.harian
                                ? Colors.blue
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterMode.bulanan,
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: _filterMode == FilterMode.bulanan
                              ? Colors.blue
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bulanan',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.bulanan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.bulanan
                                ? Colors.blue
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterMode.tahunan,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: _filterMode == FilterMode.tahunan
                              ? Colors.blue
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tahunan',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.tahunan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.tahunan
                                ? Colors.blue
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: FilterMode.semua,
                    child: Row(
                      children: [
                        Icon(
                          Icons.save,
                          color: _filterMode == FilterMode.semua
                              ? Colors.blue
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Semua',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.semua
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.semua
                                ? Colors.redAccent
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Tombol untuk memilih tanggal/bulan/tahun
              if (_filterMode != FilterMode.semua)
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();

                    if (_filterMode == FilterMode.harian) {
                      // Pilih tanggal lengkap (tidak boleh lebih dari hari ini)
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate.isAfter(now)
                            ? now
                            : _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: now, // Tidak boleh pilih tanggal masa depan
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    } else if (_filterMode == FilterMode.bulanan) {
                      // Pilih bulan dan tahun saja
                      int selectedYear = _selectedDate.year;
                      int selectedMonth = _selectedDate.month;

                      final result = await showDialog<Map<String, int>>(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: const Text('Pilih Bulan'),
                                content: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: Column(
                                    children: [
                                      // Pilih Tahun
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: selectedYear > 2020
                                                ? () {
                                                    setDialogState(() {
                                                      selectedYear--;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(Icons.arrow_left),
                                          ),
                                          Text(
                                            selectedYear.toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: selectedYear < now.year
                                                ? () {
                                                    setDialogState(() {
                                                      selectedYear++;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(Icons.arrow_right),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      // Grid Bulan
                                      Expanded(
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                childAspectRatio: 2,
                                              ),
                                          itemCount: 12,
                                          itemBuilder: (context, index) {
                                            final monthNames = [
                                              'Jan',
                                              'Feb',
                                              'Mar',
                                              'Apr',
                                              'Mei',
                                              'Jun',
                                              'Jul',
                                              'Ags',
                                              'Sep',
                                              'Okt',
                                              'Nov',
                                              'Des',
                                            ];

                                            final monthIndex = index + 1;

                                            // Disable bulan masa depan
                                            bool isDisabled =
                                                selectedYear == now.year &&
                                                monthIndex > now.month;

                                            return GestureDetector(
                                              onTap: isDisabled
                                                  ? null
                                                  : () {
                                                      setDialogState(() {
                                                        selectedMonth =
                                                            monthIndex;
                                                      });
                                                    },
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: isDisabled
                                                      ? Colors.grey[350]
                                                      : selectedMonth ==
                                                            monthIndex
                                                      ? Colors.purple[900]
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    monthNames[index],
                                                    style: TextStyle(
                                                      color: isDisabled
                                                          ? Colors.grey[500]
                                                          : selectedMonth ==
                                                                monthIndex
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight:
                                                          selectedMonth ==
                                                              monthIndex
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, {
                                        'year': selectedYear,
                                        'month': selectedMonth,
                                      });
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      if (result != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            result['year']!,
                            result['month']!,
                            1,
                          );
                        });
                      }
                    } else if (_filterMode == FilterMode.tahunan) {
                      // Pilih tahun saja
                      int displayYear = _selectedDate.year;
                      int selectedYear = _selectedDate.year;

                      final result = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: const Text('Pilih Tahun'),
                                content: SizedBox(
                                  width: 300,
                                  height: 400,
                                  child: Column(
                                    children: [
                                      // Navigation tahun
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: displayYear - 10 >= 2020
                                                ? () {
                                                    setDialogState(() {
                                                      displayYear -= 10;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(
                                              Icons.keyboard_double_arrow_left,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: displayYear > 2020
                                                ? () {
                                                    setDialogState(() {
                                                      displayYear--;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(Icons.arrow_left),
                                          ),
                                          Text(
                                            displayYear.toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: displayYear < now.year
                                                ? () {
                                                    setDialogState(() {
                                                      displayYear++;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(Icons.arrow_right),
                                          ),
                                          IconButton(
                                            onPressed:
                                                displayYear + 10 <= now.year
                                                ? () {
                                                    setDialogState(() {
                                                      displayYear += 10;
                                                    });
                                                  }
                                                : null,
                                            icon: const Icon(
                                              Icons.keyboard_double_arrow_right,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      // Grid Tahun (range 10 tahun)
                                      Expanded(
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                childAspectRatio: 2,
                                              ),
                                          itemCount: 10,
                                          itemBuilder: (context, index) {
                                            final year =
                                                displayYear - 5 + index;

                                            // Disable tahun masa depan dan tahun sebelum 2020
                                            bool isDisabled =
                                                year > now.year || year < 2020;

                                            return GestureDetector(
                                              onTap: isDisabled
                                                  ? null
                                                  : () {
                                                      setDialogState(() {
                                                        selectedYear = year;
                                                      });
                                                    },
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: isDisabled
                                                      ? Colors.grey[350]
                                                      : selectedYear == year
                                                      ? Colors.purple[900]
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    year.toString(),
                                                    style: TextStyle(
                                                      color: isDisabled
                                                          ? Colors.grey[500]
                                                          : selectedYear == year
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontWeight:
                                                          selectedYear == year
                                                          ? FontWeight.bold
                                                          : FontWeight.normal,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, null),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, selectedYear);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );

                      if (result != null) {
                        setState(() {
                          _selectedDate = DateTime(result, 1, 1);
                        });
                      }
                    }
                  },
                ),
            ],
          ),
          // END: AppBar dengan dropdown filter dan date picker yang spesifik

          // START: Ringkasan total pengeluaran dengan format yang diperbaiki
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
                      _filterMode == FilterMode.semua
                          ? 'Semua Data'
                          : _filterMode == FilterMode.bulanan
                          ? 'Bulan: ${DateFormat('MMMM yyyy', 'id').format(_selectedDate)}'
                          : _filterMode == FilterMode.tahunan
                          ? 'Tahun: ${_selectedDate.year}'
                          : 'Tanggal: ${DateFormat('dd MMMM yyyy', 'id').format(_selectedDate)}',
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
              // END: Ringkasan total pengeluaran dengan format yang diperbaiki

              // START: List pengeluaran dengan tombol edit dan hapus terpisah
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '- Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(t.jumlah)}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tombol Edit
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  onPressed: () {
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
                                  tooltip: 'Edit',
                                ),
                                // Tombol Hapus
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text(
                                          'Apakah Anda yakin ingin menghapus pengeluaran "${t.nama}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm ?? false) {
                                      provider.hapusTransaksi(t.id!);
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${t.nama} berhasil dihapus',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              // END: List pengeluaran dengan tombol edit dan hapus terpisah
            ],
          ),

          // START: Tombol tambah pengeluaran
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FormTransaksi(jenis: 'pengeluaran'),
                ),
              );
            },
            backgroundColor: Colors.red[100],
            child: const Icon(Icons.add),
          ),
          // END: Tombol tambah pengeluaran
        );
      },
    );
  }
}
