import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cctv.dart';

class FormPage extends StatefulWidget {
  final CCTV? cctv;

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameCtrl.text = widget.cctv!.name;
      locationCtrl.text = widget.cctv!.location;
      imageUrlCtrl.text = widget.cctv!.imageUrl;
    }
  }

  Future<String?> uploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return null;

    final bytes = await picked.readAsBytes(); // Convert to Uint8List
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(picked.path)}';

    final response = await supabase.storage
        .from('cctv-images') // ganti sesuai bucket kamu
        .uploadBinary(
          'public/$fileName',
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    if (response.isEmpty) return null;

    final imageUrl = supabase.storage
        .from('cctv-images')
        .getPublicUrl('public/$fileName');

    return imageUrl;
  }

  Future<void> saveData() async {
    print('saveData dipanggil'); // Tambahkan ini
    final data = {
      'name': nameCtrl.text,
      'location': locationCtrl.text,
      'image_url': imageUrlCtrl.text,
    };

    if (widget.cctv == null) {
      await supabase.from('cctvs').insert(data);
    } else {
      await supabase.from('cctvs').update(data).eq('id', widget.cctv!.id);
    }

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Gedung'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Lokasi'),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  onPressed: () async {
                    final url = await uploadImage();
                    if (url != null) {
                      imageUrlCtrl.text = url;
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 10),
                if (imageUrlCtrl.text.isNotEmpty)
                  Image.network(imageUrlCtrl.text, height: 150),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    print('Tombol Simpan ditekan'); // Tambahkan ini
                    if (_formKey.currentState!.validate()) {
                      print('Form valid, akan simpan data'); // Tambahkan ini
                      await saveData();
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
