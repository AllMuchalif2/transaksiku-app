import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import 'package:provider/provider.dart';

class FormTransaksi extends StatefulWidget {
  final String jenis; // pemasukan / pengeluaran
  final Transaksi? transaksi;

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
    if (widget.transaksi != null) {
      _namaController.text = widget.transaksi!.nama;
      _jumlahController.text = widget.transaksi!.jumlah.toString();
      _tanggal = widget.transaksi!.tanggal;
    }
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final transaksiBaru = Transaksi(
        id: widget.transaksi?.id,
        nama: _namaController.text,
        jumlah: int.parse(_jumlahController.text),
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

  Future<void> _pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Transaksi'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah Uang'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || int.tryParse(value) == null
                    ? 'Masukkan angka valid'
                    : null,
              ),
              const SizedBox(height: 16),
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
}
