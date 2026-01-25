import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/enums/business_mode.dart';
import '../../../config/admin_config.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/business_provider.dart';

import '../../providers/subscription_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/business_bottom_nav.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _loadSubscription();
      context.read<AppStateProvider>().setBottomNavIndex(2);
    });
  }

  Future<void> _loadSubscription() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      final provider = context.read<SubscriptionProvider>();
      await provider.loadSubscription(userId);
      await provider.loadAvailableProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Abonelik Planı',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B0E11),
            size: 18,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: Consumer2<SubscriptionProvider, BusinessProvider>(
        builder: (context, subscriptionProvider, businessProvider, _) {
          if (subscriptionProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final subscription = subscriptionProvider.subscription;
          final venue = businessProvider.businessVenue;

          return RefreshIndicator(
            onRefresh: _loadSubscription,
            color: AppColors.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subscription Card
                        _buildSubscriptionCard(subscription),
                        const SizedBox(height: 24),

                        // Features Section
                        _buildFeaturesSection(subscription),
                        const SizedBox(height: 24),

                        // Purchase Section
                        if (subscription == null || !subscription.isActive)
                          _buildPurchaseSection(subscriptionProvider),
                        const SizedBox(height: 24),

                        // Action Buttons
                        _buildActionButtons(venue?.id),
                        const SizedBox(height: 24),

                        // Quick Stats
                        _buildQuickStats(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(dynamic subscription) {
    if (subscription == null) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Abonelik Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B0E11),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lütfen destek ekibiyle iletişime geçin.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final int days = subscription.daysRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge and Shield Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEEF2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'AKTİF ABONELİK',
                  style: TextStyle(
                    color: Color(0xFFEE2B5B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFFFDC5D3),
                size: 26,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Subscription Title
          Text(
            subscription.displayName,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B0E11),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Days Remaining
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: Color(0xFF903247),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$days Gün Kaldı',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF903247),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (days % 30) / 30, // Simplified for demonstration
              minHeight: 8,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFEE2B5B),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Renewal Date
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Yenileme Tarihi: ${subscription.expiresAt != null ? _formatDate(subscription.expiresAt!) : '-'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(dynamic subscription) {
    final features = [
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Sınırsız Hizmet',
        'desc': 'Dilediğiniz kadar hizmet ekleyin',
      },
      {
        'icon': Icons.people_outline_rounded,
        'title': 'Uzman Ekip',
        'desc': 'Ekip üyelerinizi sınırsız yönetin',
      },
      {
        'icon': Icons.campaign_outlined,
        'title': 'Sınırsız Kampanya',
        'desc': 'Aylık kampanya limiti yok',
      },
      {
        'icon': Icons.notifications_active_outlined,
        'title': 'Sınırsız Bildirim',
        'desc': 'Günlük bildirim limiti yok',
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'Gelişmiş Analitik',
        'desc': 'Kurumsal seviye raporlar',
      },
      {
        'icon': Icons.support_agent_rounded,
        'title': 'Özel Destek',
        'desc': '7/24 hızlı yardım',
      },
      {
        'icon': Icons.star_outlined,
        'title': 'Öne Çıkan Listing',
        'desc': 'Özel vitrin görünürlüğü',
      },
      {
        'icon': Icons.api_outlined,
        'title': 'API Erişimi',
        'desc': 'Tüm API özellikleri açık',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'ÖZELLİKLER',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: features.asMap().entries.map((entry) {
              final isLast = entry.key == features.length - 1;
              final feature = entry.value;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          feature['icon'] as IconData,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature['title'] as String,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B0E11),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              feature['desc'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[400],
                        size: 20,
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey[100]),
                    const SizedBox(height: 16),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPurchaseSection(SubscriptionProvider provider) {
    if (provider.availableProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'PLANINI SEÇ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...provider.availableProducts.map((product) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: product.id.contains('premium')
                    ? AppColors.primary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B0E11),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        final venueId = context
                            .read<BusinessProvider>()
                            .businessVenue
                            ?.id;
                        if (venueId != null) {
                          provider.buySubscription(product, venueId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Seç',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(String? venueId) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _openAdminPanel(context, venueId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'Yönetim Paneline Git',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _switchToNormalAccount(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6B7280),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline_rounded, size: 20),
                SizedBox(width: 10),
                Text(
                  'Normal Hesaba Geç',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {
        'label': 'Toplam Görüntülenme',
        'value': '1.2K',
        'icon': Icons.visibility_outlined,
      },
      {
        'label': 'Favori Eklenme',
        'value': '89',
        'icon': Icons.favorite_border_rounded,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'BU AY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1.5,
            ),
          ),
        ),
        Row(
          children: stats.map((stat) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: stat == stats.first ? 12 : 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      stat['value'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B0E11),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Admin panel açılamadı')));
      }
    }
  }

  Future<void> _switchToNormalAccount(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      final businessProvider = context.read<BusinessProvider>();
      await businessProvider.switchMode(BusinessMode.normal, userId);
      if (mounted) context.go('/');
    }
  }
}
