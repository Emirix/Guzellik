import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/search_provider.dart';

/// Custom bottom navigation bar using BottomAppBar for FAB integration
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationCount = context.watch<NotificationProvider>().unreadCount;

    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final selectedIndex = appState.selectedBottomNavIndex;

        return BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          height: 65,
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Left side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.explore_outlined,
                      activeIcon: Icons.explore,
                      label: 'Keşfet',
                      isSelected: selectedIndex == 0,
                      onTap: () => _handleTap(context, appState, 0),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.search_outlined,
                      activeIcon: Icons.search,
                      label: 'Ara',
                      isSelected: selectedIndex == 1,
                      onTap: () => _handleTap(context, appState, 1),
                    ),
                  ],
                ),
              ),

              // Middle gap for FAB
              const SizedBox(width: 48),

              // Right side
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.notifications_outlined,
                      activeIcon: Icons.notifications,
                      label: 'Bildirimler',
                      isSelected: selectedIndex == 2,
                      badgeCount: notificationCount,
                      onTap: () => _handleTap(context, appState, 2),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profil',
                      isSelected: selectedIndex == 3,
                      onTap: () => _handleTap(context, appState, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 26),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, AppStateProvider appState, int index) {
    appState.setBottomNavIndex(index);

    // Reset discovery view to home when returning to Explore tab
    if (index == 0) {
      final discoveryProvider = context.read<DiscoveryProvider>();
      discoveryProvider.setViewMode(DiscoveryViewMode.home);
    }
    // Reset search filters when going to Search tab
    if (index == 1) {
      final searchProvider = context.read<SearchProvider>();
      searchProvider.clearFilters();
      searchProvider.clearSearch();
    }
  }
}
