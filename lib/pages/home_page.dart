import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cctv_management/models/cctv.dart';
import 'package:cctv_management/pages/form_page.dart';
import 'package:cctv_management/pages/detail_page.dart';
import 'package:cctv_management/utils/insert_log.dart';
import 'package:cctv_management/widgets/drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<CCTV> dataCCTV = [];
  String searchQuery = '';
  String sortOrder = 'created_at_desc';
  String userRole = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    fetchCCTVs();
  }

  Future<void> fetchUserRole() async {
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    userRole = metadata?['role'] ?? '';
    setState(() {});
  }

  Future<void> fetchCCTVs() async {
    setState(() {
      isLoading = true;
    });

    try {
      dynamic query = supabase.from('data_cctv').select();

      if (sortOrder == 'az') {
        query = query.order('name', ascending: true);
      } else if (sortOrder == 'za') {
        query = query.order('name', ascending: false);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query;

      if (response is List) {
        dataCCTV = response.map((e) => CCTV.fromMap(e)).toList();
      } else {
        dataCCTV = [];
      }
    } catch (e) {
      dataCCTV = [];
      print('Error fetching data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteCCTV(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Apakah anda yakin ingin menghapus CCTV ini?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Hapus'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('data_cctv').delete().eq('id', id);
      await insertLog(action: 'delete', message: 'Hapus CCTV id=$id');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Data CCTV berhasil dihapus'),
            ],
          ),
          backgroundColor: Colors.black87,
        ),
      );

      fetchCCTVs();
    } catch (e) {
      print('Error deleting data: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCCTV =
        dataCCTV.where((cctv) {
          final query = searchQuery.toLowerCase();
          return cctv.name.toLowerCase().contains(query) ||
              cctv.location.toLowerCase().contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data CCTV'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCCTVs),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                sortOrder = value;
              });
              fetchCCTVs();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'created_at_desc',
                    child: Text('Tanggal Terbaru'),
                  ),
                  const PopupMenuItem(value: 'az', child: Text('A-Z')),
                  const PopupMenuItem(value: 'za', child: Text('Z-A')),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Apakah anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          child: const Text('Batal'),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ],
                    ),
              );

              if (confirm == true) {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/');
                }
              }
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Cari nama gedung / lokasi',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        filteredCCTV.isEmpty
                            ? const Center(child: Text('Belum ada data CCTV'))
                            : ListView.builder(
                              itemCount: filteredCCTV.length,
                              itemBuilder: (context, index) {
                                final cctv = filteredCCTV[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: ListTile(
                                    leading:
                                        cctv.imageUrl.isNotEmpty
                                            ? Image.network(
                                              cctv.imageUrl,
                                              width: 60,
                                            )
                                            : const Icon(Icons.image, size: 40),
                                    title: Text(cctv.name),
                                    subtitle: Text(
                                      '${cctv.location} • ${cctv.status ? 'Aktif' : 'Non-aktif'}',
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DetailPage(cctv: cctv),
                                        ),
                                      );
                                    },
                                    trailing:
                                        userRole == 'admin'
                                            ? IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                              onPressed:
                                                  () => deleteCCTV(cctv.id),
                                            )
                                            : null,
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton:
          userRole != 'viewer'
              ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormPage()),
                  );
                  fetchCCTVs();
                },
              )
              : null,
    );
  }
}
