import 'venue.dart';

class QuoteResponse {
  final String id;
  final String quoteRequestId;
  final String venueId;
  final double price;
  final String? message;
  final DateTime createdAt;
  final Venue? venue;

  QuoteResponse({
    required this.id,
    required this.quoteRequestId,
    required this.venueId,
    required this.price,
    this.message,
    required this.createdAt,
    this.venue,
  });

  factory QuoteResponse.fromJson(Map<String, dynamic> json) {
    return QuoteResponse(
      id: json['id'] as String,
      quoteRequestId: json['quote_request_id'] as String,
      venueId: json['venue_id'] as String,
      price: (json['price'] as num).toDouble(),
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      venue: json['venues'] != null
          ? Venue.fromJson(json['venues'] as Map<String, dynamic>)
          : null,
    );
  }
}
