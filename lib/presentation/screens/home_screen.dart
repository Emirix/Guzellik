import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/common/custom_bottom_nav.dart';
import '../../core/widgets/auth_guard.dart';
import 'explore_screen.dart';
import 'search_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Home screen with bottom navigation
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final List<Widget> _screens = [
    const ExploreScreen(),
    const SearchScreen(),
    const AuthGuard(
      requiredFor: 'Favoriler',
      redirectPath: '/favorites',
      child: FavoritesScreen(),
    ),
    const AuthGuard(
      requiredFor: 'Bildirimler',
      redirectPath: '/notifications',
      child: NotificationsScreen(),
    ),
    const AuthGuard(
      requiredFor: 'Profilim',
      redirectPath: '/profile',
      child: ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return Scaffold(
          body: IndexedStack(
            index: appState.selectedBottomNavIndex,
            children: _screens,
          ),
          bottomNavigationBar: const CustomBottomNav(),
        );
      },
    );
  }
}
