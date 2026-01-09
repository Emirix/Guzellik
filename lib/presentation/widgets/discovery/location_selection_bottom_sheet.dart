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

  void _setInitialSelection() {
    String? currentCity;
    String? currentDistrict;

    if (widget.isOnboarding) {
      final onboarding = context.read<LocationOnboardingProvider>();
      currentCity = onboarding.selectedLocation?.provinceName;
      currentDistrict = onboarding.selectedLocation?.districtName;
    } else {
      final discovery = context.read<DiscoveryProvider>();
      currentCity = discovery.manualCity;
      currentDistrict = discovery.manualDistrict;

      // Fallback if not using manual location but have coordinates
      if (currentCity == null && currentDistrict == null) {
        // Try to parse from name if it follows "District, City" format
        final name = discovery.currentLocationName;
        if (name.contains(', ')) {
          final parts = name.split(', ');
          currentDistrict = parts[0];
          currentCity = parts[1];
        }
      }
    }

    if (currentCity != null) {
      final province = _provinces.cast<Province?>().firstWhere(
        (p) => p?.name.toLowerCase() == currentCity?.toLowerCase(),
        orElse: () => null,
      );

      if (province != null) {
        setState(() {
          _selectedProvince = province;
        });
        _loadDistricts(province.id, initialDistrictName: currentDistrict);
      }
    }
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
      _setInitialSelection();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingProvinces = false;
      });
    }
  }

  Future<void> _loadDistricts(
    int provinceId, {
    String? initialDistrictName,
  }) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _filteredDistricts = [];
      if (initialDistrictName == null) {
        _selectedDistrict = null;
        _districtSearchController.clear();
      }
    });

    try {
      final districts = await _locationRepository.fetchDistrictsByProvince(
        provinceId,
      );
      setState(() {
        _districts = districts;
        _filteredDistricts = districts;
        _isLoadingDistricts = false;

        if (initialDistrictName != null) {
          _selectedDistrict = _districts.cast<District?>().firstWhere(
            (d) => d?.name.toLowerCase() == initialDistrictName.toLowerCase(),
            orElse: () => null,
          );
        }
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

                  // Province & District Selection (Side by Side)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProvinceDropdown()),
                      const SizedBox(width: 12),
                      Expanded(child: _buildDistrictDropdown()),
                    ],
                  ),
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
                                    .updateManualLocation(
                                      city: city,
                                      district: district,
                                    );
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

  Widget _buildProvinceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İl',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isLoadingProvinces ? null : () => _showProvinceSelector(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedProvince != null
                    ? AppColors.primary
                    : AppColors.gray300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_city_outlined,
                  size: 20,
                  color: _selectedProvince != null
                      ? AppColors.primary
                      : AppColors.gray400,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _isLoadingProvinces
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _selectedProvince?.name ?? 'İl seçin',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedProvince != null
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight: _selectedProvince != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _selectedProvince != null
                      ? AppColors.primary
                      : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistrictDropdown() {
    final isEnabled = _selectedProvince != null && !_isLoadingDistricts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İlçe',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isEnabled ? () => _showDistrictSelector() : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _selectedDistrict != null
                    ? AppColors.primary
                    : AppColors.gray300,
              ),
              borderRadius: BorderRadius.circular(12),
              color: _selectedProvince == null
                  ? AppColors.gray100
                  : AppColors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 20,
                  color: _selectedDistrict != null
                      ? AppColors.primary
                      : AppColors.gray400,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _isLoadingDistricts
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _selectedDistrict?.name ??
                              (_selectedProvince == null
                                  ? 'Önce il seçin'
                                  : 'İlçe seçin'),
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedDistrict != null
                                ? AppColors.gray900
                                : AppColors.gray400,
                            fontWeight: _selectedDistrict != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _selectedDistrict != null
                      ? AppColors.primary
                      : AppColors.gray400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProvinceSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'İl Seçin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.gray700),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _provinceSearchController,
                decoration: InputDecoration(
                  hintText: 'İl ara...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.gray500,
                  ),
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
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
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
                          leading: Icon(
                            Icons.location_city,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray400,
                            size: 20,
                          ),
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
                                  Icons.check_circle,
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
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistrictSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selectedProvince?.name ?? ''} - İlçe Seçin',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.gray700),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _districtSearchController,
                decoration: InputDecoration(
                  hintText: 'İlçe ara...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.gray500,
                  ),
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
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
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
                          leading: Icon(
                            Icons.place,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.gray400,
                            size: 20,
                          ),
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
                                  Icons.check_circle,
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
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
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
                  districtId: _selectedDistrict!.id,
                  latitude: _selectedProvince!.latitude,
                  longitude: _selectedProvince!.longitude,
                );
              } else {
                // Use discovery provider
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
