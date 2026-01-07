import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/location_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/discovery_provider.dart';
import 'map_location_picker.dart';

class LocationSelectionBottomSheet extends StatefulWidget {
  const LocationSelectionBottomSheet({super.key});

  @override
  State<LocationSelectionBottomSheet> createState() =>
      _LocationSelectionBottomSheetState();
}

class _LocationSelectionBottomSheetState
    extends State<LocationSelectionBottomSheet> {
  String? _selectedCity;
  String? _selectedDistrict;
  List<String> _districts = [];

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
                const Text(
                  'Konum Seçin',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
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

                  // City Dropdown
                  _buildCityDropdown(),
                  const SizedBox(height: 16),

                  // District Dropdown
                  _buildDistrictDropdown(),
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
                              final provider = context
                                  .read<DiscoveryProvider>();
                              provider.updateManualLocation(city, district);
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
        final provider = context.read<DiscoveryProvider>();
        await provider.updateLocation();
        await provider.refresh();
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

  Widget _buildCityDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCity,
          hint: const Text(
            'İl seçiniz',
            style: TextStyle(color: AppColors.gray500),
          ),
          icon: const Icon(Icons.expand_more, color: AppColors.gray700),
          items: LocationConstants.cities.map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(
                city,
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedDistrict = null;
              _districts = value != null
                  ? LocationConstants.getDistricts(value)
                  : [];
            });
          },
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedCity == null ? AppColors.gray200 : AppColors.gray300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedDistrict,
          hint: Text(
            'İlçe seçiniz',
            style: TextStyle(
              color: _selectedCity == null
                  ? AppColors.gray300
                  : AppColors.gray500,
            ),
          ),
          icon: Icon(
            Icons.expand_more,
            color: _selectedCity == null
                ? AppColors.gray300
                : AppColors.gray700,
          ),
          items: _districts.map((district) {
            return DropdownMenuItem(
              value: district,
              child: Text(
                district,
                style: const TextStyle(fontSize: 15, color: AppColors.gray900),
              ),
            );
          }).toList(),
          onChanged: _selectedCity == null
              ? null
              : (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    final isEnabled = _selectedCity != null && _selectedDistrict != null;

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              final provider = context.read<DiscoveryProvider>();
              provider.updateManualLocation(_selectedCity!, _selectedDistrict!);
              Navigator.pop(context);
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
