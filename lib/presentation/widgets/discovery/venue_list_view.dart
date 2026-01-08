import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../venue/venue_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_utils.dart';

class VenueListView extends StatefulWidget {
  const VenueListView({super.key});

  @override
  State<VenueListView> createState() => _VenueListViewState();
}

class _VenueListViewState extends State<VenueListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 100, bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Categories Chips
              _buildCategories(context),

              // 2. Featured Section
              _buildSectionHeader('Öne Çıkanlar', onSeeAll: () {}),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: provider.venues.length,
                  itemBuilder: (context, index) {
                    return VenueCard(
                      venue: provider.venues[index],
                      type: VenueCardType.vertical,
                    );
                  },
                ),
              ),

              // 3. Category Browser
              _buildSectionHeader('Kategorilere Göz At'),
              _buildCategoryBrowser(context),

              // 4. Nearby Venues
              _buildSectionHeader('Yakınınızdaki Salonlar'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.venues.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: VenueCard(
                        venue: provider.venues[index],
                        type: VenueCardType.horizontal,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, _) {
        final categoryNames = [
          'Tümü',
          ...provider.categories.map((c) => c.name),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              itemCount: categoryNames.length,
              itemBuilder: (context, index) {
                final category = categoryNames[index];
                final isSelected = category == 'Tümü'
                    ? provider.filter.categories.isEmpty
                    : provider.filter.categories.contains(category);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      if (category == 'Tümü') {
                        provider.updateFilter(
                          provider.filter.copyWith(categories: []),
                        );
                      } else {
                        provider.updateFilter(
                          provider.filter.copyWith(categories: [category]),
                        );
                      }
                    },
                    child: Chip(
                      label: Text(category),
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.gray900,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.gray100,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Tümünü gör',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBrowser(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, _) {
        final categories = provider.categories;

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gray100, width: 2),
                      ),
                      child: Icon(
                        IconUtils.getCategoryIcon(category.icon),
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
