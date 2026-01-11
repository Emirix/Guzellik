import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/business_bottom_nav.dart';
import '../../providers/business_provider.dart';
import '../../../data/models/venue.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final venue = businessProvider.businessVenue;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
            ),
          ),
        ),
        title: const Text(
          'İşletme Profili',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B0E11),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil güncellendi')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const BusinessBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCoverAndProfile(context, venue),
            const SizedBox(height: 16),
            _buildManagementMenu(context, venue),
            const SizedBox(height: 24),
            _buildSaveButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverAndProfile(BuildContext context, Venue? venue) {
    final coverUrl = venue?.heroImages.isNotEmpty == true
        ? venue!.heroImages.first
        : null;
    final logoUrl = venue?.imageUrl;

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
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2)),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => context.push('/business/admin/gallery'),
                icon: const Icon(Icons.photo_camera, size: 18),
                label: const Text(
                  'Kapağı Değiştir',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
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

        // Profile Details (Positioned relative to cover)
        Padding(
          padding: const EdgeInsets.only(top: 180),
          child: Column(
            children: [
              // Logo
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        image: logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(logoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: logoUrl == null
                          ? const Icon(
                              Icons.store,
                              size: 50,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Venue Name & Info
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        venue?.name ?? 'İşletme Adı',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1B0E11),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue?.address ?? 'Konum Bilgisi',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars, color: Color(0xFFD4AF37), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'PREMİUM İŞLETME',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagementMenu(BuildContext context, Venue? venue) {
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
            icon: Icons.compare_arrows_sharp,
            title: 'Kampanyalar',
            subtitle: 'Kampanyalarınızı yönetin',
            onTap: () => context.push('/business/admin/campaigns'),
          ),

          _buildListItem(
            context,
            icon: Icons.collections,
            title: 'Galeri & Medya',
            subtitle: 'Salon Görselleri, Video Tanıtımı',
            onTap: () => context.push('/business/admin/gallery'),
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
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
                    color: AppColors.primary.withOpacity(0.1),
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
                                color: Colors.green.withOpacity(0.1),
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
            shadowColor: AppColors.primary.withOpacity(0.4),
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

    final hours = venue.workingHours;
    final monday = hours['monday'] as Map<String, dynamic>?;

    if (monday != null && monday['open'] == true) {
      return 'Pzt - Cmt: ${monday['start']} - ${monday['end']}';
    }

    return 'Çalışma saatlerini düzenleyin';
  }

  bool _isCurrentlyOpen(Venue? venue) {
    if (venue == null || venue.workingHours.isEmpty) return false;
    // Basit bir kontrol, geliştirilebilir
    return true;
  }
}
