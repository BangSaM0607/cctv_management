class CCTV {
  final String id; // ID unik (UUID)
  final String name; // Nama gedung
  final String location; // Lokasi CCTV
  final String imageUrl; // URL gambar CCTV

  CCTV({
    required this.id, // ID unik
    required this.name, // Nama gedung
    required this.location, // Lokasi CCTV
    required this.imageUrl, // URL gambar CCTV
  });

  factory CCTV.fromMap(Map<String, dynamic> map) {
    return CCTV(
      id: map['id'], // ID unik
      name: map['name'], // Nama gedung
      location: map['location'], // Lokasi CCTV
      imageUrl: map['image_url'], // URL gambar CCTV
    );
  }

  Map<String, dynamic> toMap() {
    // Mengubah objek CCTV menjadi Map untuk disimpan di database
    return {'name': name, 'location': location, 'image_url': imageUrl};
  }
}
