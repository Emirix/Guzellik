import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/campaign_repository.dart';

/// Bottom sheet for campaign sort options
class CampaignSortOptions extends StatelessWidget {
  final CampaignSortType currentSort;
  final Function(CampaignSortType) onSortSelected;

  const CampaignSortOptions({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required CampaignSortType currentSort,
    required Function(CampaignSortType) onSortSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CampaignSortOptions(
        currentSort: currentSort,
        onSortSelected: onSortSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                const Icon(Icons.sort, color: AppColors.gray800, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Sıralama',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),

          // Sort options
          _buildSortOption(
            context,
            icon: Icons.calendar_today,
            title: 'Tarihe Göre',
            subtitle: 'En yeni kampanyalar önce',
            sortType: CampaignSortType.date,
          ),
          _buildSortOption(
            context,
            icon: Icons.local_offer,
            title: 'İndirim Oranına Göre',
            subtitle: 'En yüksek indirimler önce',
            sortType: CampaignSortType.discount,
          ),
          _buildSortOption(
            context,
            icon: Icons.access_time,
            title: 'Yakında Sona Erecekler',
            subtitle: 'Süresi dolmak üzere olanlar önce',
            sortType: CampaignSortType.expiringSoon,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required CampaignSortType sortType,
  }) {
    final isSelected = currentSort == sortType;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onSortSelected(sortType);
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(0.05)
                : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.gray600,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.7)
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
