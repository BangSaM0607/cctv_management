import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cctv.dart';

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

  Future<void> saveData() async {
    final map = {
      'name': nameCtrl.text,
      'location': locationCtrl.text,
      'image_url': imageUrlCtrl.text,
    };

    if (widget.cctv == null) {
      await supabase.from('cctvs').insert(map);
    } else {
      await supabase.from('cctvs').update(map).eq('id', widget.cctv!.id);
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
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Gedung'),
              ),
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Lokasi'),
              ),
              TextFormField(
                controller: imageUrlCtrl,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: saveData, child: const Text('Simpan')),
            ],
          ),
        ),
      ),
    );
  }
}
