import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../providers/campaign_provider.dart';
import '../widgets/campaigns/campaign_card.dart';
import '../widgets/campaigns/campaign_detail_bottom_sheet.dart';
import '../widgets/campaigns/campaign_sort_options.dart';

/// Campaigns screen showing all active campaigns
class CampaignsScreen extends StatefulWidget {
  final String? venueId; // Optional: filter by venue

  const CampaignsScreen({super.key, this.venueId});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch campaigns on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CampaignProvider>().fetchCampaigns();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kampanyalar'),
        actions: [
          // Sort button
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              final provider = context.read<CampaignProvider>();
              CampaignSortOptions.show(
                context,
                currentSort: provider.sortType,
                onSortSelected: (sortType) {
                  provider.setSortType(sortType);
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CampaignProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading && !provider.hasCampaigns) {
            return _buildLoadingState();
          }

          // Error state
          if (provider.error != null && !provider.hasCampaigns) {
            return _buildErrorState(provider);
          }

          // Empty state
          if (!provider.hasCampaigns) {
            return _buildEmptyState();
          }

          // Success state with campaigns
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.campaigns.length,
              itemBuilder: (context, index) {
                final campaign = provider.campaigns[index];
                return CampaignCard(
                  campaign: campaign,
                  onTap: () {
                    CampaignDetailBottomSheet.show(context, campaign);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Kampanyalar yükleniyor...',
            style: TextStyle(fontSize: 14, color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CampaignProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Kampanyalar yüklenirken bir hata oluştu',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.fetchCampaigns(refresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz Kampanya Yok',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Şu anda aktif kampanya bulunmuyor.\nYeni kampanyalar için takipte kalın!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
