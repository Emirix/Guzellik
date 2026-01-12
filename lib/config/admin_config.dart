/// Admin panel configuration
/// Stores the admin panel URL and provides helper methods
class AdminConfig {
  /// Admin panel base URL
  /// For development: 'http://localhost:5173'
  /// For production: 'https://admin.guzellikharitam.com'
  static const String adminPanelUrl = 'http://localhost:5173';

  /// Get admin panel URL with venue ID
  static String getAdminUrl(String venueId) {
    return '$adminPanelUrl/dashboard?venue=$venueId';
  }

  /// Get admin panel base URL
  static String getBaseUrl() {
    return adminPanelUrl;
  }
}
