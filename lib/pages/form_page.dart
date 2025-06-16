import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cctv.dart';
import 'package:uuid/uuid.dart';

class FormPage extends StatefulWidget {
  final CCTV? cctv;

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  File? selectedImage;
  bool isUploading = false;
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameCtrl.text = widget.cctv!.name;
      locationCtrl.text = widget.cctv!.location;
      isActive = widget.cctv!.status;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File file) async {
    final fileName = const Uuid().v4();
    final storage = supabase.storage.from('cctv-images');
    final response = await storage.upload('public/$fileName.jpg', file);
    if (response != null) {
      return storage.getPublicUrl('public/$fileName.jpg');
    }
    return null;
  }

  Future<void> saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);
    String imageUrl = widget.cctv?.imageUrl ?? '';

    if (selectedImage != null) {
      final url = await uploadImage(selectedImage!);
      if (url != null) imageUrl = url;
    }

    final data = {
      'name': nameCtrl.text,
      'location': locationCtrl.text,
      'image_url': imageUrl,
      'status': isActive,
    };

    if (widget.cctv == null) {
      await supabase.from('cctvs').insert(data);
    } else {
      await supabase.from('cctvs').update(data).eq('id', widget.cctv!.id);
    }

    setState(() => isUploading = false);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            isUploading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nama Gedung',
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: locationCtrl,
                        decoration: const InputDecoration(labelText: 'Lokasi'),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Wajib diisi'
                                    : null,
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        title: const Text('CCTV Aktif'),
                        value: isActive,
                        onChanged:
                            (val) => setState(() => isActive = val ?? false),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Gambar'),
                      ),
                      if (selectedImage != null)
                        Image.file(
                          selectedImage!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: saveData,
                        child: const Text('Simpan'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
