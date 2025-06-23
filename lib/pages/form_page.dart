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
  final CCTV? cctv; // Data CCTV yang akan diedit (jika ada)

  const FormPage({super.key, this.cctv});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client
  final _formKey = GlobalKey<FormState>(); // Key untuk form validasi

  File? _pickedImage; // Untuk gambar yang dipilih di mobile
  Uint8List? _webImage; // Untuk gambar yang dipilih di web
  String? _imageUrl; // URL gambar yang sudah diupload

  final _nameController = TextEditingController(); // Controller nama CCTV
  final _locationController = TextEditingController(); // Controller lokasi CCTV
  bool _status = true; // Status aktif/non-aktif
  bool _isSaving = false; // Status loading saat simpan

  @override
  void initState() {
    super.initState();
    // Jika edit, isi field dengan data lama
    if (widget.cctv != null) {
      _nameController.text = widget.cctv!.name;
      _locationController.text = widget.cctv!.location;
      _imageUrl = widget.cctv!.imageUrl;
      _status = widget.cctv!.status;
    }
  }

  // Fungsi untuk memilih gambar dari galeri
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

  // Fungsi untuk upload gambar ke Supabase Storage
  Future<String?> _uploadImage() async {
    try {
      final fileName = const Uuid().v4() + '.jpg'; // Nama file unik
      final storageRef = supabase.storage.from('cctv-images');

      if (kIsWeb && _webImage != null) {
        await storageRef.uploadBinary(fileName, _webImage!); // Upload di web
      } else if (_pickedImage != null) {
        await storageRef.upload(fileName, _pickedImage!); // Upload di mobile
      } else {
        return _imageUrl; // Jika tidak ada gambar baru, pakai gambar lama
      }

      // Dapatkan signed URL untuk gambar yang diupload
      final signedUrlResp = await storageRef.createSignedUrl(
        fileName,
        3600 * 24 * 7, // Berlaku 7 hari
      );
      return signedUrlResp;
    } catch (e) {
      // Tampilkan pesan error jika gagal upload
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
      return null;
    }
  }

  // Fungsi untuk menyimpan data (insert/update)
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return; // Validasi form

    setState(() {
      _isSaving = true; // Tampilkan loading
    });

    String? imageUrl = await _uploadImage(); // Upload gambar jika ada

    if (widget.cctv == null) {
      // INSERT data baru
      final id = const Uuid().v4();
      await supabase.from('data_cctv').insert({
        'id': id,
        'name': _nameController.text,
        'location': _locationController.text,
        'image_url': imageUrl ?? '',
        'status': _status,
        'created_at': DateTime.now().toIso8601String(),
      });
      await insertLog(
        action: 'insert',
        message: 'Tambah CCTV id=$id',
      ); // Catat log insert
    } else {
      // UPDATE data lama
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
        message: 'Update CCTV id=${widget.cctv!.id}', // Catat log update
      );
    }

    setState(() {
      _isSaving = false; // Sembunyikan loading
    });

    if (mounted) Navigator.pop(context, true); // Kembali ke halaman sebelumnya
  }

  // Widget untuk preview gambar yang dipilih/diupload
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

    // Jika belum ada gambar, tampilkan icon kamera
    return Container(
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.camera_alt, size: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cctv != null; // Cek mode edit/tambah

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit CCTV' : 'Tambah CCTV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _buildImagePreview(),
              ), // Pilih gambar
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
                onPressed: _isSaving ? null : _saveData, // Simpan data
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(isEdit ? 'Update' : 'Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
