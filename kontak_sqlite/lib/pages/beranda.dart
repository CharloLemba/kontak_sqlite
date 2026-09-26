import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class Beranda extends StatefulWidget {
  const new({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  // Variabel unutk menampung foto/file atau path yang dipilih
  File? _fotoTerpilih;

  // Fungsi unutk mengambil gambar dari galeri
  Future<void> _ambilFotoDariGaleri() async {
    final ImagePicker picker = ImagePicker();
    // Buka galeri unutk pilih foto
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _fotoTerpilih = File(foto.path);
      });
    }
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
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
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _ambilFotoDariGaleri,
                  icon: Icon(Icons.refresh),
                  label: Text("Ganti Foto"),
                ),
              ] else ...[
                Card(
                  elevation: 10,
                  child: InkWell(
                    onTap: _ambilFotoDariGaleri,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 30, color: Colors.indigo),
                          SizedBox(height: 20),
                          Text("Silahkan ambil foto dari penyimpanan"),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),

      // Tombol tambah data
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 10,
        child: Icon(Icons.add),
      ),
    );
  }
}
