import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_sqlite/database/database_helper.dart';
import 'package:kontak_sqlite/widgets/widgets.dart'; // <-- Import file widgets.dart kamu
import 'package:url_launcher/url_launcher.dart';

class EditKontak extends StatefulWidget {
  final Kontak kontak;

  const EditKontak({super.key, required this.kontak});

  @override
  State<EditKontak> createState() => _EditKontakState();
}

class _EditKontakState extends State<EditKontak> {
  File? _fotoTerpilih;

  late TextEditingController namaKontakController;
  late TextEditingController nomorHPController;

  @override
  void initState() {
    super.initState();
    namaKontakController = TextEditingController(
      text: widget.kontak.namaKontak,
    );
    nomorHPController = TextEditingController(text: widget.kontak.nomorHP);
  }

  Future<void> _ambilFotoDariGaleri() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _fotoTerpilih = File(foto.path);
      });
    }
  }

  Future<void> prosesUpdateKontak() async {
    final String namaKontak = namaKontakController.text.trim();
    final String nomorHPKontak = nomorHPController.text.trim();

    Uint8List fotoBytes;
    if (_fotoTerpilih != null) {
      fotoBytes = await _fotoTerpilih!.readAsBytes();
    } else {
      fotoBytes = widget.kontak.fotoKontak;
    }

    final kontakBaru = Kontak(
      id: widget.kontak.id,
      namaKontak: namaKontak,
      nomorHP: nomorHPKontak,
      fotoKontak: fotoBytes,
    );

    try {
      await DatabaseHelper.instance.updateKontak(kontakBaru);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kontak berhasil diedit!')));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kontak gagal diedit!\n$e')));
    }
  }

  Future<void> prosesHapusKontak() async {
    bool? konfirmasi = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kontak'),
        content: Text('Yakin ingin menghapus ${widget.kontak.namaKontak}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await DatabaseHelper.instance.deleteKontak(widget.kontak.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kontak berhasil dihapus!')));
      Navigator.pop(context, true);
    }
  }

  Future<void> _panggilNomor() async {
    final Uri url = Uri(scheme: 'tel', path: nomorHPController.text.trim());
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi telepon')),
      );
    }
  }

  Future<void> _kirimPesan() async {
    final Uri url = Uri(scheme: 'sms', path: nomorHPController.text.trim());
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka aplikasi pesan')),
      );
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
        title: const Text('Edit Kontak'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _ambilFotoDariGaleri,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Ganti Foto'),
                  ),
                ] else ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          widget.kontak.fotoKontak,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        child: ElevatedButton.icon(
                          onPressed: _ambilFotoDariGaleri,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Ubah Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 20),

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
                              labelText: "Nama Kontak",
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

      // Panggil Widget kustom dari file widgets.dart dengan sangat bersih di sini!
      bottomNavigationBar: BottomActionButtons(
        onSave: () async {
          if (namaKontakController.text.trim().isEmpty ||
              nomorHPController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nama dan Nomor HP tidak boleh kosong!'),
              ),
            );
            return;
          }
          await prosesUpdateKontak();
        },
        onDelete: prosesHapusKontak,
        onCall: _panggilNomor,
        onMessage: _kirimPesan,
      ),
    );
  }
}
