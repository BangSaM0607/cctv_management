class CCTV {
  final String? id;
  final String name;
  final String location;
  final String imageUrl;
  final bool status;

  CCTV({
    this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.status,
  });

  factory CCTV.fromMap(Map<String, dynamic> map) {
    return CCTV(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      imageUrl: map['image_url'],
      status: map['status'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'location': location,
      'image_url': imageUrl,
      'status': status,
    };
  }
}
