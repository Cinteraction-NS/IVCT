class Organizer {
  final int id;
  final String name;
  final String email;
  final String profilePhotoPath;

  Organizer({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePhotoPath,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) => Organizer(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        profilePhotoPath: json['profile_photo_path'] as String,
      );
}
