import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cctv.dart';
import 'form_page.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchCtrl = TextEditingController();

  List<CCTV> _allCctv = [];
  List<CCTV> _filteredCctv = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchCtrl.addListener(_filterSearchResults);
  }

  void _filterSearchResults() {
    final keyword = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredCctv =
          _allCctv.where((item) {
            return item.name.toLowerCase().contains(keyword) ||
                item.location.toLowerCase().contains(keyword);
          }).toList();
    });
  }

  Future<void> fetchData() async {
    final response = await supabase.from('cctvs').select();
    final data = (response as List).map((e) => CCTV.fromMap(e)).toList();

    setState(() {
      _allCctv = data;
      _filteredCctv = data;
    });
  }

  Future<void> deleteItem(String id) async {
    await supabase.from('cctvs').delete().eq('id', id);
    fetchData();
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Data'),
            content: const Text('Yakin ingin menghapus data ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await deleteItem(id);
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar CCTV'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: fetchData),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          fetchData();
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Cari nama gedung / lokasi',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child:
                _filteredCctv.isEmpty
                    ? const Center(child: Text('Data kosong'))
                    : ListView.builder(
                      itemCount: _filteredCctv.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCctv[index];
                        return Card(
                          child: ListTile(
                            leading:
                                item.imageUrl.isNotEmpty
                                    ? Image.network(
                                      item.imageUrl,
                                      width: 60,
                                      fit: BoxFit.cover,
                                    )
                                    : const Icon(Icons.image_not_supported),
                            title: Text(item.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.location),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        item.status ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.status ? 'Aktif' : 'Nonaktif',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FormPage(cctv: item),
                                      ),
                                    );
                                    fetchData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _confirmDelete(item.id),
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
    );
  }
}
