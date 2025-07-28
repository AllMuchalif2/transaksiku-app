import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaksi.dart';

class TransaksiProvider with ChangeNotifier {
  List<Transaksi> _daftarTransaksi = [];
  List<Transaksi> get daftarTransaksi => _daftarTransaksi;

  final _db = DatabaseHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTransaksi() async {
    _isLoading = true;
    notifyListeners();

    _daftarTransaksi = await _db.getTransaksi();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> tambahTransaksi(Transaksi trx) async {
    await _db.insertTransaksi(trx);
    await loadTransaksi();
  }

  Future<void> updateTransaksi(Transaksi trx) async {
    await _db.updateTransaksi(trx);
    await loadTransaksi();
  }

  Future<void> hapusTransaksi(int id) async {
    await _db.deleteTransaksi(id);
    await loadTransaksi();
  }

  // Tambahan: Filter berdasarkan jenis
  List<Transaksi> filterByJenis(String jenis) {
    return _daftarTransaksi.where((t) => t.jenis == jenis).toList();
  }

  // Tambahan: Hitung total pemasukan/pengeluaran
  int totalByJenis(String jenis) {
    return _daftarTransaksi
        .where((t) => t.jenis == jenis)
        .fold(0, (sum, t) => sum + t.jumlah);
  }

  // Tambahan: Total bersih (pemasukan - pengeluaran)
  int totalSelisih() {
    return totalByJenis('pemasukan') - totalByJenis('pengeluaran');
  }

  List<Transaksi> getByJenisHariIni(String jenis) {
    DateTime now = DateTime.now();
    return _daftarTransaksi
        .where(
          (t) =>
              t.jenis == jenis &&
              t.tanggal.year == now.year &&
              t.tanggal.month == now.month &&
              t.tanggal.day == now.day,
        )
        .toList();
  }

  List<Transaksi> getByJenisDanTanggal(String jenis, DateTime tanggal) {
    return _daftarTransaksi
        .where(
          (t) =>
              t.jenis == jenis &&
              t.tanggal.year == tanggal.year &&
              t.tanggal.month == tanggal.month &&
              t.tanggal.day == tanggal.day,
        )
        .toList();
  }

  List<Transaksi> getByJenisBulanIni(String jenis) {
    return _daftarTransaksi
        .where(
          (t) =>
              t.jenis == jenis &&
              t.tanggal.month == DateTime.now().month &&
              t.tanggal.year == DateTime.now().year,
        )
        .toList();
  }
}
