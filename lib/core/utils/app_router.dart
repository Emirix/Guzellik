import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/explore_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/password_reset_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/venue/venue_details_screen.dart';
import '../../presentation/screens/location_onboarding_screen.dart';
import '../../presentation/screens/quote/quote_request_screen.dart';
import '../../presentation/screens/quote/my_quotes_screen.dart';
import '../../presentation/screens/quote/quote_detail_screen.dart';
import '../../data/models/quote_request.dart';
import '../../data/models/venue.dart';
import '../widgets/auth_guard.dart';

/// App router configuration using go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return LoginScreen(redirectPath: redirect);
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/password-reset',
        name: 'password-reset',
        builder: (context, state) => const PasswordResetScreen(),
      ),

      // Main App Routes (Public)
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) =>
            const LocationOnboardingScreen(child: HomeScreen()),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const ExploreScreen(),
      ),

      // Protected Routes (Require Authentication)
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) {
          final tab = state.uri.queryParameters['tab'];
          return AuthGuard(
            requiredFor: 'Favoriler',
            redirectPath: '/favorites',
            child: FavoritesScreen(initialTab: tab),
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Bildirimler',
          redirectPath: '/notifications',
          child: NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Profilim',
          redirectPath: '/profile',
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/quote-request',
        name: 'quote-request',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Teklif İste',
          redirectPath: '/quote-request',
          child: QuoteRequestScreen(),
        ),
      ),

      GoRoute(
        path: '/my-quotes',
        name: 'my-quotes',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Tekliflerim',
          redirectPath: '/my-quotes',
          child: MyQuotesScreen(),
        ),
      ),
      GoRoute(
        path: '/quote-detail',
        name: 'quote-detail',
        builder: (context, state) {
          final quote = state.extra as QuoteRequest;
          return AuthGuard(
            requiredFor: 'Teklif Detayı',
            redirectPath: '/my-quotes',
            child: QuoteDetailScreen(quote: quote),
          );
        },
      ),
      // Venue Details (Public)
      GoRoute(
        path: '/venue/:id',
        name: 'venue-details',
        builder: (context, state) {
          final venueId = state.pathParameters['id']!;
          final venue = state.extra as Venue?;
          return VenueDetailsScreen(venueId: venueId, initialVenue: venue);
        },
      ),
    ],

    // Error handling
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Sayfa bulunamadı: ${state.uri}'))),
  );
}
