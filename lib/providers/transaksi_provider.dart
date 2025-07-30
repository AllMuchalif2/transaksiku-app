// transaksi_provider.dart
import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/transaksi.dart';

class TransaksiProvider with ChangeNotifier {
  List<Transaksi> _daftarTransaksi = [];
  List<Transaksi> get daftarTransaksi => _daftarTransaksi;

  final _db = DatabaseHelper();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Memuat semua data transaksi dari database
  Future<void> loadTransaksi() async {
    _isLoading = true;
    notifyListeners();

    _daftarTransaksi = await _db.getTransaksi();

    _isLoading = false;
    notifyListeners();
  }

  // Menambah transaksi baru
  Future<void> tambahTransaksi(Transaksi trx) async {
    await _db.insertTransaksi(trx);
    await loadTransaksi();
  }

  // Mengupdate data transaksi
  Future<void> updateTransaksi(Transaksi trx) async {
    await _db.updateTransaksi(trx);
    await loadTransaksi();
  }

  // Menghapus transaksi berdasarkan ID
  Future<void> hapusTransaksi(int id) async {
    await _db.deleteTransaksi(id);
    await loadTransaksi();
  }

  // Filter: Semua transaksi berdasarkan jenis
  List<Transaksi> getByJenis(String jenis) {
    return _daftarTransaksi.where((t) => t.jenis == jenis).toList();
  }

  // Filter: Hari ini
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

  // Filter: Bulan ini
  List<Transaksi> getByJenisBulanIni(String jenis) {
    final now = DateTime.now();
    return _daftarTransaksi
        .where(
          (t) =>
              t.jenis == jenis &&
              t.tanggal.month == now.month &&
              t.tanggal.year == now.year,
        )
        .toList();
  }

  // Filter: Bulan ini
  List<Transaksi> getByJenisTahunIni(String jenis) {
    final now = DateTime.now();
    return _daftarTransaksi
        .where((t) => t.jenis == jenis && t.tanggal.year == now.year)
        .toList();
  }

  // Filter: Tanggal tertentu
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

  // Filter: Bulanan (bulan & tahun spesifik)
  List<Transaksi> getByJenisBulanan(String jenis, DateTime tanggal) {
    return _daftarTransaksi
        .where(
          (t) =>
              t.jenis == jenis &&
              t.tanggal.year == tanggal.year &&
              t.tanggal.month == tanggal.month,
        )
        .toList();
  }

  // Filter: Tahunan (hanya berdasarkan tahun)
  List<Transaksi> getByJenisTahunan(String jenis, int tahun) {
    return _daftarTransaksi
        .where((t) => t.jenis == jenis && t.tanggal.year == tahun)
        .toList();
  }

  // Hitung total berdasarkan jenis
  int totalByJenis(String jenis) {
    return _daftarTransaksi
        .where((t) => t.jenis == jenis)
        .fold(0, (sum, t) => sum + t.jumlah);
  }

  // Hitung total selisih (pemasukan - pengeluaran)
  int totalSelisih() {
    return totalByJenis('pemasukan') - totalByJenis('pengeluaran');
  }
}
