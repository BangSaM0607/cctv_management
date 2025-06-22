import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
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
  bool status = true;
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.cctv != null) {
      nameController.text = widget.cctv!.name;
      locationController.text = widget.cctv!.location;
      status = widget.cctv!.status;
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String> uploadImage(String uuid) async {
    if (imageFile == null) return widget.cctv?.imageUrl ?? '';

    final bytes = await imageFile!.readAsBytes();
    final fileName = 'cctv_images/$uuid.jpg';

    await supabase.storage
        .from('cctv_images')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = supabase.storage
        .from('cctv_images')
        .getPublicUrl(fileName);
    return publicUrl;
  }

  Future<void> saveData() async {
    if (nameController.text.isEmpty || locationController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Peringatan',
        desc: 'Nama gedung dan lokasi tidak boleh kosong!',
      ).show();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String uuid = widget.cctv?.id ?? const Uuid().v4();
      String imageUrl = await uploadImage(uuid);

      if (widget.cctv == null) {
        // INSERT
        await supabase.from('data_cctv').insert({
          'id': uuid,
          'name': nameController.text,
          'location': locationController.text,
          'image_url': imageUrl,
          'status': status,
        });
        await insertLog(
          action: 'add',
          message: 'Tambah CCTV: ${nameController.text}',
          timestamp: DateTime.now().toIso8601String(),
        );
      } else {
        // UPDATE
        await supabase
            .from('data_cctv')
            .update({
              'name': nameController.text,
              'image_url': imageUrl,
              'status': status,
            })
            .eq('id', widget.cctv!.id);
        await insertLog(
          action: 'edit',
          message: 'Edit CCTV: ${nameController.text}',
          timestamp: DateTime.now().toIso8601String(),
        );
      }

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Sukses',
        desc: 'Data berhasil disimpan',
        btnOkOnPress: () {
          Navigator.pop(context);
        },
      ).show();
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
      ).show();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cctv == null ? 'Tambah CCTV' : 'Edit CCTV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Gedung',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Status: '),
                Checkbox(
                  value: status,
                  onChanged: (value) {
                    setState(() {
                      status = value ?? true;
                    });
                  },
                ),
                Text(status ? 'Aktif' : 'Non-Aktif'),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
              onPressed: pickImage,
            ),
            const SizedBox(height: 8),
            if (imageFile != null) Image.file(imageFile!, height: 150),
            if (widget.cctv?.imageUrl.isNotEmpty == true && imageFile == null)
              Image.network(widget.cctv!.imageUrl, height: 150),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : saveData,
              icon: const Icon(Icons.save),
              label: Text(isLoading ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
