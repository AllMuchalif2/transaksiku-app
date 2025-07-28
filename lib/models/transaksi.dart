class Transaksi {
  final int? id;
  final String nama;
  final int jumlah;
  final String jenis; // 'pemasukan' atau 'pengeluaran'
  final DateTime tanggal;

  Transaksi({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.jenis,
    required this.tanggal,
  });

  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'],
      nama: map['nama'],
      jumlah: map['jumlah'],
      jenis: map['jenis'],
      tanggal: DateTime.parse(map['tanggal']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'jenis': jenis,
      'tanggal': tanggal.toIso8601String(),
    };
  }
}
