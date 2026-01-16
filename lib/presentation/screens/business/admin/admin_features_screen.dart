import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../providers/admin_features_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../data/repositories/venue_features_repository.dart';
import '../../../../data/models/venue_feature.dart';

class AdminFeaturesScreen extends StatefulWidget {
  const AdminFeaturesScreen({super.key});

  @override
  State<AdminFeaturesScreen> createState() => _AdminFeaturesScreenState();
}

class _AdminFeaturesScreenState extends State<AdminFeaturesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<AdminFeaturesProvider>().initialize();
      } catch (_) {
        // Provider will be initialized locally in build if not found here
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if provider exists in context (e.g. provided by router)
    try {
      context.read<AdminFeaturesProvider>();
      return _buildScaffold(context);
    } catch (_) {
      // If not found, provide it locally using venueId from BusinessProvider
      final businessProvider = context.read<BusinessProvider>();
      final venueId = businessProvider.businessVenue?.id ?? '';

      return ChangeNotifierProvider(
        create: (context) => AdminFeaturesProvider(
          repository: VenueFeaturesRepository(),
          venueId: venueId,
        )..initialize(),
        child: Builder(builder: (context) => _buildScaffold(context)),
      );
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İşletme Özellikleri'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        actions: [
          Consumer<AdminFeaturesProvider>(
            builder: (context, provider, _) {
              return TextButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        final success = await provider.saveFeatures();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Özellikler kaydedildi'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                provider.error ?? 'Bir hata oluştu',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              );
            },
          ),
        ],
      ),
      body: Consumer<AdminFeaturesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allFeatures.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.error != null && provider.allFeatures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Bir hata oluştu', style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.initialize(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final featuresByCategory = provider.featuresByCategory;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'İşletmenizin sahip olduğu özellikleri seçin. Seçtiğiniz özellikler profilinizde görünecektir.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Selected count
              Text(
                '${provider.selectedFeatureIds.length} özellik seçildi',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Features by category
              ...featuresByCategory.entries.map((entry) {
                final category = entry.key;
                final features = entry.value;
                final categoryName = features.first.getCategoryDisplayName();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        categoryName,
                        style: AppTextStyles.heading4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...features.map((feature) {
                      return _buildFeatureItem(feature, provider);
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureItem(
    VenueFeature feature,
    AdminFeaturesProvider provider,
  ) {
    final isSelected = provider.isFeatureSelected(feature.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.gray100,
          width: 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: SwitchListTile(
        value: isSelected,
        onChanged: (_) => provider.toggleFeature(feature.id),
        title: Text(
          feature.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.gray900 : AppColors.gray700,
          ),
        ),
        subtitle: feature.description != null
            ? Text(
                feature.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray500,
                ),
              )
            : null,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
