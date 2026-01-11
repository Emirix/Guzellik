import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'core/services/ad_service.dart';
import 'data/services/supabase_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/location_service.dart';
import 'data/services/location_preferences.dart';
import 'data/repositories/venue_repository.dart';
import 'data/repositories/location_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'presentation/providers/discovery_provider.dart';
import 'presentation/providers/venue_details_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'presentation/providers/review_submission_provider.dart';
import 'presentation/providers/search_provider.dart';
import 'presentation/providers/location_onboarding_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/favorites_provider.dart';
import 'presentation/providers/campaign_provider.dart';
import 'presentation/providers/business_provider.dart';
import 'presentation/providers/subscription_provider.dart';
import 'presentation/providers/admin_services_provider.dart';
import 'presentation/providers/admin_gallery_provider.dart';
import 'presentation/providers/admin_specialists_provider.dart';
import 'presentation/providers/admin_campaigns_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ============================================
  // OPTIMIZED: Parallel Service Initialization
  // ============================================

  // Phase 1: Core services (Firebase & Supabase) - paralel başlatma
  await Future.wait([_initFirebase(), _initSupabase()], eagerError: false);

  // Phase 2: Dependent services - paralel başlatma
  await Future.wait([_initNotifications(), _initAdMob()], eagerError: false);

  runApp(const GuzellikApp());
}

/// Firebase başlatma (izole hata yönetimi)
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    debugPrint('✓ Firebase initialized');
    return true;
  } catch (e) {
    debugPrint('✗ Firebase error: $e');
    return false;
  }
}

/// Supabase başlatma (izole hata yönetimi)
Future<bool> _initSupabase() async {
  try {
    await SupabaseService.initialize();
    debugPrint('✓ Supabase initialized');
    return true;
  } catch (e) {
    debugPrint('✗ Supabase error: $e');
    return false;
  }
}

/// Notification servisi başlatma
Future<bool> _initNotifications() async {
  try {
    await NotificationService.instance.initialize();
    debugPrint('✓ Notifications initialized');
    return true;
  } catch (e) {
    debugPrint('✗ Notifications error: $e');
    return false;
  }
}

/// AdMob başlatma
Future<bool> _initAdMob() async {
  try {
    await AdService.instance.initialize();
    debugPrint('✓ AdMob initialized');
    return true;
  } catch (e) {
    debugPrint('✗ AdMob error: $e');
    return false;
  }
}

class GuzellikApp extends StatelessWidget {
  const GuzellikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => LocationService()),
        Provider(create: (_) => LocationPreferences()),
        Provider(create: (_) => LocationRepository()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => VenueDetailsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(
          create: (_) => ReviewSubmissionProvider(VenueRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(venueRepository: VenueRepository()),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationOnboardingProvider(
            locationService: context.read<LocationService>(),
            locationRepository: context.read<LocationRepository>(),
            locationPreferences: context.read<LocationPreferences>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(venueRepository: VenueRepository()),
        ),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => AdminServicesProvider()),
        ChangeNotifierProvider(create: (_) => AdminGalleryProvider()),
        ChangeNotifierProvider(create: (_) => AdminSpecialistsProvider()),
        ChangeNotifierProvider(create: (_) => AdminCampaignsProvider()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.themeMode,

            // Router
            routerConfig: AppRouter.router,

            // Locale
            locale: const Locale('tr', 'TR'),
            supportedLocales: const [Locale('tr', 'TR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
