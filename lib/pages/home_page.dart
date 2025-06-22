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

  @override
  void initState() {
    super.initState();
    fetchCCTVs();
  }

  Future<void> fetchCCTVs() async {
    final response = await supabase
        .from('data_cctv')
        .select()
        .order('created_at');
    final List<CCTV> cctvList =
        response.map((e) => CCTV.fromMap(e)).toList().cast<CCTV>();

    setState(() {
      dataCCTV = cctvList;
      _applySearch();
    });
  }

  void _applySearch() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredCCTV = dataCCTV;
      } else {
        filteredCCTV =
            dataCCTV.where((cctv) {
              final nameMatch = cctv.name.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              final locationMatch = cctv.location.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              return nameMatch || locationMatch;
            }).toList();
      }
    });
  }

  Future<void> deleteCCTV(String id) async {
    await supabase.from('data_cctv').delete().eq('id', id);
    fetchCCTVs();
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
                _applySearch();
              },
              decoration: const InputDecoration(
                labelText: 'Cari Nama / Lokasi',
                prefixIcon: Icon(Icons.search),
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
                    subtitle: Text(cctv.location),
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
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            if (cctv.id != null) {
                              deleteCCTV(cctv.id!);
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
