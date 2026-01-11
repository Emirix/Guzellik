import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/explore_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/notifications_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/campaigns_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/password_reset_screen.dart';
import '../../presentation/screens/auth/complete_profile_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/venue/venue_details_screen.dart';
import '../../presentation/screens/location_onboarding_screen.dart';
import '../../presentation/screens/business/subscription_screen.dart';
import '../../presentation/screens/business/store_screen.dart';
import '../../presentation/screens/business/admin_dashboard_screen.dart';
import '../../presentation/screens/business/admin/admin_services_screen.dart';
import '../../presentation/screens/business/admin/admin_specialists_screen.dart';
import '../../presentation/screens/business/admin/admin_gallery_screen.dart';
import '../../presentation/screens/business/admin/admin_campaigns_screen.dart';
import '../../presentation/screens/business/admin/admin_working_hours_screen.dart';
import '../../presentation/screens/business/admin/admin_location_screen.dart';
import '../../presentation/screens/business/admin_basic_info_screen.dart';
import '../../presentation/widgets/common/business_bottom_nav.dart';
import '../../presentation/providers/business_provider.dart';
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
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        builder: (context, state) {
          final redirect = state.uri.queryParameters['redirect'];
          return CompleteProfileScreen(redirectPath: redirect);
        },
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
      // Venue Details (Public)
      GoRoute(
        path: '/venue/:id',
        name: 'venue-details',
        builder: (context, state) {
          final venueId = state.pathParameters['id']!;
          final extra = state.extra;
          final venue = extra is Venue
              ? extra
              : (extra is Map<String, dynamic> ? Venue.fromJson(extra) : null);

          // Check if user is viewing their own business venue
          final businessProvider = context.read<BusinessProvider>();
          final isOwnVenue =
              businessProvider.isBusinessMode &&
              businessProvider.businessVenue?.id == venueId;

          return VenueDetailsScreen(
            venueId: venueId,
            initialVenue: venue,
            bottomNavigationBar: isOwnVenue ? const BusinessBottomNav() : null,
            hideDefaultBottomBar: isOwnVenue,
          );
        },
      ),

      // Campaigns (Public)
      GoRoute(
        path: '/campaigns',
        name: 'campaigns',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'];
          return CampaignsScreen(venueId: venueId);
        },
      ),

      // Business Routes (Require Business Account)
      GoRoute(
        path: '/business/subscription',
        name: 'business-subscription',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Abonelik',
          redirectPath: '/business/subscription',
          child: SubscriptionScreen(),
        ),
      ),
      GoRoute(
        path: '/business/store',
        name: 'business-store',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Mağaza',
          redirectPath: '/business/store',
          child: StoreScreen(),
        ),
      ),

      // Admin Routes (Business Management)
      GoRoute(
        path: '/business/admin',
        name: 'business-admin',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Yönetim',
          redirectPath: '/business/admin',
          child: AdminDashboardScreen(),
        ),
      ),
      // TODO: Add sub-routes for services, gallery, specialists, campaigns
      GoRoute(
        path: '/business/admin/basic-info',
        name: 'admin-basic-info',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Temel Bilgiler',
          redirectPath: '/business/admin/basic-info',
          child: AdminBasicInfoScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/services',
        name: 'admin-services',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Hizmet Yönetimi',
          redirectPath: '/business/admin/services',
          child: AdminServicesScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/working-hours',
        name: 'admin-working-hours',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Çalışma Saatleri',
          redirectPath: '/business/admin/working-hours',
          child: AdminWorkingHoursScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/gallery',
        name: 'admin-gallery',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Galeri Yönetimi',
          redirectPath: '/business/admin/gallery',
          child: AdminGalleryScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/specialists',
        name: 'admin-specialists',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Uzman Yönetimi',
          redirectPath: '/business/admin/specialists',
          child: AdminSpecialistsScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/campaigns',
        name: 'admin-campaigns',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Kampanya Yönetimi',
          redirectPath: '/business/admin/campaigns',
          child: AdminCampaignsScreen(),
        ),
      ),
      GoRoute(
        path: '/business/admin/location',
        name: 'admin-location',
        builder: (context, state) => const AuthGuard(
          requiredFor: 'Konum Yönetimi',
          redirectPath: '/business/admin/location',
          child: AdminLocationScreen(),
        ),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Sayfa bulunamadı: ${state.uri}'))),
  );
}
