import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cctv_management/pages/register_page.dart';
import 'package:cctv_management/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client

  final TextEditingController emailController =
      TextEditingController(); // Controller untuk input email
  final TextEditingController passwordController =
      TextEditingController(); // Controller untuk input password

  // Fungsi untuk proses login user
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      // Proses login ke Supabase
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Jika login berhasil, tampilkan dialog sukses
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Login berhasil!',
          desc: 'Selamat datang, ${response.user!.email}',
          btnOkOnPress: () {
            // Navigasi ke halaman HomePage setelah login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ).show();
      } else {
        // Jika login gagal, tampilkan dialog error
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Login gagal!',
          desc: 'Email atau password salah!',
          btnOkOnPress: () {},
        ).show();
      }
    } on AuthException catch (e) {
      // Penanganan error autentikasi
      String message = 'Terjadi kesalahan!';
      if (e.message.contains('Invalid login credentials')) {
        message = 'Email atau password salah!';
      } else if (e.message.contains('User not found')) {
        message = 'Email tidak terdaftar!';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: message,
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      // Penanganan error lain
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.videocam, size: 80), // Icon aplikasi
                const SizedBox(height: 24),
                const Text(
                  'Login CCTV Management',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true, // Sembunyikan input password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: login, // Panggil fungsi login saat ditekan
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Navigasi ke halaman register jika belum punya akun
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
