class CCTV {
  final String id;
  final String name;
  final String location;
  final String imageUrl;

  CCTV({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
  });

  factory CCTV.fromMap(Map<String, dynamic> map) {
    return CCTV(
      id: map['id'],
      name: map['name'],
      location: map['location'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'location': location, 'image_url': imageUrl};
  }
}
