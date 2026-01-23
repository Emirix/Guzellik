/// Central configuration file for app branding and constants
/// This is the single source of truth for app name, logos, and branding
class AppConfig {
  // App Identity
  static const String appName = 'Güzellik Haritam';
  static const String appNameShort = 'Güzellik Haritam';
  static const String appTagline = 'Güzelliğiniz için her şey bir arada';

  // Version
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // Assets - Logos
  static const String appLogo = 'assets/logos/app_logo.png';
  static const String appLogoLight = 'assets/logos/app_logo_light.png';
  static const String appLogoDark = 'assets/logos/app_logo_dark.png';
  static const String appIcon = 'assets/icons/app_icon.png';

  // Assets - Icons
  static const String iconVerified = 'assets/icons/verified_badge.svg';
  static const String iconPopular = 'assets/icons/popular_badge.svg';
  static const String iconHygiene = 'assets/icons/hygiene_badge.svg';

  // Assets - Placeholders
  static const String placeholderVenue = 'assets/images/placeholder_venue.png';
  static const String placeholderProfile =
      'assets/images/placeholder_profile.png';
  static const String placeholderService =
      'assets/images/placeholder_service.png';

  // Contact & Social
  static const String supportEmail = 'destek@guzellikplatformu.com';
  static const String supportPhone = '+90 XXX XXX XX XX';
  static const String websiteUrl = 'https://guzellikplatformu.com';
  static const String instagramUrl = 'https://instagram.com/guzellikplatformu';

  // Legal
  static const String privacyPolicyUrl =
      'https://guzellikplatformu.com/gizlilik';
  static const String termsOfServiceUrl =
      'https://guzellikplatformu.com/kullanim-kosullari';
  static const String kvkkUrl = 'https://guzellikplatformu.com/kvkk';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableDarkMode = true;

  // Map Configuration
  static const double defaultMapZoom = 14.0;
  static const double defaultLatitude = 41.0082; // Istanbul
  static const double defaultLongitude = 28.9784; // Istanbul

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxSearchResults = 100;

  // Cache Duration (in hours)
  static const int imageCacheDuration = 24;
  static const int dataCacheDuration = 1;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;

  // In-App Purchases
  static const String premiumSubscriptionId =
      'isletme_aboneligi1'; // TODO: Replace with real ID from Play Console
  static const Set<String> subscriptionIds = {premiumSubscriptionId};

  // Private constructor to prevent instantiation
  AppConfig._();
}
