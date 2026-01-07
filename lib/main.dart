import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_config.dart';
import 'config/environment_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'data/services/supabase_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/location_service.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'presentation/providers/discovery_provider.dart';
import 'presentation/providers/venue_details_provider.dart';
import 'presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue without Firebase for now
  }

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Supabase initialization error: $e');
    // Continue without Supabase for now
  }

  // Initialize Notification Service
  try {
    await NotificationService.instance.initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Notification service initialization error: $e');
    // Continue without notifications for now
  }

  runApp(const GuzellikApp());
}

class GuzellikApp extends StatelessWidget {
  const GuzellikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => DiscoveryProvider()),
        ChangeNotifierProvider(create: (_) => VenueDetailsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
