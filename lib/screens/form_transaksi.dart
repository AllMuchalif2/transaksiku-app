// ==================== IMPORT ====================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
// ==================== END IMPORT ====================

// ==================== FORMATTER UNTUK RUPIAH ====================
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
    // Menghapus semua karakter kecuali angka
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (newText.isEmpty) return newValue.copyWith(text: '');

    // Format ulang jadi rupiah
    final number = int.parse(newText);
    final newString = _formatter.format(number);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}
// ==================== END FORMATTER ====================

// ==================== FORM TRANSAKSI ====================
class FormTransaksi extends StatefulWidget {
  final String jenis; // pemasukan / pengeluaran
  final Transaksi? transaksi;

  const FormTransaksi({super.key, required this.jenis, this.transaksi});

  @override
  State<FormTransaksi> createState() => _FormTransaksiState();
}
// ==================== END HEADER WIDGET ====================

class _FormTransaksiState extends State<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();
  DateTime _tanggal = DateTime.now();

  // ==================== INISIALISASI ====================
  @override
  void initState() {
    super.initState();
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
  // ==================== END INISIALISASI ====================

  // ==================== SIMPAN TRANSAKSI ====================
  void _simpan() {
    if (_formKey.currentState!.validate()) {
      // Ambil hanya angka dari string
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
      if (widget.transaksi == null) {
        provider.tambahTransaksi(transaksiBaru);
      } else {
        provider.updateTransaksi(transaksiBaru);
      }

      Navigator.pop(context);
    }
  }
  // ==================== END SIMPAN ====================

  // ==================== PILIH TANGGAL ====================
  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
      });
    }
  }
  // ==================== END PILIH TANGGAL ====================

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaksi != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit ${widget.jenis}' : 'Tambah ${widget.jenis}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== Field Nama =====
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Transaksi'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              // ===== Field Jumlah Uang (Dengan Format Rupiah) =====
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah Uang'),
                keyboardType: TextInputType.number,
                inputFormatters: [CurrencyInputFormatter()],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Masukkan jumlah uang';
                  final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (cleaned.isEmpty || int.tryParse(cleaned) == null) {
                    return 'Masukkan angka valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // ===== Tanggal =====
              Row(
                children: [
                  Text('Tanggal: ${DateFormat('dd/MM/yyyy').format(_tanggal)}'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pilihTanggal,
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // ===== Tombol Simpan =====
              ElevatedButton.icon(
                onPressed: _simpan,
                icon: const Icon(Icons.save),
                label: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== END BUILD ====================
}

// ==================== END FORM TRANSAKSI ====================
