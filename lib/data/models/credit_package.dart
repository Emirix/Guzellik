/// Credit package model
class CreditPackage {
  final String id;
  final String name;
  final int creditAmount;
  final double price;
  final String? description;
  final bool isPopular;

  CreditPackage({
    required this.id,
    required this.name,
    required this.creditAmount,
    required this.price,
    this.description,
    this.isPopular = false,
  });

  /// Create from JSON
  factory CreditPackage.fromJson(Map<String, dynamic> json) {
    return CreditPackage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      creditAmount: json['credit_amount'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credit_amount': creditAmount,
      'price': price,
      'description': description,
      'is_popular': isPopular,
    };
  }
}
