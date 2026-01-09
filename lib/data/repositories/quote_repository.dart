import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quote_request.dart';
import '../models/quote_response.dart';
import '../models/service_category.dart';

class QuoteRepository {
  final SupabaseClient _client;

  QuoteRepository(this._client);

  /// Get all service categories
  Future<List<ServiceCategory>> getServiceCategories() async {
    final response = await _client
        .from('service_categories')
        .select()
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map((json) => ServiceCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Create a new quote request
  Future<String> createQuoteRequest({
    DateTime? preferredDate,
    required String? preferredTimeSlot,
    required String? notes,
    required List<String> serviceCategoryIds,
  }) async {
    final response = await _client.rpc(
      'create_quote_request',
      params: {
        'p_preferred_date': preferredDate?.toIso8601String().split('T')[0],
        'p_preferred_time_slot': preferredTimeSlot,
        'p_notes': notes,
        'p_service_category_ids': serviceCategoryIds,
      },
    );

    return response as String;
  }

  /// Get user's quote requests
  Future<List<QuoteRequest>> getMyQuoteRequests() async {
    final response = await _client
        .from('quote_requests')
        .select('''
          *,
          quote_request_services(
            service_categories(*)
          ),
          quote_responses(count)
        ''')
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((json) {
      // Flatten response count
      final responseCount = (json['quote_responses'] as List).isNotEmpty
          ? json['quote_responses'][0]['count'] as int
          : 0;

      // Map services
      final services = (json['quote_request_services'] as List)
          .map((s) => s['service_categories'])
          .toList();

      final fullJson = {
        ...json as Map<String, dynamic>,
        'response_count': responseCount,
        'services': services,
      };

      return QuoteRequest.fromJson(fullJson);
    }).toList();
  }

  /// Get quote request details by id
  Future<QuoteRequest> getQuoteRequestById(String id) async {
    final response = await _client
        .from('quote_requests')
        .select('''
          *,
          quote_request_services(
            service_categories(*)
          )
        ''')
        .eq('id', id)
        .single();

    final services = (response['quote_request_services'] as List)
        .map((s) => s['service_categories'])
        .toList();

    final fullJson = {...response, 'services': services};

    return QuoteRequest.fromJson(fullJson);
  }

  /// Get responses for a quote request
  Future<List<QuoteResponse>> getQuoteResponses(String quoteRequestId) async {
    final response = await _client
        .from('quote_responses')
        .select('''
          *,
          venues(*)
        ''')
        .eq('quote_request_id', quoteRequestId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => QuoteResponse.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Close a quote request
  Future<void> closeQuoteRequest(String id) async {
    await _client
        .from('quote_requests')
        .update({'status': 'closed'})
        .eq('id', id);
  }
}
