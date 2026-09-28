import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kontak_sqlite/pages/tambah_kontak.dart' as tambah_kontak;
import 'package:kontak_sqlite/database/database_helper.dart';
import 'package:kontak_sqlite/pages/edit_kontak.dart' as edit_kontak;

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // -----------------------------------
  // Mengambil data kontak dari database
  // -----------------------------------
  Future<List<Kontak>> _dataKontak() async {
    return await DatabaseHelper.instance.getKontak();
  }

  // -------------------------
  // Fungsi untuk refresh data
  // -------------------------
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ----------------------------------
      // AppBar Aplikasi - Tampilan Beranda
      // ----------------------------------
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text("Kontak - SQLite"),
        centerTitle: true,
      ),
      // ----------------------------------------
      // Bagian utama aplikasi - Tampilan Beranda
      // ----------------------------------------
      body: SafeArea(
        // ------------------------------------------------
        // Fungsi untuk mengambil data kontak dari database
        // ------------------------------------------------
        child: FutureBuilder<List<Kontak>>(
          future: _dataKontak(),
          builder: (context, snapshot) {
            // ---------------------------------------------------------------------------
            // Fungsi jika masih mengambil data dari database, menampilkan animasi loading
            // ---------------------------------------------------------------------------
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // ----------------------------------------------------------------------
            // Fungsi untuk menampilkan error saat gagal mengambil data dari database
            // ----------------------------------------------------------------------
            else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi kesalahan: ${snapshot.error}"),
              );
            }
            // -------------------------------------------------------------
            // Fungsi untuk menampilkan data yang masih kosong dari database
            // -------------------------------------------------------------
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada kontak disimpan.\nTekan tombol + di bawah untuk menambah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            // --------------------------------------------
            // Menampilkan daftar data kontak dari database
            // --------------------------------------------
            final listKontak = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(12),
              // ---------------------------------------------------------------------
              // Data dimunculkan ke dalam bentuk sebuah Card didalam GridView.builder
              // ---------------------------------------------------------------------
              child: GridView.builder(
                itemCount: listKontak.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final kontak = listKontak[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // -------------------------------------------------------------------
                    // InkWell agar Card bisa di-tap dan dialihkan ke halaman EditKontak()
                    // -------------------------------------------------------------------
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                edit_kontak.EditKontak(kontak: kontak),
                          ),
                        );
                        _refreshData();
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --------------------------------------------------------------------------------
                          // Menampilkan gambar dari File Path lokal aplikasi dengan sudut rounded/melengkung
                          // --------------------------------------------------------------------------------
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.file(
                                File(kontak.fotoPath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // -----------------------------------------------------------------------------------------
                          // Untuk menampilkan data nama & nomor hp dari database kedalam sebuah Column dengan Padding
                          // -----------------------------------------------------------------------------------------
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  kontak.namaKontak,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  kontak.nomorHP,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      // --------------------------------------------------------------------------
      // Tombol tambah kontak, yang akan mengalihkan user ke halaman TambahKontak()
      // --------------------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => const tambah_kontak.TambahKontak(),
            ),
          );
          _refreshData();
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 10,
        child: const Icon(Icons.add),
      ),
    );
  }
}
