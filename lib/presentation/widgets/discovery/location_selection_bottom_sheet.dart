import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/location_onboarding_provider.dart';
import 'map_location_picker.dart';

class LocationSelectionBottomSheet extends StatefulWidget {
  final bool isOnboarding;

  const LocationSelectionBottomSheet({super.key, this.isOnboarding = false});

  @override
  State<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends State<LocationSelectionBottomSheet> {
  bool _isLoadingCurrentLocation = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isOnboarding ? 'Konumunuzu Seçin' : 'Konum Seçin',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                if (!widget.isOnboarding)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.gray700,
                  ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.gray200),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current Location Button
                _buildCurrentLocationButton(context),
                const SizedBox(height: 16),

                // Divider with "veya" text
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.gray300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.gray300)),
                  ],
                ),
                const SizedBox(height: 16),

                // Map Selection Button
                _buildMapSelectionButton(context),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isLoadingCurrentLocation
          ? null
          : () async {
              setState(() {
                _isLoadingCurrentLocation = true;
              });

              String locationName = '';

              try {
                if (widget.isOnboarding) {
                  final provider = context.read<LocationOnboardingProvider>();
                  await provider.requestGPSLocation();
                  locationName =
                      provider.selectedLocation?.districtName ?? 'Mevcut konum';
                  if (provider.selectedLocation?.provinceName != null) {
                    locationName =
                        '$locationName, ${provider.selectedLocation!.provinceName}';
                  }
                } else {
                  final provider = context.read<DiscoveryProvider>();
                  await provider.updateLocation();
                  locationName = provider.currentLocationName;
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Konumunuz: $locationName olarak güncellendi',
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  setState(() {
                    _isLoadingCurrentLocation = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Konum alınamadı. Lütfen haritadan seçin.',
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              }
            },
      icon: _isLoadingCurrentLocation
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            )
          : const Icon(Icons.my_location, size: 20),
      label: Text(
        _isLoadingCurrentLocation
            ? 'Konum alınıyor...'
            : 'Mevcut Konumumu Kullan',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
        disabledForegroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildMapSelectionButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapLocationPicker(
              onLocationSelected: (city, district) {
                if (widget.isOnboarding) {
                  context
                      .read<LocationOnboardingProvider>()
                      .completeManualSelection(
                        provinceName: city,
                        districtName: district,
                      );
                } else {
                  context.read<DiscoveryProvider>().updateManualLocation(
                    city: city,
                    district: district,
                  );
                }
                Navigator.pop(context);

                // Show snackbar for map selection
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Konumunuz: $district, $city olarak güncellendi',
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
            ),
          ),
        );
      },
      icon: const Icon(Icons.map_outlined, size: 20),
      label: const Text('Haritadan Konum Seç'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
