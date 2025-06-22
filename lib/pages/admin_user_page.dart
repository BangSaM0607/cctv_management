import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/drawer_menu.dart';

class AdminUserPage extends StatefulWidget {
  const AdminUserPage({super.key});

  @override
  State<AdminUserPage> createState() => _AdminUserPageState();
}

class _AdminUserPageState extends State<AdminUserPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      final List<dynamic> response =
          await supabase.rpc('get_all_users').select();
      setState(() {
        users = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
      ).show();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateRole(String userId, String newRole) async {
    try {
      await supabase.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(userMetadata: {'role': newRole}),
      );

      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Sukses',
        desc: 'Role user berhasil diupdate ke: $newRole',
      ).show();

      fetchUsers();
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
      appBar: AppBar(
        title: const Text('Kelola User & Role'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchUsers),
        ],
      ),
      drawer: const DrawerMenu(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text('Tidak ada user'))
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final email = user['email'] ?? '';
                  final role = user['user_metadata']?['role'] ?? 'unknown';
                  final userId = user['id'];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(email),
                      subtitle: Text('Role: $role'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          updateRole(userId, value);
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'admin',
                                child: Text('Admin'),
                              ),
                              const PopupMenuItem(
                                value: 'operator',
                                child: Text('Operator'),
                              ),
                              const PopupMenuItem(
                                value: 'viewer',
                                child: Text('Viewer'),
                              ),
                            ],
                        child: const Icon(Icons.edit),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
