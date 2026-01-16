import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../providers/admin_features_provider.dart';
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
      context.read<AdminFeaturesProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            return const Center(child: CircularProgressIndicator());
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
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
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
          color: isSelected ? AppColors.primary : AppColors.gray200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: (_) => provider.toggleFeature(feature.id),
        title: Row(
          children: [
            Icon(
              _getIconData(feature.icon),
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.gray600,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.gray900 : AppColors.gray700,
                ),
              ),
            ),
          ],
        ),
        subtitle: feature.description != null
            ? Padding(
                padding: const EdgeInsets.only(left: 32, top: 4),
                child: Text(
                  feature.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              )
            : null,
        activeColor: AppColors.primary,
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    final iconMap = {
      'science': Icons.science,
      'sanitizer': Icons.sanitizer,
      'verified': Icons.verified,
      'event_available': Icons.event_available,
      'card_giftcard': Icons.card_giftcard,
      'home': Icons.home,
      'chat': Icons.chat,
      'ac_unit': Icons.ac_unit,
      'local_cafe': Icons.local_cafe,
      'child_care': Icons.child_care,
      'menu_book': Icons.menu_book,
      'music_note': Icons.music_note,
      'wifi': Icons.wifi,
      'credit_card': Icons.credit_card,
      'payments': Icons.payments,
      'contactless': Icons.contactless,
      'money': Icons.money,
      'local_parking': Icons.local_parking,
      'directions_bus': Icons.directions_bus,
      'local_taxi': Icons.local_taxi,
      'accessible': Icons.accessible,
      'chat_bubble': Icons.chat_bubble,
      'photo_camera': Icons.photo_camera,
    };

    return iconMap[iconName] ?? Icons.check_circle_outline;
  }
}
