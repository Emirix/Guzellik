import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/venue_details_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/venue/venue_hero.dart';
import '../../widgets/venue/venue_tab_switcher.dart';
import '../../widgets/venue/venue_quick_actions.dart';
import '../../widgets/venue/components/booking_bottom_bar.dart';
import '../../widgets/venue/tabs/services_tab.dart';
import '../../widgets/venue/tabs/about_tab.dart';
import '../../widgets/venue/tabs/experts_tab.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    VenueHero(venue: venue),
                    // Quick Actions Section
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          VenueQuickActions(venue: venue),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                    VenueTabSwitcher(tabController: _tabController),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    ServicesTab(venueId: venue.id),
                    AboutTab(venue: venue),
                    const Center(child: Text('Yorumlar Çok Yakında')),
                    ExpertsTab(venue: venue),
                  ],
                ),
              ),

              // Fixed Bottom Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BookingBottomBar(
                  totalPrice: 750, // TODO: Calculate from selected services
                  onBookingTap: () {
                    // TODO: Navigate to booking screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Randevu oluşturma ekranı yakında eklenecek',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
