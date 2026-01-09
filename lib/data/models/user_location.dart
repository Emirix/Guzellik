/// UserLocation model representing user's selected or GPS-based location
class UserLocation {
  final String provinceName;
  final String districtName;
  final int? provinceId;
  final String? districtId;
  final double? latitude;
  final double? longitude;
  final bool isGPSBased;

  UserLocation({
    required this.provinceName,
    required this.districtName,
    this.provinceId,
    this.districtId,
    this.latitude,
    this.longitude,
    required this.isGPSBased,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      provinceName: json['provinceName'] as String,
      districtName: json['districtName'] as String,
      provinceId: json['provinceId'] as int?,
      districtId: json['districtId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isGPSBased: json['isGPSBased'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provinceName': provinceName,
      'districtName': districtName,
      'provinceId': provinceId,
      'districtId': districtId,
      'latitude': latitude,
      'longitude': longitude,
      'isGPSBased': isGPSBased,
    };
  }

  /// Get formatted location string (e.g., "Kadıköy, İstanbul")
  String get formattedLocation => '$districtName, $provinceName';

  /// Check if location has coordinates
  bool get hasCoordinates => latitude != null && longitude != null;

  UserLocation copyWith({
    String? provinceName,
    String? districtName,
    int? provinceId,
    String? districtId,
    double? latitude,
    double? longitude,
    bool? isGPSBased,
  }) {
    return UserLocation(
      provinceName: provinceName ?? this.provinceName,
      districtName: districtName ?? this.districtName,
      provinceId: provinceId ?? this.provinceId,
      districtId: districtId ?? this.districtId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isGPSBased: isGPSBased ?? this.isGPSBased,
    );
  }

  @override
  String toString() => formattedLocation;
}
