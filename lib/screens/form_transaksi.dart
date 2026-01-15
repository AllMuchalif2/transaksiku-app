import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';

/// Formatter untuk input mata uang Rupiah.
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Menghapus semua karakter non-numerik.
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return newValue.copyWith(text: '');

    // Memformat ulang angka menjadi format Rupiah.
    final number = int.parse(newText);
    final newString = _formatter.format(number);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

/// Widget untuk form tambah atau edit transaksi.
class FormTransaksi extends StatefulWidget {
  final String jenis; // Jenis transaksi: 'pemasukan' atau 'pengeluaran'.
  final Transaksi?
  transaksi; // Data transaksi jika dalam mode edit, null jika mode tambah.

  const FormTransaksi({super.key, required this.jenis, this.transaksi});

  @override
  State<FormTransaksi> createState() => _FormTransaksiState();
}

class _FormTransaksiState extends State<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Jika dalam mode edit, isi form dengan data yang ada.
    if (widget.transaksi != null) {
      _namaController.text = widget.transaksi!.nama;
      _jumlahController.text = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(widget.transaksi!.jumlah);
      _tanggal = widget.transaksi!.tanggal;
    }
  }

  /// Menyimpan data transaksi ke database.
  void _simpan() {
    if (_formKey.currentState!.validate()) {
      // Mengambil nilai angka dari input jumlah.
      final nilaiBersih = _jumlahController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final jumlahUang = int.parse(nilaiBersih);

      final transaksiBaru = Transaksi(
        id: widget.transaksi?.id,
        nama: _namaController.text,
        jumlah: jumlahUang,
        jenis: widget.jenis,
        tanggal: _tanggal,
      );

      final provider = Provider.of<TransaksiProvider>(context, listen: false);

      // Membedakan antara tambah data baru dan update data lama.
      if (widget.transaksi == null) {
        provider.tambahTransaksi(transaksiBaru);
      } else {
        provider.updateTransaksi(transaksiBaru);
      }

      Navigator.pop(context, true); // Kembali ke layar sebelumnya setelah simpan.
    }
  }

  /// Menampilkan dialog pemilih tanggal.
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
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
        _tanggal = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaksi != null;
    final title = isEdit ? 'Edit ${widget.jenis}' : 'Tambah ${widget.jenis}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Transaksi',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                cursorColor: Colors.teal,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Uang',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                cursorColor: Colors.teal,
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah uang wajib diisi';
                  }
                  final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleaned.isEmpty || int.tryParse(cleaned) == null) {
                    return 'Format angka tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(_tanggal)}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pilihTanggal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
