import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cctv.dart';

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
              ),
              TextFormField(
                controller: locationCtrl, // Controller untuk lokasi CCTV
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                ), // Label untuk field lokasi
              ),
              TextFormField(
                controller: imageUrlCtrl, // Controller untuk URL gambar CCTV
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                ), // Label untuk field URL gambar
              ),
              const SizedBox(height: 20), // Jarak antar field
              ElevatedButton(
                onPressed: saveData,
                child: const Text('Simpan'),
              ), // Tombol untuk menyimpan data
            ],
          ),
        ),
      ),
    );
  }
}
