import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cctv_management/pages/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client

  final TextEditingController emailController =
      TextEditingController(); // Controller untuk input email
  final TextEditingController passwordController =
      TextEditingController(); // Controller untuk input password
  String selectedRole = 'viewer'; // Default role user baru

  // Fungsi untuk proses registrasi user baru
  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      // Proses sign up ke Supabase
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': selectedRole, // Simpan role ke metadata
        },
      );

      // Jika berhasil, tampilkan dialog sukses
      if (response.user != null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Berhasil daftar!',
          desc: 'Silakan login dengan email: $email',
          btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ).show();
      }
    } on AuthException catch (e) {
      // Jika error autentikasi, tampilkan dialog error
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.message,
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      // Jika error lain, tampilkan dialog error
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
      appBar: AppBar(title: const Text('Register Akun')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.person_add, size: 80), // Icon register
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
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              // Dropdown untuk memilih role user
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Pilih Role',
                  prefixIcon: Icon(Icons.admin_panel_settings),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'operator', child: Text('Operator')),
                  DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Tombol daftar
              ElevatedButton(
                onPressed: register, // Panggil fungsi register saat ditekan
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
