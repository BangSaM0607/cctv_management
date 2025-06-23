import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cctv_management/pages/login_page.dart';
import 'package:cctv_management/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:
        'https://lleiuchgukmblykhhduz.supabase.co', // Ganti dengan URL Supabase kamu
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8', // Ganti dengan ANON KEY Supabase kamu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCTV Management',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client

  @override
  Widget build(BuildContext context) {
    // Membuat MaterialApp baru (sebenarnya tidak perlu, karena sudah ada di MyApp)
    return MaterialApp(
      title: 'CCTV Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // Mengecek apakah user sudah login atau belum
      home:
          Supabase.instance.client.auth.currentUser == null
              ? const LoginPage() // Jika belum login, tampilkan LoginPage
              : const HomePage(), // Jika sudah login, tampilkan HomePage
    );
  }
}
