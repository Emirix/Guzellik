import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/notification_provider.dart';

/// Custom bottom navigation bar
/// Main navigation for the app
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationCount = context.watch<NotificationProvider>().unreadCount;

    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return BottomNavigationBar(
          currentIndex: appState.selectedBottomNavIndex,
          onTap: (index) => appState.setBottomNavIndex(index),
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Keşfet',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Ara',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoriler',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                label: Text(notificationCount.toString()),
                isLabelVisible: notificationCount > 0,
                backgroundColor: Colors.red,
                child: const Icon(Icons.notifications_outlined),
              ),
              activeIcon: Badge(
                label: Text(notificationCount.toString()),
                isLabelVisible: notificationCount > 0,
                backgroundColor: Colors.red,
                child: const Icon(Icons.notifications),
              ),
              label: 'Bildirimler',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        );
      },
    );
  }
}
