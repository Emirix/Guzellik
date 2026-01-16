import 'venue.dart';
import '../../core/utils/image_utils.dart';

/// Campaign model representing promotional offers from venues
class Campaign {
  final String id;
  final String venueId;
  final String title;
  final String? description;
  final int? discountPercentage; // 0-100
  final double? discountAmount; // TRY amount
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined venue data (populated when fetched with venue info)
  final Venue? venue;

  Campaign({
    required this.id,
    required this.venueId,
    required this.title,
    this.description,
    this.discountPercentage,
    this.discountAmount,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.venue,
  }) : assert(
         discountPercentage != null || discountAmount != null,
         'At least one discount type must be provided',
       );

  /// Check if campaign is currently active
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if campaign is expiring soon (within 3 days)
  bool get isExpiringSoon {
    if (!isCurrentlyActive) return false;
    final daysUntilEnd = endDate.difference(DateTime.now()).inDays;
    return daysUntilEnd <= 3 && daysUntilEnd >= 0;
  }

  /// Get formatted discount string for display
  String get formattedDiscount {
    if (discountPercentage != null) {
      return '%$discountPercentage';
    } else if (discountAmount != null) {
      return '${discountAmount!.toStringAsFixed(0)}₺';
    }
    return '';
  }

  /// Get discount type for sorting
  DiscountType get discountType {
    if (discountPercentage != null) {
      return DiscountType.percentage;
    } else {
      return DiscountType.amount;
    }
  }

  /// Get numeric discount value for sorting
  double get discountValue {
    if (discountPercentage != null) {
      return discountPercentage!.toDouble();
    } else if (discountAmount != null) {
      return discountAmount!;
    }
    return 0.0;
  }

  /// Get days remaining until campaign ends
  int get daysRemaining {
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Get formatted date range
  String get formattedDateRange {
    final startStr = '${startDate.day}.${startDate.month}.${startDate.year}';
    final endStr = '${endDate.day}.${endDate.month}.${endDate.year}';
    return '$startStr - $endStr';
  }

  factory Campaign.fromJson(Map<String, dynamic> json) {
    // Parse venue if included
    Venue? venueData;
    if (json['venues'] != null) {
      venueData = Venue.fromJson(json['venues'] as Map<String, dynamic>);
    } else if (json['venue'] != null) {
      venueData = Venue.fromJson(json['venue'] as Map<String, dynamic>);
    }

    return Campaign(
      id: json['id'] as String,
      venueId: json['venue_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      discountPercentage: json['discount_percentage'] as int?,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      imageUrl: ImageUtils.normalizeUrl(json['image_url'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      venue: venueData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'title': title,
      'description': description,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (venue != null) 'venue': venue!.toJson(),
    };
  }

  Campaign copyWith({
    String? id,
    String? venueId,
    String? title,
    String? description,
    int? discountPercentage,
    double? discountAmount,
    DateTime? startDate,
    DateTime? endDate,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Venue? venue,
  }) {
    return Campaign(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      venue: venue ?? this.venue,
    );
  }
}

/// Discount type enum
enum DiscountType { percentage, amount }
