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

  @override
  void initState() {
    super.initState();
    fetchCCTVs();
  }

  Future<void> fetchCCTVs() async {
    final response = await supabase.from('cctvs').select().order('created_at');
    setState(() {
      cctvs = response.map((e) => CCTV.fromMap(e)).toList().cast<CCTV>();
    });
  }

  Future<void> deleteCCTV(String id) async {
    await supabase.from('cctvs').delete().eq('id', id);
    fetchCCTVs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data CCTV')),
      body: ListView.builder(
        itemCount: cctvs.length,
        itemBuilder: (context, index) {
          final cctv = cctvs[index];
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
                        MaterialPageRoute(builder: (_) => FormPage(cctv: cctv)),
                      );
                      fetchCCTVs();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteCCTV(cctv.id),
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
