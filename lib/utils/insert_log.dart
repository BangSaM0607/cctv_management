import 'package:supabase_flutter/supabase_flutter.dart';

// Fungsi untuk memasukkan log ke tabel 'logs' di Supabase
Future<void> insertLog({
  required String action, // Jenis aksi (misal: insert, update, delete)
  required String message, // Pesan log yang ingin dicatat
}) async {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client
  final user = supabase.auth.currentUser; // Ambil user yang sedang login
  final email = user?.email ?? ''; // Ambil email user, jika ada

  // Insert data log ke tabel 'logs'
  await supabase.from('logs').insert({
    'action': action, // Kolom aksi
    'message': message, // Kolom pesan
    'user_email': email, // Kolom email user
  });
}
