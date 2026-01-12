import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../widgets/common/custom_bottom_nav.dart';
import 'explore_screen.dart';
import 'search_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

import '../../core/widgets/auth_guard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Widget> _screens = const [
    ExploreScreen(),
    SearchScreen(),
    AuthGuard(
      requiredFor: 'Bildirimler',
      redirectPath: '/notifications',
      child: NotificationsScreen(),
    ),
    AuthGuard(
      requiredFor: 'Profilim',
      redirectPath: '/profile',
      child: ProfileScreen(isEmbedded: true),
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.pushNamed('campaigns');
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.local_offer, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation:
              const _CustomFloatingActionButtonLocation(12),
          bottomNavigationBar: const CustomBottomNav(),
        );
      },
    );
  }
}

class _CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  final double offsetY;
  const _CustomFloatingActionButtonLocation(this.offsetY);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final Offset standardOffset = FloatingActionButtonLocation.centerDocked
        .getOffset(scaffoldGeometry);
    return Offset(standardOffset.dx, standardOffset.dy + offsetY);
  }
}
