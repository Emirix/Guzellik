import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/venue_category.dart';

/// Repository for venue category operations
class VenueCategoryRepository {
  final SupabaseClient _supabase;

  VenueCategoryRepository(this._supabase);

  /// Get all active venue categories
  /// Results are ordered alphabetically by name
  Future<List<VenueCategory>> getActiveCategories() async {
    try {
      final response = await _supabase
          .from('venue_categories')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => VenueCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Kategoriler yüklenirken hata oluştu: $e');
    }
  }

  /// Get a single category by ID
  Future<VenueCategory?> getCategoryById(String id) async {
    try {
      final response = await _supabase
          .from('venue_categories')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return VenueCategory.fromJson(response);
    } catch (e) {
      throw Exception('Kategori yüklenirken hata oluştu: $e');
    }
  }

  /// Get a category by slug
  Future<VenueCategory?> getCategoryBySlug(String slug) async {
    try {
      final response = await _supabase
          .from('venue_categories')
          .select()
          .eq('slug', slug)
          .maybeSingle();

      if (response == null) return null;

      return VenueCategory.fromJson(response);
    } catch (e) {
      throw Exception('Kategori yüklenirken hata oluştu: $e');
    }
  }
}
