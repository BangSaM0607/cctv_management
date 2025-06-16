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
  List<CCTV> _allCctv = [];
  List<CCTV> _filteredCctv = [];
  bool _showOnlyActive = false;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchCCTV();
  }

  Future<void> _fetchCCTV() async {
    final response = await supabase.from('cctvs').select('*');
    final data = (response as List).map((e) => CCTV.fromMap(e)).toList();
    setState(() {
      _allCctv = data;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredCctv =
          _allCctv.where((cctv) {
            final matchesSearch =
                cctv.name.toLowerCase().contains(_searchText.toLowerCase()) ||
                cctv.location.toLowerCase().contains(_searchText.toLowerCase());
            final matchesStatus = !_showOnlyActive || cctv.status;
            return matchesSearch && matchesStatus;
          }).toList();
    });
  }

  void _deleteCCTV(String id) async {
    await supabase.from('cctvs').delete().eq('id', id);
    _fetchCCTV();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data CCTV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FormPage()),
              );
              _fetchCCTV();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Cari nama gedung atau lokasi',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchText = value;
                _applyFilters();
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Tampilkan hanya CCTV Aktif'),
            value: _showOnlyActive,
            onChanged: (value) {
              setState(() {
                _showOnlyActive = value;
              });
              _applyFilters();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCctv.length,
              itemBuilder: (context, index) {
                final item = _filteredCctv[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading:
                        item.imageUrl.isNotEmpty
                            ? Image.network(
                              item.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                            : const Icon(Icons.image_not_supported, size: 60),
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
                            color: item.status ? Colors.green : Colors.red,
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
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormPage(cctv: item),
                            ),
                          );
                          _fetchCCTV();
                        } else if (value == 'delete') {
                          _deleteCCTV(item.id);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
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
