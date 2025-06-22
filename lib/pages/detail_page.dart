import 'package:flutter/material.dart';
import '../models/cctv.dart';
import '../widgets/drawer_menu.dart';

class DetailPage extends StatelessWidget {
  final CCTV cctv;

  const DetailPage({super.key, required this.cctv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail CCTV')),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child:
                  cctv.imageUrl.isNotEmpty
                      ? Image.network(
                        cctv.imageUrl,
                        height: 200,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.image_not_supported,
                              size: 100,
                            ),
                      )
                      : const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Nama Gedung'),
              subtitle: Text(cctv.name),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Lokasi'),
              subtitle: Text(cctv.location),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: const Text('Status'),
              subtitle: Text(cctv.status ? 'Aktif' : 'Non-Aktif'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('ID'),
              subtitle: Text(cctv.id),
            ),
          ],
        ),
      ),
    );
  }
}
