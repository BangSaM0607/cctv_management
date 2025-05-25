import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cctv.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

class FormPage extends StatefulWidget {
  final CCTV? cctv; // CCTV yang akan diedit, null jika untuk tambah baru
  const FormPage({
    super.key,
    this.cctv,
  }); // Konstruktor untuk menerima CCTV yang akan diedit

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  // GlobalKey untuk mengelola state dari Form
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameCtrl.text =
          widget.cctv!.name; // Mengisi controller dengan data CCTV yang ada
      locationCtrl.text =
          widget.cctv!.location; // Mengisi controller dengan lokasi CCTV
      imageUrlCtrl.text =
          widget.cctv!.imageUrl; // Mengisi controller dengan URL gambar CCTV
    }
  }

  Future<String?> uploadImage() async {
    final picker =
        ImagePicker(); // Inisialisasi ImagePicker untuk memilih gambar
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    ); // Memilih gambar dari galeri
    if (picked == null)
      return null; // Jika tidak ada gambar yang dipilih, kembalikan null

    final file = File(picked.path); // Mengambil file dari path yang dipilih
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}'; // Membuat nama file unik berdasarkan waktu dan nama asli file

    final response = await supabase.storage
        .from('cctv-images') // Sesuaikan nama bucket
        .upload(
          'public/$fileName', // Menyimpan file di dalam folder 'public' di bucket 'cctv-images'
          file,
          fileOptions: const FileOptions(
            upsert: true,
          ), // Mengizinkan upsert (update atau insert) file
        );

    if (response.isEmpty)
      return null; // Jika tidak ada respons, kembalikan null

    final url = supabase.storage
        .from('cctv-images')
        .getPublicUrl(
          'public/$fileName',
        ); // Mendapatkan URL publik dari file yang diupload
    return url; // Mengembalikan URL gambar yang diupload
  }

  Future<void> saveData() async {
    final map = {
      'name': nameCtrl.text, // Mengambil nama dari controller
      'location': locationCtrl.text, // Mengambil lokasi dari controller
      'image_url': imageUrlCtrl.text, // Mengambil URL gambar dari controller
    };

    if (widget.cctv == null) {
      await supabase
          .from('cctvs')
          .insert(map); // Menyimpan data baru jika CCTV belum ada
    } else {
      await supabase
          .from('cctvs')
          .update(map)
          .eq('id', widget.cctv!.id); // Mengupdate data CCTV yang sudah ada
    }

    if (context.mounted)
      Navigator.pop(
        context,
      ); // Kembali ke halaman sebelumnya setelah menyimpan data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV',
        ), // Judul dinamis berdasarkan apakah ini untuk tambah atau edit
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ), // Padding untuk memberikan jarak di sekitar form
        child: Form(
          key:
              _formKey, // Menggunakan GlobalKey untuk mengelola state dari Form
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl, // Controller untuk nama gedung
                decoration: const InputDecoration(
                  labelText: 'Nama Gedung',
                ), // Label untuk field nama gedung
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null, // Validasi untuk memastikan nama tidak kosong
              ),
              TextFormField(
                controller: locationCtrl, // Controller untuk lokasi CCTV
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                ), // Label untuk field lokasi
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Lokasi wajib diisi'
                            : null, // Validasi untuk memastikan lokasi tidak kosong
              ),
              TextFormField(
                controller: imageUrlCtrl, // Controller untuk URL gambar CCTV
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                ), // Label untuk field URL gambar
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'URL gambar  wajib diisi'
                            : null, // Validasi untuk memastikan URL gambar tidak kosong
              ),
              TextFormField(
                controller: imageUrlCtrl, // Controller untuk URL gambar CCTV
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                ), // Label untuk field URL gambar
              ),
              const SizedBox(height: 10),
              // Tombol upload gambar
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text('Upload Gambar'),
                onPressed: () async {
                  final url = await uploadImage();
                  if (url != null) {
                    setState(() {
                      imageUrlCtrl.text = url;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gambar berhasil diupload!'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upload gambar dibatalkan!'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20), // Jarak antar field
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveData();
                  }
                }, // Validasi form sebelum menyimpan data
                child: const Text('Simpan'),
              ), // Tombol untuk menyimpan data
            ],
          ),
        ),
      ),
    );
  }
}
