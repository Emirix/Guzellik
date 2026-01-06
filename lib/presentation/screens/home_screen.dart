import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/common/custom_bottom_nav.dart';
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
    const FavoritesScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
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
