import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cctv.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;
  List<CCTV> dataCCTV = [];
  List<CCTV> filteredCCTV = [];
  String searchQuery = '';
  String? selectedStatus;
  String selectedSort = 'Terbaru';

  @override
  void initState() {
    super.initState();
    fetchCCTVs();
  }

  Future<void> fetchCCTVs() async {
    final response = await supabase
        .from('data_cctv')
        .select()
        .order('created_at', ascending: false);
    final List<CCTV> cctvList =
        response.map((e) => CCTV.fromMap(e)).toList().cast<CCTV>();

    setState(() {
      dataCCTV = cctvList;
      _applySearchFilterSort();
    });
  }

  void _applySearchFilterSort() {
    List<CCTV> tempList =
        dataCCTV.where((cctv) {
          final nameMatch = cctv.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
          final locationMatch = cctv.location.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

          bool statusMatch = true;
          if (selectedStatus == 'aktif') {
            statusMatch = cctv.status == true;
          } else if (selectedStatus == 'nonaktif') {
            statusMatch = cctv.status == false;
          }

          return (nameMatch || locationMatch) && statusMatch;
        }).toList();

    // Apply Sorting
    if (selectedSort == 'A-Z') {
      tempList.sort((a, b) => a.name.compareTo(b.name));
    } else if (selectedSort == 'Z-A') {
      tempList.sort((a, b) => b.name.compareTo(a.name));
    } else {
      tempList.sort(
        (a, b) => (b.id ?? '').compareTo(a.id ?? ''),
      ); // Default: created_at DESC
    }

    setState(() {
      filteredCCTV = tempList;
    });
  }

  Future<void> deleteCCTV(String id) async {
    await supabase.from('data_cctv').delete().eq('id', id);
    fetchCCTVs();
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah anda yakin ingin menghapus CCTV ini?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(context).pop(); // tutup dialog
                await deleteCCTV(id); // hapus data

                // Tampilkan Snackbar berhasil
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data CCTV berhasil dihapus!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data CCTV')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                _applySearchFilterSort();
              },
              decoration: const InputDecoration(
                labelText: 'Cari Nama / Lokasi',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              value: selectedStatus,
              items: const [
                DropdownMenuItem(child: Text('Semua'), value: null),
                DropdownMenuItem(child: Text('Aktif'), value: 'aktif'),
                DropdownMenuItem(child: Text('Nonaktif'), value: 'nonaktif'),
              ],
              onChanged: (value) {
                selectedStatus = value;
                _applySearchFilterSort();
              },
              decoration: const InputDecoration(
                labelText: 'Filter Status',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedSort,
              items: const [
                DropdownMenuItem(child: Text('Terbaru'), value: 'Terbaru'),
                DropdownMenuItem(child: Text('A-Z'), value: 'A-Z'),
                DropdownMenuItem(child: Text('Z-A'), value: 'Z-A'),
              ],
              onChanged: (value) {
                selectedSort = value!;
                _applySearchFilterSort();
              },
              decoration: const InputDecoration(
                labelText: 'Urutkan',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredCCTV.length,
              itemBuilder: (context, index) {
                final cctv = filteredCCTV[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(
                      cctv.imageUrl,
                      width: 60,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                    title: Text(cctv.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cctv.location),
                        Text(
                          cctv.status ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            color: cctv.status ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            if (cctv.id != null) {
                              _showDeleteConfirmation(context, cctv.id!);
                            }
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          fetchCCTVs();
        },
      ),
    );
  }
}
