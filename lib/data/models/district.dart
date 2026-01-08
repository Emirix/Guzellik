/// District model representing a district within a province
class District {
  final String id;
  final int provinceId;
  final String name;

  District({required this.id, required this.provinceId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      provinceId: json['province_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'province_id': provinceId, 'name': name};
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is District && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
