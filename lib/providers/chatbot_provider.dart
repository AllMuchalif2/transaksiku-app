import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import 'transaksi_provider.dart';

class ChatBotProvider with ChangeNotifier {
  // State untuk menyimpan list pesan
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // Getter agar UI bisa membaca data
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  // 1. App Secret untuk autentikasi backend
  static const String _appSecret = 'u-didnt-even-know';

  // 2. URL Backend
  final String _apiUrl = 'https://groq-for-transaksiku-app.vercel.app/api/bot';

  // Fungsi Utama: Kirim Pesan
  Future<void> sendMessage(
    String userMessage,
    TransaksiProvider transaksiProvider,
  ) async {
    // 1. Tambahkan pesan user ke UI (Optimistic UI)
    _messages.add({'role': 'user', 'text': userMessage});
    _isLoading = true;
    notifyListeners(); // Kabari UI untuk update

    try {
      // 2. Siapkan Context (Data transaksi terakhir agar AI pintar)
      final recentTransactions = transaksiProvider.daftarTransaksi
          .take(20)
          .map((t) => t.toMap())
          .toList();

      // 3. Kirim Request ke Backend
      final response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Content-Type': 'application/json',
              'x-app-secret': _appSecret,
            },
            body: jsonEncode({
              'message': userMessage,
              'transactions': recentTransactions,
            }),
          )
          .timeout(const Duration(seconds: 60));

      // 4. Proses Respon
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botData = data['data'];

        if (botData['type'] == 'transaction_created') {
          // --- KASUS: Input Transaksi Otomatis ---
          final result = botData['result'];

          // Buat objek Transaksi
          final newTrx = Transaksi(
            nama: result['nama'],
            jumlah: result['jumlah'],
            jenis: result['jenis'],
            tanggal: DateTime.parse(result['tanggal']),
          );

          // Simpan ke Database via Provider Transaksi
          await transaksiProvider.tambahTransaksi(newTrx);

          // Tambahkan pesan sukses dari Bot
          _messages.add({
            'role': 'bot',
            'text':
                '${botData['message']}\n\n'
                'Item: ${newTrx.nama}\n'
                'Nominal: Rp ${NumberFormat("#,##0", "id_ID").format(newTrx.jumlah)}\n'
                'Tgl: ${DateFormat('dd MMM yyyy').format(newTrx.tanggal)}',
            'type': 'success',
          });
        } else {
          // --- KASUS: Chat Biasa ---
          _messages.add({
            'role': 'bot',
            'text': botData['message'],
            'type': 'text',
          });
        }
      } else {
        // Jika masih error, tampilkan status codenya untuk debugging
        throw Exception(
          'Gagal terhubung ke server (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      _messages.add({
        'role': 'bot',
        'text':
            'Terjadi kesalahan:\n$e\n\nPastikan backend sudah di-deploy ulang dengan route /api/bot.',
        'type': 'error',
      });
    } finally {
      _isLoading = false;
      notifyListeners(); // Stop loading
    }
  }

  // Opsional: Fungsi untuk membersihkan chat
  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
