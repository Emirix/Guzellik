import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/venue_details_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/venue/v2/venue_hero_v2.dart';
import '../../widgets/venue/v2/venue_overview_v2.dart';
import '../../widgets/venue/venue_tab_switcher.dart';
import '../../widgets/venue/components/booking_bottom_bar.dart';
import '../../widgets/venue/tabs/services_tab.dart';
import '../../widgets/venue/tabs/experts_tab.dart';
import '../../widgets/venue/tabs/reviews_tab.dart';
import '../../widgets/common/ad_banner_widget.dart';
import '../../../data/models/venue.dart';

class VenueDetailsScreen extends StatefulWidget {
  final String venueId;
  final Venue? initialVenue;

  const VenueDetailsScreen({
    super.key,
    required this.venueId,
    this.initialVenue,
  });

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VenueDetailsProvider>().loadVenueDetails(
        widget.venueId,
        initialVenue: widget.initialVenue,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bağlantı açılamadı: $url')));
      }
    }
  }

  void _showContactOptions(BuildContext context, Venue venue) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'İletişime Geç',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    padding: EdgeInsets.zero,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // WhatsApp Option
            _buildContactOption(
              icon: Icons.chat_bubble_outline,
              iconColor: const Color(0xFF25D366),
              title: 'WhatsApp ile Yaz',
              subtitle: 'Hızlı yanıt için WhatsApp hattımız',
              onTap: () {
                Navigator.pop(context);
                final phone =
                    venue.socialLinks['phone']?.toString() ??
                    venue.socialLinks['whatsapp']?.toString() ??
                    "905000000000";
                _launchUrl('https://wa.me/$phone');
              },
            ),
            const SizedBox(height: 12),
            // Call Option
            _buildContactOption(
              icon: Icons.call_outlined,
              iconColor: AppColors.primary,
              title: 'Ara',
              subtitle: 'Doğrudan bilgi almak için bizi arayın',
              onTap: () {
                Navigator.pop(context);
                final phone =
                    venue.socialLinks['phone']?.toString() ??
                    venue.socialLinks['whatsapp']?.toString() ??
                    "905000000000";
                _launchUrl('tel:+$phone');
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.gray400),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Consumer<VenueDetailsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.venue == null) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.error != null && provider.venue == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => provider.loadVenueDetails(widget.venueId),
                    child: Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final venue = provider.venue;
          if (venue == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 48,
                    color: AppColors.gray400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mekan bulunamadı',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray700,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Main Content
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    VenueHeroV2(venue: venue),
                    // Rounded top overlay that goes over the hero image
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    VenueTabSwitcher(tabController: _tabController),
                  ];
                },
                body: Container(
                  color: AppColors.backgroundLight,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      VenueOverviewV2(
                        venue: venue,
                        reviews: provider.reviews,
                        onSeeAll: () => _tabController.animateTo(2),
                      ),
                      ServicesTab(venueId: venue.id),
                      venue.id.isNotEmpty
                          ? ReviewsTab(venueId: venue.id)
                          : const SizedBox(),
                      ExpertsTab(venue: venue),
                    ],
                  ),
                ),
              ),

              // Ad Banner above bottom bar
              const Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: AdBannerWidget(),
              ),

              // Fixed Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BookingBottomBar(
                  onBookingTap: () => _showContactOptions(context, venue),
                  rating: venue.rating,
                  reviewCount: venue.ratingCount,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
