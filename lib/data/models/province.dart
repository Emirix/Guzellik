/// Province model representing a Turkish province
class Province {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  Province({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });
  
  

  factory Province.fromJson(Map<String, dynamic> json) {  
    return Province(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Province && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
