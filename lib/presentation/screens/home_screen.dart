import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state_provider.dart';
import '../providers/quote_provider.dart';
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
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final quoteProvider = context.read<QuoteProvider>();

              // If we haven't checked quotes yet, fetch them first
              if (!quoteProvider.hasCheckedQuotes) {
                await quoteProvider.fetchMyQuotes();
              }

              // Navigate based on whether user has quotes
              if (quoteProvider.hasAnyQuotes) {
                await context.pushNamed('my-quotes');
              } else {
                await context.pushNamed('quote-request');
              }
            },
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 8,
            shape: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    const Color(0xFFD4AF37), // Gold accent
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.request_quote,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: const CustomBottomNav(),
        );
      },
    );
  }
}
