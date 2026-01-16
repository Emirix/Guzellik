import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/venue_details_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/service.dart';
import '../components/service_card.dart';

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
          return const Center(child: CircularProgressIndicator());
        }

        // Apply filters and search
        List<Service> filteredServices = provider.services.where((s) {
          final query = _searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(query) ||
              (s.category?.toLowerCase() ?? '').contains(query);
        }).toList();

        if (filteredServices.isEmpty && provider.services.isNotEmpty) {
          return _buildNoResults();
        }

        if (provider.services.isEmpty) {
          return _buildEmptyState();
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  String category = grouped.keys.elementAt(index);
                  List<Service> services = grouped[category]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, top: 20),
                        child: Text(category, style: AppTextStyles.heading3),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Hizmet ara...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.gray400,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.gray400),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: Center(
            child: Text(
              'Aramanızla eşleşen hizmet bulunamadı.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'Bu mekan için henüz hizmet eklenmemiş.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
      ),
    );
  }
}
