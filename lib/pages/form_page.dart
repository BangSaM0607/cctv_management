import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/cctv.dart';
import '../utils/insert_log.dart';

class FormPage extends StatefulWidget {
  final CCTV? cctv;

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  bool status = false;
  File? imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameController.text = widget.cctv!.name;
      locationController.text = widget.cctv!.location;
      status = widget.cctv!.status;
      imageUrl = widget.cctv!.imageUrl;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File file) async {
    final fileName = const Uuid().v4();
    await supabase.storage
        .from('cctv_images')
        .upload('public/$fileName.jpg', file);

    final publicUrl = supabase.storage
        .from('cctv_images')
        .getPublicUrl('public/$fileName.jpg');

    return publicUrl;
  }

  Future<void> saveData() async {
    final userId = supabase.auth.currentUser!.id;

    String finalImageUrl = imageUrl ?? '';
    if (imageFile != null) {
      finalImageUrl = await uploadImage(imageFile!);
    }

    if (widget.cctv == null) {
      final newId = const Uuid().v4();

      await supabase.from('data_cctv').insert({
        'id': newId,
        'name': nameController.text,
        'location': locationController.text,
        'image_url': finalImageUrl,
        'status': status,
        'user_id': userId,
      });

      await insertLog('insert', newId, 'Tambah CCTV: ${nameController.text}');
    } else {
      await supabase
          .from('data_cctv')
          .update({
            'name': nameController.text,
            'location': locationController.text,
            'image_url': finalImageUrl,
            'status': status,
          })
          .eq('id', widget.cctv!.id);

      await insertLog(
        'update',
        widget.cctv!.id,
        'Update CCTV: ${nameController.text}',
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama CCTV'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Lokasi'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Status Aktif'),
              value: status,
              onChanged: (value) {
                setState(() {
                  status = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
              onPressed: pickImage,
            ),
            if (imageFile != null)
              Image.file(imageFile!, height: 150)
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              Image.network(imageUrl!, height: 150)
            else
              const SizedBox(
                height: 150,
                child: Center(child: Text('Belum ada gambar')),
              ),
            const SizedBox(height: 20),
            ElevatedButton(child: const Text('Simpan'), onPressed: saveData),
          ],
        ),
      ),
    );
  }
}
