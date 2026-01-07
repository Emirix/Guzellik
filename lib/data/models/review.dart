class Review {
  final String id;
  final String venueId;
  final String userId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

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
      avatar = profile['avatar_url'];
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
      userFullName: name,
      userAvatarUrl: avatar,
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
    };
  }
}
