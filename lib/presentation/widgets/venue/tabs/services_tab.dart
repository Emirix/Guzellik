import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/service.dart';
import '../components/service_card.dart';
import '../../common/empty_state.dart';

class ServicesTab extends StatefulWidget {
  final String venueId;

  const ServicesTab({super.key, required this.venueId});

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VenueDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.services.isEmpty) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (provider.error != null && provider.services.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Hata Oluştu',
              message: 'Hizmetler yüklenirken bir sorun oluştu.',
              actionLabel: 'Tekrar Dene',
              onAction: () => provider.loadVenueDetails(widget.venueId),
            ),
          );
        }

        // Apply filters and search
        List<Service> filteredServices = provider.services.where((s) {
          final query = _searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(query) ||
              (s.category?.toLowerCase() ?? '').contains(query);
        }).toList();

        if (provider.services.isEmpty) {
          return Center(
            child: EmptyState(
              icon: Icons.spa_outlined,
              title: 'Hizmet Bulunamadı',
              message: 'Bu mekan için henüz eklenmiş bir hizmet bulunmuyor.',
            ),
          );
        }

        if (filteredServices.isEmpty) {
          return Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: Center(
                  child: EmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'Sonuç Bulunamadı',
                    message: 'Aramanızla eşleşen bir hizmet bulamadık.',
                    actionLabel: 'Aramayı Temizle',
                    onAction: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
                ),
              ),
            ],
          );
        }

        // Group by category
        Map<String, List<Service>> grouped = {};
        for (var service in filteredServices) {
          final category = service.category ?? 'Genel';
          grouped.putIfAbsent(category, () => []).add(service);
        }

        return Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  String category = grouped.keys.elementAt(index);
                  List<Service> services = grouped[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 24),
                        child: Text(
                          category,
                          style: AppTextStyles.heading4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.gray900,
                          ),
                        ),
                      ),
                      ...services.map((s) => ServiceCard(service: s)),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          textAlignVertical: TextAlignVertical.center,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Hizmetlerde ara...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.primary,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.gray400,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }
}
