import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://lleiuchgukmblykhhduz.supabase.co', // ganti dengan URL project kamu
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxsZWl1Y2hndWttYmx5a2hoZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MjU1MzYsImV4cCI6MjA2MzIwMTUzNn0.TolJDNpew7JVGe2tP9ngx3BHR97LNNvyZNTALE-cDT8', // ganti dengan anon key project kamu
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CCTV Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: session == null ? const LoginPage() : const HomePage(),
    );
  }
}
