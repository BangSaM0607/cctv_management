// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client
  List<dynamic> logList = []; // List untuk menyimpan data log

  @override
  void initState() {
    super.initState();
    fetchLogs(); // Ambil data log saat halaman pertama kali dibuka
  }

  // Fungsi untuk mengambil data log dari tabel 'logs' di Supabase
  Future<void> fetchLogs() async {
    final response = await supabase
        .from('logs')
        .select()
        .order('created_at', ascending: false) // Urutkan dari terbaru
        .limit(50); // Batasi 50 data terakhir

    setState(() {
      logList = response; // Simpan hasil query ke logList
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Log')), // Judul halaman
      body:
          logList.isEmpty
              // Jika logList masih kosong, tampilkan loading
              ? const Center(child: CircularProgressIndicator())
              // Jika sudah ada data, tampilkan ListView
              : ListView.builder(
                itemCount: logList.length,
                itemBuilder: (context, index) {
                  final log = logList[index];
                  return ListTile(
                    leading: const Icon(Icons.history), // Icon log
                    title: Text(
                      '${log['action']} - ${log['message']}',
                    ), // Aksi dan pesan log
                    subtitle: Text(
                      'User: ${log['user_email'] ?? '-'}\n${log['created_at'] ?? ''}', // Email user & waktu
                    ),
                    isThreeLine: true, // Subtitle jadi 2 baris
                  );
                },
              ),
    );
  }
}
