import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/cctv.dart';
import 'form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  }); // Konstruktor untuk halaman utama, tidak menerima parameter
  @override
  State<HomePage> createState() => _HomePageState(); // Mengembalikan state dari halaman utama
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client; // Mengambil instance Supabase
  List<CCTV> cctvs = []; // List untuk menyimpan data CCTV

  @override
  void initState() {
    super.initState();
    fetchCCTVs(); // Ambil data saat halaman dibuka
  }

  Future<void> fetchCCTVs() async {
    final response = await supabase.from('cctvs').select().order('created_at');
    setState(() {
      // Mengubah data dari Map ke List CCTV
      cctvs = response.map((e) => CCTV.fromMap(e)).toList().cast<CCTV>();
    });
  }

  Future<void> deleteCCTV(String id) async {
    await supabase
        .from('cctvs')
        .delete()
        .eq('id', id); // Menghapus data CCTV berdasarkan ID
    fetchCCTVs(); // Refresh data setelah penghapusan
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data CCTV')), // Judul halaman
      body: ListView.builder(
        itemCount: cctvs.length, // Jumlah item berdasarkan panjang list cctvs
        itemBuilder: (context, index) {
          final cctv = cctvs[index]; // Mengambil CCTV berdasarkan index
          return Card(
            child: ListTile(
              leading: Image.network(
                cctv.imageUrl, // Menampilkan gambar CCTV dari URL
                width: 60, // Lebar gambar
                errorBuilder:
                    (_, __, ___) => const Icon(
                      Icons.image,
                    ), // Menampilkan ikon jika gambar gagal dimuat
              ),
              title: Text(cctv.name), // Menampilkan nama CCTV
              subtitle: Text(cctv.location), // Menampilkan lokasi CCTV
              trailing: Row(
                mainAxisSize:
                    MainAxisSize
                        .min, // Mengatur ukuran row agar sesuai dengan konten
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit), // Ikon untuk mengedit CCTV
                    onPressed: () async {
                      await Navigator.push(
                        context, // Navigasi ke halaman FormPage untuk mengedit CCTV
                        MaterialPageRoute(builder: (_) => FormPage(cctv: cctv)),
                      );
                      fetchCCTVs(); // Refresh data setelah kembali dari halaman edit
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete), // Ikon untuk menghapus CCTV
                    onPressed:
                        () => deleteCCTV(
                          cctv.id,
                        ), // Menghapus CCTV berdasarkan ID
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add), // Ikon untuk menambah CCTV
        onPressed: () async {
          await Navigator.push(
            context, // Navigasi ke halaman FormPage untuk menambah CCTV baru
            MaterialPageRoute(builder: (_) => const FormPage()),
          );
          fetchCCTVs();
        },
      ),
    );
  }
}
