import 'package:app_uang/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaksi_provider.dart';

/// Layar untuk menampilkan halaman pengaturan.
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _buildThemeCard(context),
          _buildResetCard(context),
          _buildAboutCard(context),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListTile(
        leading: Icon(
          themeProvider.themeMode == ThemeMode.dark
              ? Icons.dark_mode
              : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
          size: 36,
        ),
        title: const Text(
          'Mode Gelap',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Ganti antara mode terang dan gelap'),
        trailing: Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleTheme();
          },
        ),
      ),
    );
  }

  Widget _buildResetCard(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListTile(
        leading: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.redAccent,
          size: 36,
        ),
        title: const Text(
          'Hapus Semua Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
        subtitle: const Text(
          'Tindakan ini akan menghapus semua catatan transaksi secara permanen.',
        ),
        onTap: () => _showConfirmationDialog(context),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListTile(
        leading: const Icon(
          Icons.info_outline,
          color: Colors.blueAccent,
          size: 36,
        ),
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Informasi aplikasi dan pengembang'),
        onTap: () => _showAboutDialog(context),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.teal),
            SizedBox(width: 10),
            Text('Tentang Aplikasi'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Transaksiku App v3.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Aplikasi sederhana untuk mencatat transaksi keuangan pribadi Anda. Dibangun dengan Flutter.',
              ),
              Divider(height: 30),
              Text(
                'Pengembang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 16),
              Row(children: [SizedBox(width: 8), Text('GitHub: AllMuchalif2')]),
              SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(width: 8),
                  Text('Instagram: @allmuchalif2'),
                ],
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Tutup', style: TextStyle(color: Colors.teal)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data transaksi? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteAllData(context);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _deleteAllData(BuildContext context) {
    final provider = Provider.of<TransaksiProvider>(context, listen: false);
    provider
        .hapusSemuaTransaksi()
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua data transaksi berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus data.'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
}
