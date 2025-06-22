import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  bool status = true;
  File? pickedImageFile;
  String? imageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.cctv?.name ?? '');
    _locationController = TextEditingController(
      text: widget.cctv?.location ?? '',
    );
    status = widget.cctv?.status ?? true;
    imageUrl = widget.cctv?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadImage(File imageFile, String id) async {
    final ext = imageFile.path.split('.').last;
    final filePath = 'cctv_images/$id.$ext';

    try {
      await supabase.storage.from('cctv-images').upload(filePath, imageFile);

      final publicUrl = supabase.storage
          .from('cctv-images')
          .getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Upload image error: $e');
      return null;
    }
  }

  Future<void> saveCCTV() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final id = widget.cctv?.id ?? const Uuid().v4();

      String? uploadedImageUrl = imageUrl;

      if (pickedImageFile != null) {
        final url = await uploadImage(pickedImageFile!, id);
        if (url != null) {
          uploadedImageUrl = url;
        }
      }

      final data = {
        'id': id,
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'image_url': uploadedImageUrl ?? '',
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (widget.cctv == null) {
        // Insert new
        await supabase.from('data_cctv').insert(data);
        await insertLog(action: 'create', message: 'Tambah CCTV id=$id');
      } else {
        // Update existing
        await supabase.from('data_cctv').update(data).eq('id', id);
        await insertLog(action: 'update', message: 'Update CCTV id=$id');
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Save CCTV error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildImagePreview() {
    if (pickedImageFile != null) {
      return Image.file(
        pickedImageFile!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else {
      return const Icon(Icons.image, size: 120, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.cctv != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit CCTV' : 'Tambah CCTV')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildImagePreview(),
              TextButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pilih Gambar'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Gedung / CCTV',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Lokasi wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                value: status,
                onChanged: (val) {
                  setState(() {
                    status = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: saveCCTV,
                    child: Text(isEditing ? 'Update' : 'Simpan'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
