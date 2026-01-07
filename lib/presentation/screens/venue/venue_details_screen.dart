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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF25D366),
                ),
              ),
              title: const Text(
                'WhatsApp ile Yaz',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Hızlı yanıt için WhatsApp hattımız'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://wa.me/905000000000');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.call_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Ara',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Doğrudan bilgi almak için bizi arayın'),
              onTap: () {
                Navigator.pop(context);
                _launchUrl('tel:+905000000000');
              },
            ),
            const SizedBox(height: 16),
          ],
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
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.venue == null) {
            return Center(child: Text('Hata: ${provider.error}'));
          }

          final venue = provider.venue;
          if (venue == null) {
            return const Center(child: Text('Mekan bulunamadı'));
          }

          return Stack(
            children: [
              // Main Content
              NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    VenueHeroV2(venue: venue),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.backgroundLight,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
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
