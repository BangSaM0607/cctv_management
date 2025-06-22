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
          children: [
            Image.network(
              cctv.imageUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 100),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(
                cctv.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(cctv.location),
            ),
            ListTile(
              leading: Icon(
                cctv.status ? Icons.check_circle : Icons.cancel,
                color: cctv.status ? Colors.green : Colors.red,
              ),
              title: Text(
                cctv.status ? 'Aktif' : 'Nonaktif',
                style: TextStyle(
                  color: cctv.status ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
