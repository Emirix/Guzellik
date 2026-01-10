import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/province.dart';
import '../../../data/models/district.dart';
import '../../../data/repositories/location_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_onboarding_provider.dart';
import '../../providers/discovery_provider.dart';
import '../../widgets/common/searchable_location_dropdown.dart';

/// Screen to complete user profile after social login (e.g. Google)
/// Mandatory province and district selection
class CompleteProfileScreen extends StatefulWidget {
  final String? redirectPath;

  const CompleteProfileScreen({super.key, this.redirectPath});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Province> _provinces = [];
  List<District> _districts = [];

  int? _selectedProvinceId;
  String? _selectedDistrictId;

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
      final repo = context.read<LocationRepository>();
      final provinces = await repo.fetchProvinces();
      setState(() {
        _provinces = provinces;
        _isLoadingProvinces = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProvinces = false);
      }
    }
  }

  Future<void> _loadDistricts(int provinceId) async {
    setState(() {
      _isLoadingDistricts = true;
      _districts = [];
      _selectedDistrictId = null;
    });
    try {
      final repo = context.read<LocationRepository>();
      final districts = await repo.fetchDistrictsByProvince(provinceId);
      setState(() {
        _districts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingDistricts = false);
      }
    }
  }

  Future<void> _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      // Update profile in DB
      final success = await authProvider.updateProfile(
        provinceId: _selectedProvinceId,
        districtId: _selectedDistrictId,
      );

      if (mounted && success) {
        // Also update local location state
        final selectedProvince = _provinces.firstWhere(
          (p) => p.id == _selectedProvinceId,
        );
        final selectedDistrict = _districts.firstWhere(
          (d) => d.id == _selectedDistrictId,
        );

        // Update DiscoveryProvider
        await context.read<DiscoveryProvider>().updateManualLocation(
          city: selectedProvince.name,
          district: selectedDistrict.name,
          provinceId: selectedProvince.id,
          districtId: selectedDistrict.id,
        );

        // Update LocationOnboardingProvider
        await context
            .read<LocationOnboardingProvider>()
            .completeManualSelection(
              provinceName: selectedProvince.name,
              districtName: selectedDistrict.name,
              provinceId: selectedProvince.id,
              districtId: selectedDistrict.id,
            );

        // Navigate to destination
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!);
        } else {
          context.go('/');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Profil güncellenemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section with Icon
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        const Color(0xFFF8F6F6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/logo-transparent.svg',
                      width: 60,
                      height: 60,
                      colorFilter: const ColorFilter.mode(
                        AppColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Profilini Tamamla',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B0E11),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Size en yakın yerleri gösterebilmemiz için konum bilgilerinizi seçiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF955062),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Province Selection
                    SearchableLocationDropdown<int>(
                      label: 'İl Seçin',
                      hint: _isLoadingProvinces
                          ? 'Yükleniyor...'
                          : 'İl Seçiniz',
                      value: _selectedProvinceId,
                      prefixIcon: Icons.location_city,
                      items: _provinces.map((p) {
                        return SearchableDropdownItem(
                          value: p.id,
                          label: p.name,
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProvinceId = value;
                        });
                        if (value != null) {
                          _loadDistricts(value);
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'İl seçimi zorunludur';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // District Selection
                    SearchableLocationDropdown<String>(
                      label: 'İlçe Seçin',
                      hint: _selectedProvinceId == null
                          ? 'Önce İl Seçiniz'
                          : (_isLoadingDistricts
                                ? 'Yükleniyor...'
                                : 'İlçe Seçiniz'),
                      value: _selectedDistrictId,
                      prefixIcon: Icons.place_outlined,
                      items: _districts.map((d) {
                        return SearchableDropdownItem(
                          value: d.id,
                          label: d.name,
                        );
                      }).toList(),
                      onChanged: _selectedProvinceId == null
                          ? null
                          : (value) {
                              setState(() {
                                _selectedDistrictId = value;
                              });
                            },
                      validator: (value) {
                        if (value == null) return 'İlçe seçimi zorunludur';
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    // Action Button
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, _) {
                        return Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFFFF6B8A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : _handleComplete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 0,
                            ),
                            child: authProvider.isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Kaydet ve Devam Et',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
