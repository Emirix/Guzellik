import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminBasicInfoProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  // State
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _venueData;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get venueData => _venueData;

  String get name => _venueData?['name'] ?? '';
  String get description => _venueData?['description'] ?? '';
  Map<String, dynamic> get socialLinks =>
      _venueData?['social_links'] as Map<String, dynamic>? ?? {};

  String get phone => socialLinks['phone']?.toString() ?? '';
  String get email => socialLinks['email']?.toString() ?? '';
  String get instagramUrl => socialLinks['instagram']?.toString() ?? '';
  String get whatsappNumber => socialLinks['whatsapp']?.toString() ?? '';
  String get facebookUrl => socialLinks['facebook']?.toString() ?? '';
  String get websiteUrl => socialLinks['website']?.toString() ?? '';

  /// Load venue basic info
  Future<void> loadVenueBasicInfo(String venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('venues')
          .select('id, name, description, social_links')
          .eq('id', venueId)
          .single();

      _venueData = response;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error loading venue basic info: $e');
      }
    }
  }

  /// Update basic info
  Future<void> updateBasicInfo({
    required String venueId,
    String? name,
    String? description,
    String? phone,
    String? email,
    Map<String, dynamic>? socialLinks,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;

      // Merge phone and email into social_links
      if (socialLinks != null || phone != null || email != null) {
        final currentSocialLinks = Map<String, dynamic>.from(
          _venueData?['social_links'] as Map<String, dynamic>? ?? {},
        );

        if (phone != null) currentSocialLinks['phone'] = phone;
        if (email != null) currentSocialLinks['email'] = email;
        if (socialLinks != null) {
          currentSocialLinks.addAll(socialLinks);
        }

        updateData['social_links'] = currentSocialLinks;
      }

      await _supabase.from('venues').update(updateData).eq('id', venueId);

      // Optimistic update
      _venueData = {...?_venueData, ...updateData};
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error updating venue basic info: $e');
      }
      rethrow;
    }
  }

  /// Validate phone number
  bool validatePhone(String phone) {
    if (phone.isEmpty) return true; // Optional field
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\s'), ''));
  }

  /// Validate email
  bool validateEmail(String email) {
    if (email.isEmpty) return true; // Optional field
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate URL
  bool validateUrl(String url) {
    if (url.isEmpty) return true; // Optional field
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
