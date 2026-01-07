/// Expert/Specialist model for venue staff
class Expert {
  final String id;
  final String name;
  final String title;
  final String? photoUrl;
  final double? rating;
  final String? specialty;

  Expert({
    required this.id,
    required this.name,
    required this.title,
    this.photoUrl,
    this.rating,
    this.specialty,
  });

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] as String,
      name: json['name'] as String,
      title: json['title'] as String,
      photoUrl: json['photo_url'] as String?,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      specialty: json['specialty'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'photo_url': photoUrl,
      'rating': rating,
      'specialty': specialty,
    };
  }
}
