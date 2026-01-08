import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/province.dart';
import '../../../data/models/district.dart';
import '../../../data/repositories/location_repository.dart';
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
  Province? _selectedProvince;
  District? _selectedDistrict;

  List<Province> _provinces = [];
  List<District> _districts = [];

  bool _isLoadingProvinces = true;
  bool _isLoadingDistricts = false;
  String? _errorMessage;

  // Search controllers
  final TextEditingController _provinceSearchController =
      TextEditingController();
  final TextEditingController _districtSearchController =
      TextEditingController();

  List<Province> _filteredProvinces = [];
  List<District> _filteredDistricts = [];

  late LocationRepository _locationRepository;

  @override
  void initState() {
    super.initState();
    // Get repository from provider if available, otherwise create new
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initRepository();
    });
  }

  void _initRepository() {
    try {
      final onboardingProvider = context.read<LocationOnboardingProvider>();
      _locationRepository = onboardingProvider.locationRepository;
    } catch (_) {
      _locationRepository = LocationRepository();
    }
    _loadProvinces();
  }

  @override
  void dispose() {
    _provinceSearchController.dispose();
    _districtSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isLoadingProvinces = true;
      _errorMessage = null;
    });

    try {
      final provinces = await _locationRepository.fetchProvinces();
      setState(() {
        _provinces = provinces;
        _filteredProvinces = provinces;
        _isLoadingProvinces = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadDistricts(int provinceId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _filteredDistricts = [];
      _selectedDistrict = null;
      _districtSearchController.clear();
    });

    try {
      final districts = await _locationRepository.fetchDistrictsByProvince(
        provinceId,
      );
      setState(() {
        _districts = districts;
        _filteredDistricts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingDistricts = false;
      });
    }
  }

  void _filterProvinces(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProvinces = _provinces;
      } else {
        _filteredProvinces = _provinces
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _filterDistricts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDistricts = _districts;
      } else {
        _filteredDistricts = _districts
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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

                  // Manual Selection Section
                  const Text(
                    'Manuel Konum Seçimi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Province Selection
                  _buildProvinceSelection(),
                  const SizedBox(height: 16),

                  // District Selection
                  _buildDistrictSelection(),
                  const SizedBox(height: 24),

                  // Map Selection Button
                  OutlinedButton.icon(
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
                                context
                                    .read<DiscoveryProvider>()
                                    .updateManualLocation(city, district);
                              }
                              // No need to pop here as MapLocationPicker does it?
                              // Actually MapLocationPicker calls onLocationSelected, so we need to pop MapLocationPicker.
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.map_outlined, size: 20),
                    label: const Text('Haritadan Seç'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadProvinces,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Apply Button
                  _buildApplyButton(context),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocationButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        if (widget.isOnboarding) {
          final provider = context.read<LocationOnboardingProvider>();
          await provider.requestGPSLocation();
        } else {
          final provider = context.read<DiscoveryProvider>();
          await provider.updateLocation();
        }
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
      icon: const Icon(Icons.my_location, size: 20),
      label: const Text('Mevcut Konumumu Kullan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  Widget _buildProvinceSelection() {
    if (_isLoadingProvinces) {
      return _buildLoadingContainer('İller yükleniyor...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _provinceSearchController,
          decoration: InputDecoration(
            hintText: 'İl ara...',
            prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: _filterProvinces,
        ),
        const SizedBox(height: 12),

        // Province list
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _filteredProvinces.isEmpty
              ? const Center(
                  child: Text(
                    'İl bulunamadı',
                    style: TextStyle(color: AppColors.gray500),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredProvinces.length,
                  itemBuilder: (context, index) {
                    final province = _filteredProvinces[index];
                    final isSelected = _selectedProvince?.id == province.id;

                    return ListTile(
                      dense: true,
                      title: Text(
                        province.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray900,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedProvince = province;
                          _provinceSearchController.clear();
                          _filteredProvinces = _provinces;
                        });
                        _loadDistricts(province.id);
                      },
                    );
                  },
                ),
        ),

        // Selected province indicator
        if (_selectedProvince != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.location_city,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Seçilen İl: ${_selectedProvince!.name}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDistrictSelection() {
    if (_selectedProvince == null) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.gray100,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(
          'Önce bir il seçin',
          style: TextStyle(color: AppColors.gray400),
        ),
      );
    }

    if (_isLoadingDistricts) {
      return _buildLoadingContainer('İlçeler yükleniyor...');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        TextField(
          controller: _districtSearchController,
          decoration: InputDecoration(
            hintText: 'İlçe ara...',
            prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: _filterDistricts,
        ),
        const SizedBox(height: 12),

        // District list
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _filteredDistricts.isEmpty
              ? const Center(
                  child: Text(
                    'İlçe bulunamadı',
                    style: TextStyle(color: AppColors.gray500),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredDistricts.length,
                  itemBuilder: (context, index) {
                    final district = _filteredDistricts[index];
                    final isSelected = _selectedDistrict?.id == district.id;

                    return ListTile(
                      dense: true,
                      title: Text(
                        district.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.gray900,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedDistrict = district;
                          _districtSearchController.clear();
                          _filteredDistricts = _districts;
                        });
                      },
                    );
                  },
                ),
        ),

        // Selected district indicator
        if (_selectedDistrict != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.place, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Seçilen İlçe: ${_selectedDistrict!.name}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingContainer(String message) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.gray500)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    final isEnabled = _selectedProvince != null && _selectedDistrict != null;

    return ElevatedButton(
      onPressed: isEnabled
          ? () async {
              if (widget.isOnboarding) {
                // Use onboarding provider
                final onboardingProvider = context
                    .read<LocationOnboardingProvider>();
                await onboardingProvider.completeManualSelection(
                  provinceName: _selectedProvince!.name,
                  districtName: _selectedDistrict!.name,
                  provinceId: _selectedProvince!.id,
                  latitude: _selectedProvince!.latitude,
                  longitude: _selectedProvince!.longitude,
                );
              } else {
                // Use discovery provider
                final provider = context.read<DiscoveryProvider>();
                provider.updateManualLocation(
                  _selectedProvince!.name,
                  _selectedDistrict!.name,
                );
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? AppColors.primary : AppColors.gray300,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
      ),
      child: const Text(
        'Konumu Uygula',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
