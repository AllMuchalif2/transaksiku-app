import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaksi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    return _db ??= await _initDb();
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'keuangan.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT,
        jumlah INTEGER,
        jenis TEXT,
        tanggal TEXT
      )
    ''');
  }

  Future<int> insertTransaksi(Transaksi trx) async {
    final dbClient = await db;
    return await dbClient.insert('transaksi', trx.toMap());
  }

  Future<List<Transaksi>> getTransaksi() async {
    final dbClient = await db;
    final maps = await dbClient.query('transaksi', orderBy: 'tanggal DESC');
    return maps.map((e) => Transaksi.fromMap(e)).toList();
  }

  Future<int> updateTransaksi(Transaksi trx) async {
    final dbClient = await db;
    return await dbClient.update(
      'transaksi',
      trx.toMap(),
      where: 'id = ?',
      whereArgs: [trx.id],
    );
  }

  Future<int> deleteTransaksi(int id) async {
    final dbClient = await db;
    return await dbClient.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final dbClient = await db;
    dbClient.close();
  }
}
