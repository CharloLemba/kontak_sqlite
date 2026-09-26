import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_sqlite/database/database_helper.dart';

class TambahKontak extends StatefulWidget {
  const TambahKontak({super.key});

  @override
  State<TambahKontak> createState() => _TambahKontakState();
}

class _TambahKontakState extends State<TambahKontak> {
  // Menyimpan foto yang dipilih
  File? _fotoTerpilih;

  // Controller TextField
  final TextEditingController namaKontakController = TextEditingController();
  final TextEditingController nomorHPController = TextEditingController();

  // Mengambil foto dari galeri
  Future<void> _ambilFotoDariGaleri() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _fotoTerpilih = File(foto.path);
      });
    }
  }

  // Menyimpan kontak
  Future<void> simpanKontak() async {
    final String namaKontak = namaKontakController.text.trim();
    final String nomorHPKontak = nomorHPController.text.trim();

    // Pastikan foto sudah dipilih
    if (_fotoTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih foto terlebih dahulu')),
      );
      return;
    }

    // Ubah foto menjadi Uint8List
    final Uint8List fotoBytes = await _fotoTerpilih!.readAsBytes();

    // Buat object Kontak
    final kontakBaru = Kontak(
      id: null,
      namaKontak: namaKontak,
      nomorHP: nomorHPKontak,
      fotoKontak: fotoBytes,
    );

    try {
      await DatabaseHelper.instance.insertKontak(kontakBaru);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kontak berhasil disimpan!')),
      );
      // Kembali setelah berhasil menyimpan
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kontak gagal disimpan!\n$e')));
    }
  }

  @override
  void dispose() {
    namaKontakController.dispose();
    nomorHPController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Tambah Kontak'),
        centerTitle: true,
      ),

      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // =========================
              // FOTO
              // =========================
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
              ] else ...[
                Card(
                  elevation: 10,
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

              // =========================
              // FORM
              // =========================
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
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

      // =========================
      // BUTTON SIMPAN
      // =========================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (namaKontakController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama kontak belum diisi')),
                  );
                  return;
                }

                if (nomorHPController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nomor HP belum diisi')),
                  );
                  return;
                }

                if (_fotoTerpilih == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto belum dipilih')),
                  );
                  return;
                }

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
