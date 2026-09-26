import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// --------------------------------------------------------------------
// Membuat sebuah kelas (Blueprint) bernama Kontak untuk menampung data
// --------------------------------------------------------------------
class Kontak {
  final int? id;
  final String namaKontak;
  final String nomorHP;
  final Uint8List? fotoKontak;
  Kontak({
    required this.id,
    required this.namaKontak,
    required this.nomorHP,
    this.fotoKontak,
  });

  // Fungsi untuk mengubah objek Kontak menjadi bentuk Map (pasangan key-value) agar bisa dibaca oleh sqflite saat Insert/Update
  Map<String, Object?> toMap() {
    return {
      'id': id, // Memasukkan nilai id ke key 'id'
      'namaKontak':
          namaKontak, // Memasukkan nilai namaKontak ke key 'namaKontak'
      'nomorHP': nomorHP, // Memasukkan nilai nomorHP ke key 'nomorHP'
      'fotoKontak':
          fotoKontak, // Memasukkan nilai fotoKontak ke key 'fotoKontak'
    };
  }

  // Konstruktor tambahan (Factory) untuk mengubah data dari format Map/Database kembali menjadi bentuk objek Kontak
  factory Kontak.fromMap(Map<String, dynamic> map) {
    return Kontak(
      id: map['id'] as int?,
      namaKontak: map['namaKontak'] as String,
      nomorHP: map['nomorHP'] as String,
      fotoKontak: map['fotoKontak'] as Uint8List?,
    );
  }

  // Override fungsi toString agar saat objek dicetak/di-print ke console, bentuknya terbaca jelas
  @override
  String toString() =>
      'Kontak{id: $id, namaKontak: $namaKontak, nomorHP: $nomorHP, fotoKontak: $fotoKontak}';
}

// -----------------------
// Membuat Database kontak
// -----------------------
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Membuat database dengan nama 'kontak.db'
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kontak.db');
    return _database!;
  }

  // Membuka database pada path, menentukan versi database, dan membuat tabel jika baru pertama kali dipasang
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kontak (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            namaKonatk TEXT,
            nomorHP TEXT,
            fotoKontak BLOB
          )
        ''');
      },
    );
  }

  // Fungsi CREATE (Menambah Data baru ke database dengan SQL Murni)
  Future<int> insertKontak(Kontak kontak) async {
    final db = await instance.database;
    // Menggunakan rawInsert dengan placeholder '?' untuk keamanan terhadap SQL Injection
    return await db.rawInsert(
      'INSERT INTO kontak (namaKontak, nomorHP, fotoKontak) VALUES (?, ?, ?)',
      [kontak.namaKontak, kontak.nomorHP, kontak.fotoKontak],
    );
  }

  // Fungsi READ (Mengambil / Membaca Semua Data dari database dengan SQL Murni)
  Future<List<Kontak>> getKontak() async {
    final db = await instance.database;
    // Menggunakan rawQuery untuk SELECT semua data
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT * FROM kontak',
    );
    return result.map((json) => Kontak.fromMap(json)).toList();
  }

  // Fungsi UPDATE (Mengubah / Memperbarui Data berdasarkan ID dengan SQL Murni)
  Future<int> updateKontak(Kontak kontak) async {
    final db = await instance.database;
    // Menggunakan rawUpdate
    return await db.rawUpdate(
      'UPDATE kontak SET namaKontak = ?, nomorHP = ?, fotoKontak = ? WHERE id = ?',
      [kontak.namaKontak, kontak.nomorHP, kontak.fotoKontak, kontak.id],
    );
  }

  // Fungsi DELETE (Menghapus Data dari database berdasarkan ID tertentu dengan SQL Murni)
  Future<int> deleteKontak(int id) async {
    final db = await instance.database;
    // Menggunakan rawDelete
    return await db.rawDelete('DELETE FROM kontak WHERE id = ?', [id]);
  }
}
