import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      // Tentukan role otomatis
      String userRole = 'operator';

      if (email.endsWith('@smartnet.com')) {
        userRole = 'admin';
      } else if (email.endsWith('@user.com')) {
        userRole = 'viewer';
      }

      // Register + metadata role
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'role': userRole},
      );

      if (response.user != null) {
        if (!mounted) return;
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          title: 'Berhasil!',
          desc: 'Register berhasil sebagai $userRole.\nSilakan login.',
          btnOkOnPress: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ).show();
      }
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerUser,
              child: const Text('Register'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text('Sudah punya akun? Login disini'),
            ),
          ],
        ),
      ),
    );
  }
}
