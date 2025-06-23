import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client
  List<dynamic> userList = []; // List untuk menyimpan data user

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Ambil data user saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil data user dari tabel 'users' di Supabase
  Future<void> fetchUsers() async {
    final response = await supabase.from('users').select();

    setState(() {
      userList = response; // Simpan hasil query ke userList
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')), // Judul halaman
      body: ListView.builder(
        itemCount: userList.length, // Jumlah user yang akan ditampilkan
        itemBuilder: (context, index) {
          final user = userList[index];
          return ListTile(
            leading: const Icon(Icons.person), // Icon user
            title: Text(user['email'] ?? ''), // Tampilkan email user
            subtitle: Text(
              'Role: ${user['role'] ?? 'N/A'}',
            ), // Tampilkan role user
          );
        },
      ),
    );
  }
}
