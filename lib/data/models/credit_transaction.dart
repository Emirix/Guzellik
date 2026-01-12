/// Credit transaction model
class CreditTransaction {
  final String id;
  final String venueId;
  final int amount;
  final String type;
  final String? description;
  final DateTime createdAt;

  CreditTransaction({
    required this.id,
    required this.venueId,
    required this.amount,
    required this.type,
    this.description,
    required this.createdAt,
  });

  /// Create from JSON
  factory CreditTransaction.fromJson(Map<String, dynamic> json) {
    return CreditTransaction(
      id: json['id']?.toString() ?? '',
      venueId: json['venue_id']?.toString() ?? '',
      amount: json['amount'] as int? ?? 0,
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'amount': amount,
      'type': type,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
