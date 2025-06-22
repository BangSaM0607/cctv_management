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
  bool status = true;
  File? _image;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameCtrl.text = widget.cctv!.name;
      locationCtrl.text = widget.cctv!.location;
      status = widget.cctv!.status;
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
    final fileName = const Uuid().v4(); // nama file unik
    final fileExt = image.path.split('.').last;
    final path = 'cctv/$fileName.$fileExt';

    final bytes = await image.readAsBytes();
    await supabase.storage.from('cctv').uploadBinary(path, bytes);
    final imageUrl = supabase.storage.from('cctv').getPublicUrl(path);
    print('✅ Image uploaded: $imageUrl');
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
      'status': status,
    };

    if (widget.cctv == null) {
      await supabase.from('data_cctv').insert(data);
      print('✅ Data baru ditambahkan');
    } else {
      await supabase.from('data_cctv').update(data).eq('id', widget.cctv!.id!);
      print('✅ Data ${widget.cctv!.id} berhasil diupdate');
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
            Row(
              children: [
                Checkbox(
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
                const Text('Aktif'),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pilih Gambar'),
            ),
            const SizedBox(height: 16),
            if (_image != null)
              Image.file(_image!, height: 150)
            else if (widget.cctv?.imageUrl != null &&
                widget.cctv!.imageUrl.isNotEmpty)
              Image.network(widget.cctv!.imageUrl, height: 150),
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
