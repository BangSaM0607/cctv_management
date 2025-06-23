import 'package:flutter/material.dart';
import 'package:cctv_management/models/cctv.dart';
import 'package:cctv_management/pages/form_page.dart';
import 'package:cctv_management/utils/insert_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> deleteCCTV(String id) async {
    await supabase.from('data_cctv').delete().eq('id', id);
    await insertLog(action: 'delete', message: 'Hapus CCTV id=$id');
    if (mounted) {
      Navigator.pop(context, true); // balik ke HomePage
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Data CCTV berhasil dihapus'),
          ],
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cctv = widget.cctv;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail CCTV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cctv.imageUrl.isNotEmpty
                ? Image.network(cctv.imageUrl, height: 200, fit: BoxFit.cover)
                : Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
            const SizedBox(height: 16),
            Text(
              cctv.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Lokasi: ${cctv.location}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${cctv.status ? 'Aktif' : 'Non-aktif'}',
              style: TextStyle(
                fontSize: 16,
                color: cctv.status ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat: ${cctv.createdAt.toLocal()}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (userRole == 'admin' || userRole == 'operator')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => FormPage(cctv: cctv)),
                      );
                      Navigator.pop(context, true); // balik HomePage refresh
                    },
                  ),
                if (userRole == 'admin')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                'Apakah anda yakin ingin menghapus CCTV ini?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Batal'),
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text('Hapus'),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        deleteCCTV(cctv.id);
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
