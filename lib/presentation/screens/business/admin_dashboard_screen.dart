import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/business_bottom_nav.dart';
import '../../widgets/common/guzellik_haritam_header.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../../data/models/business_subscription.dart';
import '../../../data/models/venue.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final businessProvider = context.read<BusinessProvider>();
    final userId = context.read<AuthProvider>().currentUser?.id;

    if (userId != null) {
      await businessProvider.loadBusinessData(userId);
      if (mounted) {
        await context.read<SubscriptionProvider>().loadSubscription(userId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();
    final venue = businessProvider.businessVenue;
    final subscription = subscriptionProvider.subscription;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      bottomNavigationBar: const BusinessBottomNav(),
      body: Column(
        children: [
          const GuzellikHaritamHeader(backgroundColor: Color(0xFFFCFCFC)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCoverAndProfile(context, venue, subscription),
                  const SizedBox(height: 16),
                  _buildManagementMenu(context, venue, subscription),
                  const SizedBox(height: 24),
                  _buildSaveButton(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverAndProfile(
    BuildContext context,
    Venue? venue,
    BusinessSubscription? subscription,
  ) {
    final coverUrl =
        venue?.imageUrl ??
        (venue?.heroImages.isNotEmpty == true ? venue!.heroImages.first : null);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Photo
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            image: coverUrl != null
                ? DecorationImage(
                    image: NetworkImage(coverUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
            ),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/business/admin/cover-photo'),
                icon: const Icon(Icons.photo_camera, size: 18),
                label: const Text(
                  'Kapağı Değiştir',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  foregroundColor: const Color(0xFF1B0E11),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Profile Details (Clear Rectangular Card)
        Padding(
          padding: const EdgeInsets.only(top: 210),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Venue Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        venue?.name ?? 'İşletme Adı',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B0E11),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (venue?.isVerified == true) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 22),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                // Location (District, Province)
                Text(
                  (venue?.districtName != null && venue?.provinceName != null)
                      ? '${venue?.districtName}, ${venue?.provinceName}'
                      : (venue?.address ?? 'Konum Bilgisi'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                // Premium Badge or Subscription Status
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars,
                        color: Color(0xFFD4AF37),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subscription?.displayName.toUpperCase() ??
                            'YÜKLENİYOR...',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                if (subscription != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Credits Info
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${subscription.creditsBalance} Kredi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Expiry Info
                      Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subscription.daysRemaining > 0
                            ? '${subscription.daysRemaining} Gün Kaldı'
                            : 'Süresi Doldu',
                        style: TextStyle(
                          fontSize: 12,
                          color: subscription.daysRemaining < 5
                              ? Colors.red
                              : Colors.grey[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementMenu(
    BuildContext context,
    Venue? venue,
    BusinessSubscription? subscription,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yönetim Menüsü',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(height: 16),

          _buildListItem(
            context,
            icon: Icons.workspace_premium,
            title: 'Üyelik ve Mağaza',
            subtitle: 'Paket Yükselt ve Kredi Satın Al',
            onTap: () => context.push('/business/store'),
          ),

          _buildListItem(
            context,
            icon: Icons.storefront,
            title: 'Temel Bilgiler',
            subtitle: 'İsim, Tanıtım Yazısı ve İletişim',
            onTap: () => context.push('/business/admin/basic-info'),
          ),

          _buildListItem(
            context,
            icon: Icons.schedule,
            title: 'Çalışma Saatleri',
            subtitle: _formatWorkingHoursSummary(venue),
            statusLabel: _isCurrentlyOpen(venue) ? 'AÇIK' : 'KAPALI',
            onTap: () => context.push('/business/admin/working-hours'),
          ),

          _buildListItem(
            context,
            icon: Icons.location_on,
            title: 'Konum ve Adres',
            subtitle: venue?.address ?? 'Harita konumu ve açık adres',
            onTap: () => context.push('/business/admin/location'),
          ),
          _buildListItem(
            context,
            icon: Icons.checklist_rtl,
            title: 'İşletme Özellikleri',
            subtitle: 'Wi-Fi, Otopark, Ödeme Seçenekleri vb.',
            onTap: () => context.push('/business/admin/features'),
          ),

          _buildListItem(
            context,
            icon: Icons.spa,
            title: 'Hizmet Yönetimi',
            subtitle: 'Kategoriler, Fiyat Listesi, Paketler',
            onTap: () => context.push('/business/admin/services'),
          ),

          _buildListItem(
            context,
            icon: Icons.groups,
            title: 'Uzman Ekip',
            subtitle: venue != null
                ? '${venue.expertTeam.length} Uzman'
                : 'Ekip üyelerinizi yönetin',
            onTap: () => context.push('/business/admin/specialists'),
          ),

          _buildListItem(
            context,
            icon: Icons.person_search,
            title: 'Müşterilerim',
            subtitle: 'Müşteri listenizi ve bilgileri yönetin',
            onTap: () => context.push('/business/admin/customers'),
          ),

          _buildListItem(
            context,
            icon: Icons.compare_arrows_sharp,

            title: 'Kampanyalar',
            subtitle: 'Kampanyalarınızı yönetin',
            onTap: () => context.push('/business/admin/campaigns'),
          ),
          _buildListItem(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Yorum Yönetimi',
            subtitle: 'Müşteri yorumlarını onayla ve yanıtla',
            onTap: () => context.push('/business/admin/reviews'),
          ),

          _buildListItem(
            context,
            icon: Icons.collections,
            title: 'Galeri & Medya',
            subtitle: 'Salon Görselleri, Video Tanıtımı',
            onTap: () => context.push('/business/admin/gallery'),
          ),
          _buildListItem(
            context,
            icon: Icons.add_photo_alternate,
            title: 'Kapak Fotoğrafı',
            subtitle: 'Profil Kapak Görselini Belirle',
            onTap: () => context.push('/business/admin/cover-photo'),
          ),
          _buildListItem(
            context,
            icon: Icons.help_outline,
            title: 'Sıkça Sorulan Sorular',
            subtitle: 'Müşterileriniz için SSS yönetimi',
            onTap: () => context.push('/business/admin/faq'),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? statusLabel,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B0E11),
                            ),
                          ),
                          if (statusLabel != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Değişiklikler kaydedildi')),
            );
          },
          icon: const Icon(Icons.save, size: 20),
          label: const Text(
            'DEĞİŞİKLİKLERİ KAYDET',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  String _formatWorkingHoursSummary(Venue? venue) {
    if (venue == null || venue.workingHours.isEmpty) {
      return 'Haftalık çalışma planınız';
    }

    try {
      final hours = venue.workingHours;
      final monday = hours['monday'];

      if (monday is Map<String, dynamic> && monday['open'] == true) {
        final start = monday['start']?.toString() ?? '09:00';
        final end = monday['end']?.toString() ?? '20:00';
        return 'Pzt - Cmt: $start - $end';
      }
    } catch (e) {
      debugPrint('Error formatting working hours: $e');
    }

    return 'Çalışma saatlerini düzenleyin';
  }

  bool _isCurrentlyOpen(Venue? venue) {
    if (venue == null || venue.workingHours.isEmpty) return false;

    try {
      final now = DateTime.now();
      final dayNames = [
        'sunday',
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ];
      final currentDay = dayNames[now.weekday % 7];
      final dayHours = venue.workingHours[currentDay];

      if (dayHours is Map<String, dynamic> && dayHours['open'] == true) {
        final start = dayHours['start']?.toString();
        final end = dayHours['end']?.toString();

        if (start != null && end != null) {
          final startParts = start.split(':');
          final endParts = end.split(':');

          if (startParts.length == 2 && endParts.length == 2) {
            final startHour = int.parse(startParts[0]);
            final startMinute = int.parse(startParts[1]);
            final endHour = int.parse(endParts[0]);
            final endMinute = int.parse(endParts[1]);

            final startTime = TimeOfDay(hour: startHour, minute: startMinute);
            final endTime = TimeOfDay(hour: endHour, minute: endMinute);
            final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

            final currentMinutes = currentTime.hour * 60 + currentTime.minute;
            final startMinutes = startTime.hour * 60 + startTime.minute;
            final endMinutes = endTime.hour * 60 + endTime.minute;

            return currentMinutes >= startMinutes &&
                currentMinutes <= endMinutes;
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking if open: $e');
    }

    return false;
  }
}
