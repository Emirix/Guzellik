import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venue_feature.dart';
import '../services/supabase_service.dart';

class VenueFeaturesRepository {
  final SupabaseClient _supabase;

  VenueFeaturesRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.instance.client;

  /// Get all available features
  Future<List<VenueFeature>> getAllFeatures() async {
    try {
      final response = await _supabase
          .from('venue_features')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      return (response as List)
          .map((json) => VenueFeature.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch features: $e');
    }
  }

  /// Get features grouped by category
  Future<Map<String, List<VenueFeature>>> getFeaturesByCategory() async {
    try {
      final features = await getAllFeatures();
      final Map<String, List<VenueFeature>> grouped = {};

      for (final feature in features) {
        if (!grouped.containsKey(feature.category)) {
          grouped[feature.category] = [];
        }
        grouped[feature.category]!.add(feature);
      }

      return grouped;
    } catch (e) {
      throw Exception('Failed to fetch features by category: $e');
    }
  }

  /// Get selected features for a venue
  Future<List<VenueFeature>> getVenueFeatures(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_selected_features')
          .select('feature_id, venue_features(*)')
          .eq('venue_id', venueId);

      return (response as List)
          .map((json) => VenueFeature.fromJson(json['venue_features']))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch venue features: $e');
    }
  }

  /// Get selected feature IDs for a venue
  Future<List<String>> getVenueFeatureIds(String venueId) async {
    try {
      final response = await _supabase
          .from('venue_selected_features')
          .select('feature_id')
          .eq('venue_id', venueId);

      return (response as List)
          .map((json) => json['feature_id'] as String)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch venue feature IDs: $e');
    }
  }

  /// Update venue features (replace all)
  Future<void> updateVenueFeatures(
    String venueId,
    List<String> featureIds,
  ) async {
    try {
      // Delete existing features
      await _supabase
          .from('venue_selected_features')
          .delete()
          .eq('venue_id', venueId);

      // Insert new features
      if (featureIds.isNotEmpty) {
        final data = featureIds
            .map((featureId) => {'venue_id': venueId, 'feature_id': featureId})
            .toList();

        await _supabase.from('venue_selected_features').insert(data);
      }
    } catch (e) {
      throw Exception('Failed to update venue features: $e');
    }
  }

  /// Add a single feature to venue
  Future<void> addVenueFeature(String venueId, String featureId) async {
    try {
      await _supabase.from('venue_selected_features').insert({
        'venue_id': venueId,
        'feature_id': featureId,
      });
    } catch (e) {
      throw Exception('Failed to add venue feature: $e');
    }
  }

  /// Remove a single feature from venue
  Future<void> removeVenueFeature(String venueId, String featureId) async {
    try {
      await _supabase
          .from('venue_selected_features')
          .delete()
          .eq('venue_id', venueId)
          .eq('feature_id', featureId);
    } catch (e) {
      throw Exception('Failed to remove venue feature: $e');
    }
  }
}
