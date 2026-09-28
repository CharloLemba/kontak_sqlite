import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_sqlite/database/database_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as foto_path;

class TambahKontak extends StatefulWidget {
  const TambahKontak({super.key});

  @override
  State<TambahKontak> createState() => _TambahKontakState();
}

class _TambahKontakState extends State<TambahKontak> {
  // -------------------------------------------------------
  // Membuat variabel unutk menampung foto yang dipilih user
  // -------------------------------------------------------
  File? _fotoTerpilih;

  // ------------------------------------------------------------
  // controller untuk menangkap input di textfiel nama & nomor hp
  // ------------------------------------------------------------
  final TextEditingController namaKontakController = TextEditingController();
  final TextEditingController nomorHPController = TextEditingController();

  // -----------------------------------------------
  // Fungsi untuk mengambil file foto dari galeri hp
  // -----------------------------------------------
  Future<void> _ambilFotoDariGaleri() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _fotoTerpilih = File(foto.path);
      });
    }
  }

  // -----------------------------------------------------------------------------------------
  // Fungsi untuk menyalin file ke direktori internal aplikasi dan mengembalikan path finalnya
  // -----------------------------------------------------------------------------------------
  Future<String> _simpanFileKeStorage(File fileGambar) async {
    final Directory direktoriApp = await getApplicationDocumentsDirectory();
    final String namaFile =
        '${DateTime.now().millisecondsSinceEpoch}_${foto_path.basename(fileGambar.path)}';
    final String pathTujuan = foto_path.join(direktoriApp.path, namaFile);

    // -----------------------------------
    // Salin file ke folder lokal aplikasi
    // -----------------------------------
    final File fileBaru = await fileGambar.copy(pathTujuan);
    return fileBaru.path;
  }

  // -------------------------------------------------------------------------------------
  // Fungsi untuk menyimpan data foto terpilih, nama dan nomor handphone ke dalam database
  // -------------------------------------------------------------------------------------
  Future<void> simpanKontak() async {
    final String namaKontak = namaKontakController.text.trim();
    final String nomorHPKontak = nomorHPController.text.trim();

    if (_fotoTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto terlebih dahulu')),
      );
      return;
    }

    try {
      // ------------------------------------------------------------
      // Simpan file gambar secara fisik ke storage internal aplikasi
      // ------------------------------------------------------------
      final String pathFinal = await _simpanFileKeStorage(_fotoTerpilih!);

      // --------------------------------------------------------------------------------
      // Buat variabel kontakBaru untuk dimasukan ke dalam objek Kontak di dalam database
      // --------------------------------------------------------------------------------
      final kontakBaru = Kontak(
        id: null,
        namaKontak: namaKontak,
        nomorHP: nomorHPKontak,
        fotoPath: pathFinal,
      );

      // --------------------------------------------------------------
      // Lakukakn fungsi insertKontak untuk memasukkan data ke database
      // --------------------------------------------------------------
      await DatabaseHelper.instance.insertKontak(kontakBaru);

      // ---------------------------------------------------------
      // Menampilkan pesan jika data berhasil disimpan ke database
      // ---------------------------------------------------------
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil disimpan!')),
      );
      Navigator.pop(context);
    }
    // ------------------------------------------------------
    // Menampilkan pesan jika data gagal disimpan ke database
    // ------------------------------------------------------
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kontak gagal disimpan!\n$e')));
    }
  }

  // ------------------------------------------------------------------
  // (WAJIB) Fungsi untuk dispose controllers textfield nama & nomor hp
  // ------------------------------------------------------------------
  @override
  void dispose() {
    namaKontakController.dispose();
    nomorHPController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------------------------
      // AppBar Aplikasi - Tampilan TambahKontak
      // ---------------------------------------
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
        centerTitle: true,
      ),
      // ---------------------------------------------
      // Bagian utama aplikasi - Tampilan TambahKontak
      // ---------------------------------------------
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ----------------------------------------
                // Menampilkan foto yang sudah dipilih user
                // ----------------------------------------
                if (_fotoTerpilih != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _fotoTerpilih!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _ambilFotoDariGaleri,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ganti Foto'),
                  ),
                ]
                // -------------------------------
                // Membuat Card untuk memilih foto
                // -------------------------------
                else ...[
                  Card(
                    elevation: 10,
                    // --------------------------------------------------------------------
                    // InkWell agar Card bisa di-tap dan user bisa memilih foto dari galeri
                    // --------------------------------------------------------------------
                    child: InkWell(
                      onTap: _ambilFotoDariGaleri,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 30, color: Colors.indigo),
                            SizedBox(height: 20),
                            Text('Silakan ambil foto dari penyimpanan'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // ----------------------------------------
                // Sebuah Card yang menampung dua Textfield
                // ----------------------------------------
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // -------------------------------------------------------
                          // Dua Textfield untuk user dapat mengetik nama & nomor hp
                          // -------------------------------------------------------
                          TextField(
                            controller: namaKontakController,
                            decoration: const InputDecoration(
                              labelText: 'Nama Kontak',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: nomorHPController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Nomor Handphone',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // ---------------------------------------
      // Tombol untuk menyimpan data ke database
      // ---------------------------------------
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          // ------------------------------------------------------------------------------------------
          // SizedBox dengan width: double.infinity agar tombol yang memanjang berada di bawah scaffold
          // ------------------------------------------------------------------------------------------
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // -------------------------------------------------------
                // Menampilkan peringatan kalau Textfield nama belum diisi
                // -------------------------------------------------------
                if (namaKontakController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama kontak belum diisi')),
                  );
                  return;
                }
                // -----------------------------------------------------------
                // Menampilkan peringatan kalau Textfield nomor hp belum diisi
                // -----------------------------------------------------------
                if (nomorHPController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor HP belum diisi')),
                  );
                  return;
                }
                // --------------------------------------------------------
                // Menampilkan peringatan kalau belum ada foto yang dipilih
                // --------------------------------------------------------
                if (_fotoTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto belum dipilih')),
                  );
                  return;
                }
                // -------------------------------
                // Memanggil fungsi simpanKontak()
                // -------------------------------
                await simpanKontak();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SIMPAN KONTAK',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
