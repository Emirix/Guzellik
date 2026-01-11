class Specialist {
  final String id;
  final String venueId;
  final String name;
  final String profession;
  final String? gender;
  final String? photoUrl;
  final String? bio;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Specialist({
    required this.id,
    required this.venueId,
    required this.name,
    required this.profession,
    this.gender,
    this.photoUrl,
    this.bio,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['id'] as String,
      venueId: json['venue_id'] as String,
      name: json['name'] as String,
      profession: json['profession'] as String,
      gender: json['gender'] as String?,
      photoUrl: json['photo_url'] as String?,
      bio: json['bio'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'name': name,
      'profession': profession,
      'gender': gender,
      'photo_url': photoUrl,
      'bio': bio,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Specialist copyWith({
    String? id,
    String? venueId,
    String? name,
    String? profession,
    String? gender,
    String? photoUrl,
    String? bio,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialist(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Specialist(id: $id, name: $name, profession: $profession, venueId: $venueId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Specialist &&
        other.id == id &&
        other.venueId == venueId &&
        other.name == name &&
        other.profession == profession &&
        other.gender == gender &&
        other.photoUrl == photoUrl &&
        other.bio == bio &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        venueId.hashCode ^
        name.hashCode ^
        profession.hashCode ^
        gender.hashCode ^
        photoUrl.hashCode ^
        bio.hashCode ^
        sortOrder.hashCode;
  }
}
