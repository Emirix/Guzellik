class Customer {
  final String id;
  final String ownerId;
  final String name;
  final String phone;
  final int? gender;
  final DateTime? birthDate;
  final String? notes;
  final bool isDeleted;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.gender,
    this.birthDate,
    this.notes,
    this.isDeleted = false,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      gender: json['gender'] as int?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      notes: json['notes'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'phone': phone,
      'gender': gender,
      'birth_date': birthDate?.toIso8601String().split('T')[0], // YYYY-MM-DD
      'notes': notes,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Customer copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? phone,
    int? gender,
    DateTime? birthDate,
    String? notes,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      notes: notes ?? this.notes,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
