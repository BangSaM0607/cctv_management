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
  final supabase = Supabase.instance.client; // Inisialisasi Supabase client
  List<CCTV> dataCCTV = []; // List data CCTV
  String searchQuery = ''; // Query pencarian
  String sortOrder = 'created_at_desc'; // Urutan sorting default
  String userRole = ''; // Role user login
  bool isLoading = false; // Status loading

  @override
  void initState() {
    super.initState();
    fetchUserRole(); // Ambil role user saat init
    fetchCCTVs(); // Ambil data CCTV saat init
  }

  // Ambil role user dari metadata Supabase
  Future<void> fetchUserRole() async {
    final user = supabase.auth.currentUser;
    final metadata = user?.userMetadata;
    userRole = metadata?['role'] ?? '';
    setState(() {});
  }

  // Ambil data CCTV dari Supabase
  Future<void> fetchCCTVs() async {
    setState(() {
      isLoading = true; // Tampilkan loading
    });

    try {
      dynamic query = supabase.from('data_cctv').select();

      // Sorting data sesuai pilihan user
      if (sortOrder == 'az') {
        query = query.order('name', ascending: true);
      } else if (sortOrder == 'za') {
        query = query.order('name', ascending: false);
      } else {
        query = query.order('created_at', ascending: false);
      }

      final response = await query;

      if (response is List) {
        dataCCTV =
            response
                .map((e) => CCTV.fromMap(e))
                .toList(); // Mapping data ke model CCTV
      } else {
        dataCCTV = [];
      }
    } catch (e) {
      dataCCTV = [];
      print('Error fetching data: $e'); // Tampilkan error jika gagal fetch
    } finally {
      setState(() {
        isLoading = false; // Sembunyikan loading
      });
    }
  }

  // Fungsi hapus data CCTV
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
                onPressed: () => Navigator.pop(context, false), // Batal hapus
              ),
              TextButton(
                child: const Text('Hapus'),
                onPressed:
                    () => Navigator.pop(context, true), // Konfirmasi hapus
              ),
            ],
          ),
    );

    if (confirm != true) return; // Jika batal, keluar fungsi

    try {
      await supabase
          .from('data_cctv')
          .delete()
          .eq('id', id); // Hapus data di Supabase
      await insertLog(
        action: 'delete',
        message: 'Hapus CCTV id=$id',
      ); // Catat log penghapusan

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

      fetchCCTVs(); // Refresh data setelah hapus
    } catch (e) {
      print('Error deleting data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus data: $e')),
      ); // Tampilkan error jika gagal hapus
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter data CCTV sesuai pencarian
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCCTVs,
          ), // Tombol refresh data
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                sortOrder = value; // Ubah urutan sorting
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
              // Konfirmasi logout
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
                await supabase.auth.signOut(); // Proses logout
                if (mounted) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/',
                  ); // Kembali ke halaman utama
                }
              }
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(), // Drawer menu samping
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Loading saat fetch data
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
                          searchQuery = value; // Update query pencarian
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child:
                        filteredCCTV.isEmpty
                            ? const Center(
                              child: Text('Belum ada data CCTV'),
                            ) // Jika data kosong
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
                                            : const Icon(
                                              Icons.image,
                                              size: 40,
                                            ), // Tampilkan gambar atau icon
                                    title: Text(cctv.name),
                                    subtitle: Text(
                                      '${cctv.location} • ${cctv.status ? 'Aktif' : 'Non-aktif'}',
                                    ),
                                    onTap: () {
                                      // Navigasi ke halaman detail CCTV
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
                                                  () => deleteCCTV(
                                                    cctv.id,
                                                  ), // Hapus data
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
                  // Navigasi ke halaman tambah data CCTV
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FormPage()),
                  );
                  fetchCCTVs(); // Refresh data setelah tambah
                },
              )
              : null,
    );
  }
}
