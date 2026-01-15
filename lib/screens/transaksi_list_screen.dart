import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/filter_mode.dart';
import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import 'form_transaksi.dart';

class TransaksiListScreen extends StatefulWidget {
  final String title;
  final String jenis;
  final Color primaryColor;
  final Color appBarColor;
  final Color floatingActionButtonColor;

  const TransaksiListScreen({
    super.key,
    required this.title,
    required this.jenis,
    required this.primaryColor,
    required this.appBarColor,
    required this.floatingActionButtonColor,
  });

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> {
  DateTime _selectedDate = DateTime.now();
  FilterMode _filterMode = FilterMode.harian;

  @override
  Widget build(BuildContext context) {
    return Consumer<TransaksiProvider>(
      builder: (context, provider, child) {
        List<Transaksi> data;

        if (_filterMode == FilterMode.semua) {
          data = provider.getByJenis(widget.jenis);
        } else if (_filterMode == FilterMode.bulanan) {
          data = provider
              .getByJenis(widget.jenis)
              .where(
                (t) =>
                    t.tanggal.month == _selectedDate.month &&
                    t.tanggal.year == _selectedDate.year,
              )
              .toList();
        } else if (_filterMode == FilterMode.tahunan) {
          data = provider
              .getByJenis(widget.jenis)
              .where((t) => t.tanggal.year == _selectedDate.year)
              .toList();
        } else {
          data = provider.getByJenisDanTanggal(widget.jenis, _selectedDate);
        }

        int total = data.fold(0, (sum, item) => sum + item.jumlah);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            backgroundColor: widget.appBarColor,
            foregroundColor: Colors.white,
            actions: [
              if (_filterMode != FilterMode.semua)
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final now = DateTime.now();

                    if (_filterMode == FilterMode.harian) {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate.isAfter(now)
                            ? now
                            : _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: now,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: widget.appBarColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    } else if (_filterMode == FilterMode.bulanan) {
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
                                            icon: Icon(
                                              Icons.arrow_left,
                                              color: widget.appBarColor,
                                            ),
                                          ),
                                          Text(
                                            selectedYear.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: widget.appBarColor,
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
                                            icon: Icon(
                                              Icons.arrow_right,
                                              color: widget.appBarColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
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
                                                      ? widget.appBarColor
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
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: widget.appBarColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, {
                                        'year': selectedYear,
                                        'month': selectedMonth,
                                      });
                                    },
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: widget.appBarColor,
                                      ),
                                    ),
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: displayYear > 2020
                                                ? () {
                                                    setDialogState(() {
                                                      displayYear--;
                                                    });
                                                  }
                                                : null,
                                            icon: Icon(
                                              Icons.arrow_left,
                                              color: widget.appBarColor,
                                            ),
                                          ),
                                          Text(
                                            displayYear.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: widget.appBarColor,
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
                                            icon: Icon(
                                              Icons.arrow_right,
                                              color: widget.appBarColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
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
                                            bool isDisabled =
                                                year > now.year || year < 2020;

                                            return GestureDetector(
                                              onTap: isDisabled
                                                  ? null
                                                  : () => setDialogState(
                                                      () => selectedYear = year,
                                                    ),
                                              child: Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: isDisabled
                                                      ? Colors.grey[350]
                                                      : selectedYear == year
                                                      ? widget.appBarColor
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
                                    child: Text(
                                      'Batal',
                                      style: TextStyle(
                                        color: widget.appBarColor,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, selectedYear),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                        color: widget.appBarColor,
                                      ),
                                    ),
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
              PopupMenuButton<FilterMode>(
                icon: const Icon(Icons.filter_list),
                onSelected: (value) {
                  setState(() {
                    _filterMode = value;
                    final now = DateTime.now();
                    if (value == FilterMode.harian) {
                      _selectedDate = now;
                    } else if (value == FilterMode.bulanan) {
                      _selectedDate = DateTime(now.year, now.month, 1);
                    } else if (value == FilterMode.tahunan) {
                      _selectedDate = DateTime(now.year, 1, 1);
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
                              ? Colors.teal
                              : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Harian',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.harian
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.harian
                                ? Colors.teal
                                : Colors.black,
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
                              ? Colors.teal
                              : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Bulanan',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.bulanan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.bulanan
                                ? Colors.teal
                                : Colors.black,
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
                              ? Colors.teal
                              : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tahunan',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.tahunan
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.tahunan
                                ? Colors.teal
                                : Colors.black,
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
                              ? Colors.teal
                              : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Semua',
                          style: TextStyle(
                            fontWeight: _filterMode == FilterMode.semua
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _filterMode == FilterMode.semua
                                ? Colors.teal
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: widget.primaryColor.withOpacity(0.1),
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
              Expanded(
                child: data.isEmpty
                    ? const Center(child: Text('Tidak ada data'))
                    : ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (_, index) {
                          final t = data[index];
                          final isPemasukan = widget.jenis == 'pemasukan';
                          return ListTile(
                            title: Text(t.nama),
                            subtitle: Text(
                              DateFormat('dd/MM/yyyy').format(t.tanggal),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${isPemasukan ? '+' : '-'} Rp ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(t.jumlah)}',
                                  style: TextStyle(
                                    color: isPemasukan
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: widget.appBarColor,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormTransaksi(
                                          jenis: widget.jenis,
                                          transaksi: t,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${widget.title} berhasil diubah',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  tooltip: 'Edit',
                                ),
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
                                          'Apakah Anda yakin ingin menghapus ${widget.title.toLowerCase()} "${t.nama}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(
                                              'Batal',
                                              style: TextStyle(
                                                color: widget.appBarColor,
                                              ),
                                            ),
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
                                            backgroundColor: widget.appBarColor,
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
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormTransaksi(jenis: widget.jenis),
                ),
              );

              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${widget.title} berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            backgroundColor: widget.floatingActionButtonColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
