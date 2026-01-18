import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/business_provider.dart';

/// Business bottom navigation bar
/// Shows 3 tabs: Profilim, Abonelik, Mağaza
class BusinessBottomNav extends StatelessWidget {
  const BusinessBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final selectedIndex = appState.selectedBottomNavIndex;

        return BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 65,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profilim',
                isSelected: selectedIndex == 0,
                onTap: () => _handleTap(context, appState, 0),
              ),
              _buildNavItem(
                context,
                icon: Icons.dashboard_customize_outlined,
                activeIcon: Icons.dashboard_customize,
                label: 'Yönetim',
                isSelected: selectedIndex == 1,
                onTap: () => _handleTap(context, appState, 1),
              ),
              _buildNavItem(
                context,
                icon: Icons.card_membership_outlined,
                activeIcon: Icons.card_membership,
                label: 'Abonelik',
                isSelected: selectedIndex == 2,
                onTap: () => _handleTap(context, appState, 2),
              ),
              _buildNavItem(
                context,
                icon: Icons.store_outlined,
                activeIcon: Icons.store,
                label: 'Mağaza',
                isSelected: selectedIndex == 3,
                onTap: () => _handleTap(context, appState, 3),
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
  }) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 26),
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
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, AppStateProvider appState, int index) {
    appState.setBottomNavIndex(index);

    // Navigate based on index using GoRouter
    switch (index) {
      case 0:
        // Profile - Show venue details for business users
        final businessProvider = context.read<BusinessProvider>();
        if (businessProvider.isBusinessMode &&
            businessProvider.businessVenue != null) {
          context.go('/venue/${businessProvider.businessVenue!.id}');
        } else {
          context.go('/profile');
        }
        break;
      case 1:
        // Admin/Management
        context.go('/business/admin');
        break;
      case 2:
        // Subscription
        context.go('/business/subscription');
        break;
      case 3:
        // Store
        context.go('/business/store');
        break;
    }
  }
}
