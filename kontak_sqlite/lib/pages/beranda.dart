import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kontak_sqlite/pages/tambah_kontak.dart' as tambah_kontak;
import 'package:kontak_sqlite/database/database_helper.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // Fungsi untuk mengambil data dari database
  Future<List<Kontak>> _dataKontak() async {
    return await DatabaseHelper.instance.getKontak();
  }

  //Fungsi untuk memperbarui tampilan
  void _refreshData() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text("Kontak - SQLite"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Kontak>>(
          future: _dataKontak(),
          builder: (context, snapshot) {
            // Saat data masih dimuat, tampilkan animasi loading berputar
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // Ketika gagal/error mengambil data
            else if (snapshot.hasError) {
              return Center(
                child: Text("Terjadi kesaalahan: ${snapshot.error}"),
              );
            }
            // Ketika data kosong
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada kontak disimpan.\nTekan tombol + di bawah untuk menambah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }
            // Jika ada data, masukkan ke dalam gridview.builder
            final listKontak = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: listKontak.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Jumlah kolom ke samping
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8, // Perbandingan lebar dan tinggi card
                ),
                itemBuilder: (context, index) {
                  final kontak = listKontak[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Menampilkan foto dari database
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.memory(
                              kontak.fotoKontak,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12),
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
                  );
                },
              ),
            );
          },
        ),
      ),

      // Tombol tambah data
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Menunggu hingga kembali dari halaman TambahKontak untuk memperbarui data
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
