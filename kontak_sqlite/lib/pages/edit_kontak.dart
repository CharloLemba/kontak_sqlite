import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kontak_sqlite/database/database_helper.dart';
import 'package:kontak_sqlite/widgets/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as foto_path;
import 'package:url_launcher/url_launcher.dart';

class EditKontak extends StatefulWidget {
  final Kontak kontak;

  const EditKontak({super.key, required this.kontak});

  @override
  State<EditKontak> createState() => _EditKontakState();
}

class _EditKontakState extends State<EditKontak> {
  // =======================================================
  // Membuat variabel unutk menampung foto yang dipilih user
  // =======================================================
  File? _fotoTerpilih;

  // ============================================================
  // controller untuk menangkap input di textfiel nama & nomor hp
  // ============================================================
  late TextEditingController namaKontakController;
  late TextEditingController nomorHPController;

  // ===========================================================================================
  // Fungsi untuk mengambil data nomor & nomor hp dari tabel terpilih di database berdasarkan id
  // ===========================================================================================
  @override
  void initState() {
    super.initState();
    namaKontakController = TextEditingController(
      text: widget.kontak.namaKontak,
    );
    nomorHPController = TextEditingController(text: widget.kontak.nomorHP);
  }

  // ===============================================
  // Fungsi untuk mengambil file foto dari galeri hp
  // ===============================================
  Future<void> _ambilFotoDariGaleri() async {
    final ImagePicker picker = ImagePicker();
    final XFile? foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        _fotoTerpilih = File(foto.path);
      });
    }
  }

  // =========================================================================================
  // Fungsi untuk menyalin file ke direktori internal aplikasi dan mengembalikan path finalnya
  // =========================================================================================
  Future<String> _simpanFileKeStorage(File fileGambar) async {
    final Directory direktoriApp = await getApplicationDocumentsDirectory();
    final String namaFile =
        '${DateTime.now().millisecondsSinceEpoch}_${foto_path.basename(fileGambar.path)}';
    final String pathTujuan = foto_path.join(direktoriApp.path, namaFile);
    // ===================================
    // Salin file ke folder lokal aplikasi
    // ===================================
    final File fileBaru = await fileGambar.copy(pathTujuan);
    return fileBaru.path;
  }

  // ==============================================================
  // Fungsi untuk perbarui data ke database berdasarkan id terpilih
  // ==============================================================
  Future<void> prosesUpdateKontak() async {
    final String namaKontak = namaKontakController.text.trim();
    final String nomorHPKontak = nomorHPController.text.trim();

    String pathFotoFinal = widget.kontak.fotoPath;

    // =================================================================
    // Jika user memilih foto baru, simpan ke storage dan timpa path-nya
    // =================================================================
    if (_fotoTerpilih != null) {
      pathFotoFinal = await _simpanFileKeStorage(_fotoTerpilih!);

      // ======================================================
      // (WAJIB) Hapus file lama jika mau bersih-bersih storage
      // ======================================================
      try {
        final fileLama = File(widget.kontak.fotoPath);
        if (await fileLama.exists()) {
          await fileLama.delete();
        }
      } catch (_) {}
    }

    // ================================================================================
    // Buat variabel kontakBaru untuk dimasukan ke dalam objek Kontak di dalam database
    // ================================================================================
    final kontakBaru = Kontak(
      id: widget.kontak.id,
      namaKontak: namaKontak,
      nomorHP: nomorHPKontak,
      fotoPath: pathFotoFinal,
    );

    try {
      // ==================================================================================
      // Lakukakn fungsi insertupdateKontakKontak untuk memperbarui data kontak ke database
      // ==================================================================================
      await DatabaseHelper.instance.updateKontak(kontakBaru);
      // ===========================================================
      // Menampilkan pesan jika data berhasil diperbarui ke database
      // ===========================================================
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kontak berhasil diedit!')));
      Navigator.pop(context, true);
    }
    // ========================================================
    // Menampilkan pesan jika data gagal diperbarui ke database
    // ========================================================
    catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Kontak gagal diedit!\n$e')));
    }
  }

  // =======================================
  // Fungsi untuk hapus kontak dari database
  // =======================================
  Future<void> prosesHapusKontak() async {
    // ===============================================
    // Menampilkan modal untuk konfirmasi hapus dialog
    // ===============================================
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
      // ===============================
      // Hapus data kontak dari database
      // ===============================
      await DatabaseHelper.instance.deleteKontak(widget.kontak.id!);

      // =====================================================
      // (WAJIB) Hapus file fisik gambarnya dari storage lokal
      // =====================================================
      try {
        final fileGambar = File(widget.kontak.fotoPath);
        if (await fileGambar.exists()) {
          await fileGambar.delete();
        }
      } catch (_) {}

      // ==========================================
      // Menampilkan pesan kontak berhaasil dihapus
      // ==========================================
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kontak berhasil dihapus!')));
      Navigator.pop(context, true);
    }
  }

  // ====================================================================
  // Fungsi untuk melakukan panggilan ke nomor hp yang sudah diinput user
  // ====================================================================
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

  // ===================================================================
  // Fungsi untuk mengirim pesan/SMS ke nomor hp yang sudah diinput user
  // ===================================================================
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

  // ==================================================================
  // (WAJIB) Fungsi untuk dispose controllers textfield nama & nomor hp
  // ==================================================================
  @override
  void dispose() {
    namaKontakController.dispose();
    nomorHPController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // =====================================
      // AppBar Aplikasi - Tampilan EditKontak
      // =====================================
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: const Text('Edit Kontak'),
        centerTitle: true,
      ),
      // ===========================================
      // Bagian utama aplikasi - Tampilan EditKontak
      // ===========================================
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ========================================
                // Menampilkan foto yang sudah dipilih user
                // ========================================
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
                // =================================
                // Membuat Card untuk mengganti foto
                // =================================
                else ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        // =======================================================
                        // Menampilkan foto yang sudah ada dari path lokal storage
                        // =======================================================
                        child: Image.file(
                          File(widget.kontak.fotoPath),
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 250,
                              height: 250,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
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
                // ========================================
                // Sebuah Card yang menampung dua Textfield
                // ========================================
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // =======================================================
                          // Dua Textfield untuk user dapat mengetik nama & nomor hp
                          // =======================================================
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
      // =======================================================================
      // Tombol untuk memperbarui data ke database,
      // diambil dari Row() berisi empat tombol dari file
      // widgets.dart yang ada di direktori "kontak_sqlite/widgets/widgets.dart"
      // =======================================================================
      bottomNavigationBar: BottomActionButtons(
        onSave: () async {
          // ==================================================================
          // Menampilkan peringatan kalau Textfield nama & nomor hp belum diisi
          // ==================================================================
          if (namaKontakController.text.trim().isEmpty ||
              nomorHPController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nama dan Nomor HP tidak boleh kosong!'),
              ),
            );
            return;
          }
          // =====================================
          // Memanggil fungsi prosesUpdateKontak()
          // =====================================
          await prosesUpdateKontak();
        },
        // ==================================
        // Memanggil fungsi prosesHapusKontak
        // ==================================
        onDelete: prosesHapusKontak,
        // ==============================
        // Memanggil fungsi _panggilNomor
        // ==============================
        onCall: _panggilNomor,
        // ============================
        // Memanggil fungsi _kirimPesan
        // ============================
        onMessage: _kirimPesan,
      ),
    );
  }
}
