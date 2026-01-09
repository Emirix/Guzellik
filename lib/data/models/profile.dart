class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final int? provinceId;
  final String? districtId;
  final DateTime updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.provinceId,
    this.districtId,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      provinceId: json['province_id'] as int?,
      districtId: json['district_id'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'province_id': provinceId,
      'district_id': districtId,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
