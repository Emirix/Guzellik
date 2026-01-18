import '../../core/utils/image_utils.dart';

enum ReviewStatus { pending, approved, rejected }

class Review {
  final String id;
  final String venueId;
  final String userId;
  final double rating;
  final String? comment;
  final DateTime createdAt;
  final ReviewStatus status;
  final String? businessReply;
  final DateTime? replyAt;
  final int helpfulCount;
  final List<String> photos;

  // Joined profile fields (optional, if using select(..., profiles(...)))
  final String? userFullName;
  final String? userAvatarUrl;

  Review({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.status = ReviewStatus.pending,
    this.businessReply,
    this.replyAt,
    this.helpfulCount = 0,
    this.photos = const [],
    this.userFullName,
    this.userAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Check if profiles table data is joined via Supabase
    // Typical response might be: { ..., profiles: { full_name: "...", avatar_url: "..." } }
    String? name;
    String? avatar;

    if (json['profiles'] != null && json['profiles'] is Map) {
      final profile = json['profiles'];
      name = profile['full_name'];
      avatar = ImageUtils.normalizeUrl(profile['avatar_url']);
    }

    // Parse status
    ReviewStatus parsedStatus = ReviewStatus.pending;
    if (json['status'] != null) {
      try {
        parsedStatus = ReviewStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ReviewStatus.pending,
        );
      } catch (_) {}
    }

    // Parse photos
    List<String> parsedPhotos = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        parsedPhotos = (json['photos'] as List)
            .map((e) => ImageUtils.normalizeUrl(e.toString()) ?? e.toString())
            .toList();
      }
    }

    return Review(
      id: json['id'] as String? ?? '',
      venueId: json['venue_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      status: parsedStatus,
      businessReply: json['business_reply'] as String?,
      replyAt: json['reply_at'] != null
          ? DateTime.parse(json['reply_at'] as String)
          : null,
      helpfulCount: json['helpful_count'] as int? ?? 0,
      photos: parsedPhotos,
      userFullName: name ?? json['user_name'], // Fallback for RPC
      userAvatarUrl:
          avatar ??
          ImageUtils.normalizeUrl(json['user_avatar']), // Fallback for RPC
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'business_reply': businessReply,
      'reply_at': replyAt?.toIso8601String(),
      'helpful_count': helpfulCount,
      'photos': photos,
    };
  }

  bool isOwnedBy(String? currentUserId) {
    if (currentUserId == null) return false;
    return userId == currentUserId;
  }

  Review copyWith({
    String? id,
    String? venueId,
    String? userId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    ReviewStatus? status,
    String? businessReply,
    DateTime? replyAt,
    int? helpfulCount,
    List<String>? photos,
    String? userFullName,
    String? userAvatarUrl,
  }) {
    return Review(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      businessReply: businessReply ?? this.businessReply,
      replyAt: replyAt ?? this.replyAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      photos: photos ?? this.photos,
      userFullName: userFullName ?? this.userFullName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
    );
  }
}
