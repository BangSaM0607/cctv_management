import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cctv.dart';
import 'form_page.dart';
import '../utils/insert_log.dart';

class DetailPage extends StatefulWidget {
  final CCTV cctv;
  const DetailPage({super.key, required this.cctv});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final supabase = Supabase.instance.client;
  String userRole = '';

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    setState(() {
      userRole = metadata?['role'] ?? '';
    });
  }

  Future<void> deleteCCTV(BuildContext context, String id) async {
    if (userRole != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda tidak memiliki izin untuk menghapus data'),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah anda yakin ingin menghapus CCTV ini?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Hapus'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('data_cctv').delete().eq('id', id);
      await insertLog(action: 'delete', message: 'Hapus CCTV id=$id');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data CCTV berhasil dihapus'),
          backgroundColor: Colors.red,
        ),
      );

      Navigator.pop(context, true); // Kembali ke halaman sebelumnya
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cctv = widget.cctv;

    final canEdit = userRole == 'admin' || userRole == 'operator';
    final canDelete = userRole == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail CCTV'),
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FormPage(cctv: cctv)),
                );
                if (updated == true) {
                  Navigator.pop(context, true); // Refresh home_page.dart
                }
              },
            ),
          if (canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => deleteCCTV(context, cctv.id),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            cctv.imageUrl.isNotEmpty
                ? Image.network(cctv.imageUrl, height: 200, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 200, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              cctv.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${cctv.location}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Status: ', style: TextStyle(fontSize: 18)),
                Text(
                  cctv.status ? 'Aktif' : 'Non-aktif',
                  style: TextStyle(
                    fontSize: 18,
                    color: cctv.status ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${cctv.createdAt.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
