import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../../core/theme/app_colors.dart';
import '../../core/enums/business_mode.dart';
import '../../config/admin_config.dart';

/// Helper function to open admin panel
Future<void> _openAdminPanel(BuildContext context, String? venueId) async {
  if (venueId == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mekan bilgisi bulunamadı')));
    return;
  }

  final url = AdminConfig.getAdminUrl(venueId);
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin panel açılamadı')));
    }
  }
}

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
                    onPressed: () {
                      // Safely navigate back - check if we can pop first
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        // If cannot pop (this is the only route), go to home
                        context.go('/');
                      }
                    },
                  ),
                  const Text(
                    'Profilim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B0E11),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to edit profile
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    label: const Text(
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
                                    context.push('/favorites?tab=favorites');
                                  },
                                ),
                                ProfileMenuItem(
                                  icon: Icons.people_alt,
                                  title: 'Takip Ettiklerim',
                                  isPrimary: true,
                                  onTap: () {
                                    context.push('/favorites?tab=following');
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

                          // Business Mode Buttons (if business account)
                          Consumer2<AuthProvider, BusinessProvider>(
                            builder: (context, authProvider, businessProvider, _) {
                              final userId = authProvider.currentUser?.id;

                              return FutureBuilder<bool>(
                                future: userId != null
                                    ? businessProvider.checkBusinessAccount(
                                        userId,
                                      )
                                    : Future.value(false),
                                builder: (context, snapshot) {
                                  final isBusinessAccount =
                                      snapshot.data ?? false;

                                  if (!isBusinessAccount) {
                                    return const SizedBox.shrink();
                                  }

                                  final isBusinessMode =
                                      businessProvider.isBusinessMode;
                                  final venue = businessProvider.businessVenue;

                                  return Column(
                                    children: [
                                      // Business Mode Indicator Card
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFE8B4BC),
                                              Color(0xFFD4A5A5),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFE8B4BC,
                                              ).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.business_center,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'İşletme Hesabı',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        isBusinessMode
                                                            ? 'İşletme Modunda'
                                                            : 'Normal Modda',
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Business Mode Buttons
                                            if (isBusinessMode) ...[
                                              // Admin Panel Button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _openAdminPanel(
                                                        context,
                                                        venue?.id,
                                                      ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        const Color(0xFFE8B4BC),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.dashboard,
                                                    size: 20,
                                                  ),
                                                  label: const Text(
                                                    'Yönetim Paneli',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              // Switch to Normal Mode Button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: OutlinedButton.icon(
                                                  onPressed: () async {
                                                    if (userId != null) {
                                                      await businessProvider
                                                          .switchMode(
                                                            BusinessMode.normal,
                                                            userId,
                                                          );
                                                      if (context.mounted) {
                                                        context.go('/');
                                                      }
                                                    }
                                                  },
                                                  style: OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.white,
                                                    side: const BorderSide(
                                                      color: Colors.white,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.person,
                                                    size: 20,
                                                  ),
                                                  label: const Text(
                                                    'Normal Hesaba Geç',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ] else ...[
                                              // Switch to Business Mode Button
                                              SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    if (userId != null) {
                                                      await businessProvider
                                                          .switchMode(
                                                            BusinessMode
                                                                .business,
                                                            userId,
                                                          );
                                                      if (context.mounted) {
                                                        context.go('/');
                                                      }
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.white,
                                                    foregroundColor:
                                                        const Color(0xFFE8B4BC),
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  icon: const Icon(
                                                    Icons.store,
                                                    size: 20,
                                                  ),
                                                  label: const Text(
                                                    'İşletme Moduna Geç',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                          // Logout Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Önce login'e yönlendir, sonra signOut
                                    context.go('/login');
                                    authProvider.signOut();
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
