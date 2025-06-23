import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cctv_management/models/cctv.dart';
import 'package:cctv_management/utils/insert_log.dart';

class FormPage extends StatefulWidget {
  final CCTV? cctv; // << Tambahkan parameter

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  File? _pickedImage;
  Uint8List? _webImage;
  String? _imageUrl;

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  bool _status = true;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      _nameController.text = widget.cctv!.name;
      _locationController.text = widget.cctv!.location;
      _imageUrl = widget.cctv!.imageUrl;
      _status = widget.cctv!.status;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    try {
      final fileName = const Uuid().v4() + '.jpg';
      final storageRef = supabase.storage.from('cctv-images');

      if (kIsWeb && _webImage != null) {
        await storageRef.uploadBinary(fileName, _webImage!);
      } else if (_pickedImage != null) {
        await storageRef.upload(fileName, _pickedImage!);
      } else {
        return _imageUrl; // Tidak upload ulang → pakai gambar lama
      }

      final signedUrlResp = await storageRef.createSignedUrl(
        fileName,
        3600 * 24 * 7,
      );
      return signedUrlResp;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
      return null;
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    String? imageUrl = await _uploadImage();

    if (widget.cctv == null) {
      // INSERT (tambah data)
      final id = const Uuid().v4();
      await supabase.from('data_cctv').insert({
        'id': id,
        'name': _nameController.text,
        'location': _locationController.text,
        'image_url': imageUrl ?? '',
        'status': _status,
        'created_at': DateTime.now().toIso8601String(),
      });
      await insertLog(action: 'insert', message: 'Tambah CCTV id=$id');
    } else {
      // UPDATE (edit data)
      await supabase
          .from('data_cctv')
          .update({
            'name': _nameController.text,
            'location': _locationController.text,
            'image_url': imageUrl ?? '',
            'status': _status,
          })
          .eq('id', widget.cctv!.id);
      await insertLog(
        action: 'update',
        message: 'Update CCTV id=${widget.cctv!.id}',
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildImagePreview() {
    if (kIsWeb) {
      if (_webImage != null) {
        return Image.memory(_webImage!, height: 200, fit: BoxFit.cover);
      }
    } else {
      if (_pickedImage != null) {
        return Image.file(_pickedImage!, height: 200, fit: BoxFit.cover);
      }
    }

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(_imageUrl!, height: 200, fit: BoxFit.cover);
    }

    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.camera_alt, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cctv != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit CCTV' : 'Tambah CCTV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(onTap: _pickImage, child: _buildImagePreview()),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama CCTV'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Nama wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Lokasi wajib diisi'
                            : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Status Aktif'),
                value: _status,
                onChanged: (val) {
                  setState(() {
                    _status = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveData,
                child: Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
