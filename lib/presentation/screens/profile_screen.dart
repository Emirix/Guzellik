import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../providers/app_state_provider.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_stats.dart';
import '../widgets/profile/profile_menu_item.dart';
import '../widgets/common/business_bottom_nav.dart';
import '../widgets/common/guzellik_haritam_header.dart';
import '../../core/theme/app_colors.dart';
import '../../core/enums/business_mode.dart';
import '../../config/admin_config.dart';
import 'venue/venue_details_screen.dart';

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
class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Set bottom nav index to 3 (Profilim) if in business mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final businessProvider = context.read<BusinessProvider>();
      if (businessProvider.isBusinessMode && !widget.isEmbedded) {
        context.read<AppStateProvider>().setBottomNavIndex(3);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final bool showBusinessNav = businessProvider.isBusinessMode;
    final bool embedded = widget.isEmbedded;

    // If in business mode, show venue details as "Profile"
    if (showBusinessNav && businessProvider.businessVenue?.id != null) {
      return VenueDetailsScreen(
        venueId: businessProvider.businessVenue!.id,
        bottomNavigationBar: embedded ? null : const BusinessBottomNav(),
        hideDefaultBottomBar: embedded,
        showBackButton: false,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBFB),
      bottomNavigationBar: (showBusinessNav && !embedded)
          ? const BusinessBottomNav()
          : null,
      body: Column(
        children: [
          const GuzellikHaritamHeader(backgroundColor: Color(0xFFFDFBFB)),
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
                        onEditPressed: () {
                          // TODO: Navigate to edit avatar
                        },
                      );
                    },
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
                            border: Border.all(color: const Color(0xFFF3E8EA)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
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
                                  context.push('/my-reviews');
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
                                showDivider: false,
                                onTap: () {
                                  context.push('/favorites?tab=following');
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
                            border: Border.all(color: const Color(0xFFF3E8EA)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
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

                        // Business Account Conversion Button (for non-business users)
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

                                // Only show for non-business users
                                if (isBusinessAccount) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  children: [
                                    // Business Account Prompt Card
                                    InkWell(
                                      onTap: () {
                                        context.push('/business-onboarding');
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primary.withValues(
                                                alpha: 0.8,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.store,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'İşletme Hesabına Geç',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '1 yıl ücretsiz deneme ile başla',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              },
                            );
                          },
                        ),

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
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFE8B4BC,
                                            ).withValues(alpha: 0.3),
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
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                      CrossAxisAlignment.start,
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
                                                            .withValues(
                                                              alpha: 0.9,
                                                            ),
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
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: const Color(
                                                    0xFFE8B4BC,
                                                  ),
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
                                                    fontWeight: FontWeight.bold,
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
                                                  foregroundColor: Colors.white,
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
                                                    fontWeight: FontWeight.bold,
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
                                                          BusinessMode.business,
                                                          userId,
                                                        );
                                                    if (context.mounted) {
                                                      context.go('/');
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: const Color(
                                                    0xFFE8B4BC,
                                                  ),
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
                                                    fontWeight: FontWeight.bold,
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
                                onPressed: () async {
                                  // Reset business mode
                                  final businessProvider = context
                                      .read<BusinessProvider>();
                                  // Manually reset state to normal without requiring userId
                                  // This effectively does what switchMode(normal) does but cleaner for logout
                                  await businessProvider.clearSavedMode();
                                  // We can't access private _currentMode but we can call init or reload?
                                  // Or better, just switchMode if we have userId, or rely on clearSavedMode + provider re-init?
                                  // Let's use switchMode if user is logged in, otherwise just continue.

                                  final userId = authProvider.currentUser?.id;
                                  if (userId != null &&
                                      businessProvider.isBusinessMode) {
                                    await businessProvider.switchMode(
                                      BusinessMode.normal,
                                      userId,
                                    );
                                  }

                                  // Sign out
                                  await authProvider.signOut();

                                  if (context.mounted) {
                                    // Navigate to home (guest mode)
                                    context.go('/');
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: BorderSide(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.2,
                                    ),
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
    );
  }
}
