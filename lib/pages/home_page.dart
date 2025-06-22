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
  List<CCTV> cctvs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    testConnection();
    fetchCCTVs();
  }

  Future<void> testConnection() async {
    try {
      print('👉 [TEST] Coba select 1 row dari Supabase...');
      final test = await supabase.from('data_cctv').select('*').limit(1);
      print('✅ [TEST] Success! Response: $test');
    } catch (e) {
      print('❌ [TEST] Error connecting to Supabase: $e');
    }
  }

  Future<void> fetchCCTVs() async {
    try {
      print('👉 Mulai fetch data CCTV dari Supabase...');
      setState(() => isLoading = true);

      final response = await supabase.from('data_cctv').select('*');
      print('✅ Response CCTV: $response');

      final data = (response as List).map((e) => CCTV.fromMap(e)).toList();

      setState(() {
        cctvs = data;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetchCCTVs: $e');
      setState(() {
        cctvs = [];
        isLoading = false;
      });
    }
  }

  Future<void> deleteCCTV(String id) async {
    try {
      await supabase.from('data_cctv').delete().eq('id', id);
      print('✅ Data dengan id $id berhasil dihapus');
      fetchCCTVs();
    } catch (e) {
      print('❌ Error delete CCTV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data CCTV')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : cctvs.isEmpty
              ? const Center(child: Text('Tidak ada data CCTV'))
              : ListView.builder(
                itemCount: cctvs.length,
                itemBuilder: (context, index) {
                  final cctv = cctvs[index];
                  return Card(
                    child: ListTile(
                      leading:
                          cctv.imageUrl.isNotEmpty
                              ? Image.network(
                                cctv.imageUrl,
                                width: 60,
                                errorBuilder:
                                    (_, __, ___) => const Icon(Icons.image),
                              )
                              : const Icon(Icons.image, size: 60),
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
                            onPressed: () => deleteCCTV(cctv.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
