import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../../core/theme/app_colors.dart';

/// Profile screen - Redesigned based on design/profilim.php
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDFBFB).withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFF3E8EA).withOpacity(0.5),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                  const Text(
                    'Profilim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B0E11),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to edit profile
                    },
                    child: const Text(
                      'Düzenle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Header
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        final user = authProvider.currentUser;
                        final metadata = user?.userMetadata;

                        return ProfileHeader(
                          name: metadata?['full_name'] ?? 'Kullanıcı',
                          email: user?.email ?? '',
                          avatarUrl: metadata?['avatar_url'],
                          membershipLevel: 'Gold Üye',
                          onEditPressed: () {
                            // TODO: Navigate to edit avatar
                          },
                        );
                      },
                    ),

                    // Stats Section
                    const ProfileStats(
                      appointments: 24, // Represents rewards/reviews now
                      favorites: 5,
                      points: 150,
                    ),

                    // Menu List
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          // Group 1: Main Actions
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3E8EA),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ProfileMenuItem(
                                  icon: Icons.rate_review_outlined,
                                  title: 'İncelemelerim',
                                  isPrimary: true,
                                  onTap: () {
                                    // TODO: Navigate to reviews
                                  },
                                ),
                                ProfileMenuItem(
                                  icon: Icons.favorite,
                                  title: 'Favorilerim',
                                  isPrimary: true,
                                  onTap: () {
                                    context.push('/favorites');
                                  },
                                ),
                                ProfileMenuItem(
                                  icon: Icons.account_balance_wallet,
                                  title: 'Cüzdanım',
                                  subtitle: 'Son işlem: Dün',
                                  isPrimary: true,
                                  showDivider: false,
                                  onTap: () {
                                    // TODO: Navigate to wallet
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Group 2: Settings & Support
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3E8EA),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ProfileMenuItem(
                                  icon: Icons.notifications,
                                  title: 'Bildirim Ayarları',
                                  onTap: () {
                                    // TODO: Navigate to notification settings
                                  },
                                ),
                                ProfileMenuItem(
                                  icon: Icons.settings,
                                  title: 'Genel Ayarlar',
                                  onTap: () {
                                    // TODO: Navigate to settings
                                  },
                                ),
                                ProfileMenuItem(
                                  icon: Icons.help,
                                  title: 'Yardım & Destek',
                                  showDivider: false,
                                  onTap: () {
                                    // TODO: Navigate to help
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Logout Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    await authProvider.signOut();
                                    if (context.mounted) {
                                      context.go('/');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    side: BorderSide(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        authProvider.isLoading
                                            ? 'Çıkış yapılıyor...'
                                            : 'Çıkış Yap',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // Version
                          Text(
                            'Versiyon 2.1.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
