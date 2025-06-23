import 'package:flutter/material.dart';
import 'package:cctv_management/pages/admin_user_page.dart'; // Import halaman manajemen user
import 'package:cctv_management/pages/log_page.dart'; // Import halaman log

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Header pada drawer
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                'CCTV Management',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          // Menu Home
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(
                context,
              ); // Menutup drawer dan kembali ke halaman utama
            },
          ),
          // Menu Manajemen User (hanya untuk admin)
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manajemen User'),
            onTap: () {
              // Navigasi ke halaman AdminUserPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminUserPage()),
              );
            },
          ),
          // Menu Riwayat Log
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Riwayat Log'),
            onTap: () {
              // Navigasi ke halaman LogPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LogPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
