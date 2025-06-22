import 'package:flutter/material.dart';
import '../models/cctv.dart';

class DetailPage extends StatelessWidget {
  final CCTV cctv;

  const DetailPage({super.key, required this.cctv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail CCTV')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  cctv.imageUrl,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 100),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Nama Gedung:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cctv.name, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Lokasi:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(cctv.location, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              cctv.status ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 18,
                color: cctv.status ? Colors.green : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 12),
            Text('ID:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              cctv.id ?? '-',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
