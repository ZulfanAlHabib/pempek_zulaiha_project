import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Menentukan lokasi penyimpanan database di HP
    String path = join(await getDatabasesPath(), 'pempek_zulaiha.db');

    // Membuat database dan tabelnya
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Membuat tabel Keranjang (Cart) SQLite
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE keranjang (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_produk TEXT NOT NULL,
        harga_produk TEXT NOT NULL,
        latitude TEXT,
        longitude TEXT,
        waktu_pesan TEXT
      )
    ''');
  }

  // Fungsi untuk MENYIMPAN data ke SQLite (Insert)
  Future<int> insertPesanan(Map<String, dynamic> pesanan) async {
    Database db = await database;
    return await db.insert('keranjang', pesanan);
  }

  // Fungsi untuk MENGAMBIL semua data dari SQLite (Select)
  Future<List<Map<String, dynamic>>> getSemuaPesanan() async {
    Database db = await database;
    return await db.query('keranjang', orderBy: 'id DESC');
  }

  // Fungsi untuk MENGHAPUS semua isi keranjang (Jika sudah dikirim ke server)
  Future<void> hapusSemuaPesanan() async {
    Database db = await database;
    await db.delete('keranjang');
  }
}
