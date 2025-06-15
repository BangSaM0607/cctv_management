import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://lleiuchgukmblykhhduz.supabase.co', // URL Supabase
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8', // Kunci anon untuk akses Supabase
  );
  runApp(MyApp()); // Menjalankan aplikasi Flutter
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Konstruktor untuk MyApp, tidak menerima parameter
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCTV MANAGEMENT', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ), // Tema aplikasi dengan warna biru
      home: const HomePage(), // Halaman utama aplikasi
    );
  }
}
