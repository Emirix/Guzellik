import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/discovery_provider.dart';
import '../../providers/location_onboarding_provider.dart';
import '../../widgets/common/searchable_location_dropdown.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/models/province.dart';
import '../../../data/models/district.dart';

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
  final LocationRepository _locationRepository = LocationRepository();

  // Manual selection state
  List<Province> _provinces = [];
  List<District> _districts = [];
  Province? _selectedProvince;
  District? _selectedDistrict;
  bool _isLoadingProvinces = false;
  bool _isLoadingDistricts = false;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() => _isLoadingProvinces = true);
    try {
      final provinces = await _locationRepository.fetchProvinces();
      if (mounted) {
        setState(() {
          _provinces = provinces;
          _isLoadingProvinces = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProvinces = false);
        // Silently fail or show retry in dropdown
      }
    }
  }

  Future<void> _loadDistricts(Province province) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrict = null;
    });

    try {
      final districts = await _locationRepository.fetchDistrictsByProvince(
        province.id,
      );
      if (mounted) {
        setState(() {
          _districts = districts;
          _isLoadingDistricts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

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
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Location Button
                  _buildCurrentLocationButton(context),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.gray200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VEYA',
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.gray200)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Province Dropdown
                  SearchableLocationDropdown<Province>(
                    label: 'İl',
                    hint: _isLoadingProvinces ? 'Yükleniyor...' : 'İl Seçin',
                    value: _selectedProvince,
                    items: _provinces
                        .map(
                          (p) =>
                              SearchableDropdownItem(value: p, label: p.name),
                        )
                        .toList(),
                    enabled: !_isLoadingProvinces && _provinces.isNotEmpty,
                    onChanged: (province) {
                      if (province != null) {
                        setState(() => _selectedProvince = province);
                        _loadDistricts(province);
                      }
                    },
                    prefixIcon: Icons.map,
                  ),

                  const SizedBox(height: 16),

                  // District Dropdown
                  SearchableLocationDropdown<District>(
                    label: 'İlçe',
                    hint: _isLoadingDistricts ? 'Yükleniyor...' : 'İlçe Seçin',
                    value: _selectedDistrict,
                    items: _districts
                        .map(
                          (d) =>
                              SearchableDropdownItem(value: d, label: d.name),
                        )
                        .toList(),
                    enabled:
                        _selectedProvince != null &&
                        !_isLoadingDistricts &&
                        _districts.isNotEmpty,
                    onChanged: (district) {
                      if (district != null) {
                        setState(() => _selectedDistrict = district);
                        _confirmSelection();
                      }
                    },
                    prefixIcon: Icons.location_city,
                  ),

                  // Helper text if user needs to know why
                  if (widget.isOnboarding)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(
                        "Size en yakın işletmeleri göstermek için konumunuza ihtiyacımız var.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // Add bottom padding to avoid safety area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSelection() async {
    if (_selectedProvince == null || _selectedDistrict == null) return;

    try {
      if (widget.isOnboarding) {
        final provider = context.read<LocationOnboardingProvider>();
        await provider.completeManualSelection(
          provinceName: _selectedProvince!.name,
          districtName: _selectedDistrict!.name,
          provinceId: _selectedProvince!.id,
          districtId: _selectedDistrict!.id,
          // Lat/Lng might be available in province/district objects if we added them to models
          // For now, we rely on the provider to fetch them or default
          latitude: _selectedProvince!.latitude,
          longitude: _selectedProvince!.longitude,
        );
      } else {
        final provider = context.read<DiscoveryProvider>();
        await provider.updateManualLocation(
          city: _selectedProvince!.name,
          district: _selectedDistrict!.name,
          provinceId: _selectedProvince!.id,
          districtId: _selectedDistrict!.id,
          latitude: _selectedProvince!.latitude,
          longitude: _selectedProvince!.longitude,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Konum güncellendi: ${_selectedDistrict!.name}, ${_selectedProvince!.name}',
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Konum kaydedilemedi, lütfen tekrar deneyin.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
                  // Added timeout handling in provider/service previously
                  await provider.requestGPSLocation();

                  // Check if we actually got a location (requestGPSLocation handles logic)
                  if (provider.selectedLocation != null) {
                    locationName = provider.selectedLocation!.districtName;
                    if (provider.selectedLocation!.provinceName.isNotEmpty) {
                      locationName +=
                          ', ${provider.selectedLocation!.provinceName}';
                    }
                  } else {
                    // If provider failed to get location (and showed toast inside),
                    // we stop loading here.
                    // Usually provider shows manual selection on failure.
                    throw Exception("Location fetch failed");
                  }
                } else {
                  final provider = context.read<DiscoveryProvider>();
                  await provider.updateLocation();
                  locationName = provider.currentLocationName;

                  if (provider.hasLocationError) {
                    throw Exception(provider.locationError);
                  }
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
                  // Error is usually shown by the provider or handled there,
                  // but we show generic error if this block catches it
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
                              'Konum alınamadı. Lütfen manuel seçim yapın.',
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
}
