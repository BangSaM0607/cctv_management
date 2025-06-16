import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/cctv.dart';

class FormPage extends StatefulWidget {
  final CCTV? cctv;

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  File? _image;
  bool isActive = true;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameCtrl.text = widget.cctv!.name;
      locationCtrl.text = widget.cctv!.location;
      isActive = widget.cctv!.status;
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName = const Uuid().v4();
    final fileExt = image.path.split('.').last;
    final path = 'cctv/$fileName.$fileExt';

    final bytes = await image.readAsBytes();
    await supabase.storage.from('cctv').uploadBinary(path, bytes);
    final imageUrl = supabase.storage.from('cctv').getPublicUrl(path);
    return imageUrl;
  }

  Future<void> _saveCCTV() async {
    if (nameCtrl.text.isEmpty || locationCtrl.text.isEmpty) return;
    setState(() => isLoading = true);

    String imageUrl = widget.cctv?.imageUrl ?? '';
    if (_image != null) {
      imageUrl = await _uploadImage(_image!);
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

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Gedung'),
            ),
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('CCTV Aktif'),
              value: isActive,
              onChanged: (value) => setState(() => isActive = value ?? true),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 16),
            if (_image != null) Image.file(_image!, height: 150),
            const Spacer(),
            ElevatedButton(
              onPressed: isLoading ? null : _saveCCTV,
              child: Text(isLoading ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
