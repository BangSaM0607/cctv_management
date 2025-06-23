class CCTV {
  final String id; // ID unik CCTV
  final String name; // Nama CCTV
  final String location; // Lokasi CCTV
  final String imageUrl; // URL gambar CCTV
  final bool status; // Status aktif/non-aktif
  final DateTime createdAt; // Tanggal dibuat

  CCTV({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  // Factory method untuk membuat objek CCTV dari Map (misal dari Supabase)
  factory CCTV.fromMap(Map<String, dynamic> map) {
    return CCTV(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'] ?? '',
      status: map['status'] ?? false,
      createdAt:
          map['created_at'] != null
              ? DateTime.tryParse(map['created_at']) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  // Konversi objek CCTV ke Map (misal untuk insert/update ke Supabase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
