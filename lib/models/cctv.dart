class CCTV {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final bool status;
  final DateTime createdAt;

  CCTV({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.createdAt,
  });

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
