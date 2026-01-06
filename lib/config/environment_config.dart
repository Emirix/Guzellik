/// Environment configuration for different deployment stages
/// Supports dev, staging, and production environments
enum Environment {
  dev,
  staging,
  production,
}

class EnvironmentConfig {
  final Environment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String googleMapsApiKey;
  
  const EnvironmentConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.googleMapsApiKey,
  });
  
  // Development Configuration
  static const EnvironmentConfig dev = EnvironmentConfig(
    environment: Environment.dev,
    supabaseUrl: 'YOUR_DEV_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_DEV_SUPABASE_ANON_KEY',
    googleMapsApiKey: 'YOUR_DEV_GOOGLE_MAPS_API_KEY',
  );
  
  // Staging Configuration
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    supabaseUrl: 'YOUR_STAGING_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_STAGING_SUPABASE_ANON_KEY',
    googleMapsApiKey: 'YOUR_STAGING_GOOGLE_MAPS_API_KEY',
  );
  
  // Production Configuration
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    supabaseUrl: 'YOUR_PROD_SUPABASE_URL',
    supabaseAnonKey: 'YOUR_PROD_SUPABASE_ANON_KEY',
    googleMapsApiKey: 'YOUR_PROD_GOOGLE_MAPS_API_KEY',
  );
  
  // Current active configuration (change this based on build)
  static const EnvironmentConfig current = dev;
  
  bool get isDev => environment == Environment.dev;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;
}
