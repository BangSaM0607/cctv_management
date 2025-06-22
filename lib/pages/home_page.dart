import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cctv.dart';
import '../pages/detail_page.dart';
import '../pages/form_page.dart';
import '../utils/insert_log.dart';
import '../widgets/drawer_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<CCTV> dataCCTV = [];
  String searchQuery = '';
  String sortOption = 'name_asc';
  bool isAdmin = false;
  bool isOperator = false;
  bool isViewer = false;

  @override
  void initState() {
    super.initState();
    fetchCCTVs();
    checkRole();
  }

  Future<void> checkRole() async {
    final role = supabase.auth.currentUser?.userMetadata?['role'];
    setState(() {
      isAdmin = role == 'admin';
      isOperator = role == 'operator';
      isViewer = role == 'viewer';
    });
  }

  Future<void> fetchCCTVs() async {
    var query = supabase
        .from('data_cctv')
        .select()
        .order(
          sortOption == 'name_asc'
              ? 'name'
              : sortOption == 'name_desc'
              ? 'name'
              : 'created_at',
          ascending: sortOption == 'name_desc' ? false : true,
        );

    final response = await query;
    final list =
        (response as List)
            .map((e) => CCTV.fromMap(e))
            .where(
              (cctv) =>
                  cctv.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  cctv.location.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
            )
            .toList();

    setState(() {
      dataCCTV = list;
    });
  }

  Future<void> deleteCCTV(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: Text('Apakah Anda yakin ingin menghapus "$name"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await supabase.from('data_cctv').delete().eq('id', id);
      await insertLog('delete', 'Hapus CCTV: $name', '');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text('Data berhasil dihapus'),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );

      fetchCCTVs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data CCTV'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchCCTVs),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
              });
              fetchCCTVs();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'name_asc', child: Text('A-Z')),
                  const PopupMenuItem(value: 'name_desc', child: Text('Z-A')),
                  const PopupMenuItem(
                    value: 'created_at_desc',
                    child: Text('Terbaru'),
                  ),
                ],
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '🔍 Cari Nama Gedung / Lokasi...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
                fetchCCTVs();
              },
            ),
          ),
          Expanded(
            child:
                dataCCTV.isEmpty
                    ? const Center(child: Text('Tidak ada data CCTV'))
                    : ListView.builder(
                      itemCount: dataCCTV.length,
                      itemBuilder: (context, index) {
                        final cctv = dataCCTV[index];
                        return Card(
                          child: ListTile(
                            leading:
                                cctv.imageUrl.isNotEmpty
                                    ? Image.network(
                                      cctv.imageUrl,
                                      width: 60,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.image),
                                    )
                                    : const Icon(Icons.image),
                            title: Text(cctv.name),
                            subtitle: Text(
                              '${cctv.location}\nStatus: ${cctv.status ? "Aktif" : "Non-Aktif"}',
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailPage(cctv: cctv),
                                ),
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAdmin || isOperator)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FormPage(cctv: cctv),
                                        ),
                                      );
                                      fetchCCTVs();
                                    },
                                  ),
                                if (isAdmin)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      deleteCCTV(cctv.id, cctv.name);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton:
          (isAdmin || isOperator)
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
