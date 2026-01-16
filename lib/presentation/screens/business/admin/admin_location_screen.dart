import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/province.dart';
import '../../../../data/models/district.dart';
import '../../../../data/repositories/location_repository.dart';
import '../../../../data/services/location_service.dart';
import '../../../providers/admin_location_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../widgets/business/admin_map_picker.dart';

class AdminLocationScreen extends StatefulWidget {
  const AdminLocationScreen({super.key});

  @override
  State<AdminLocationScreen> createState() => _AdminLocationScreenState();
}

class _AdminLocationScreenState extends State<AdminLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  List<Province> _provinces = [];
  List<District> _districts = [];
  Province? _selectedProvince;
  District? _selectedDistrict;

  bool _isLoadingLocations = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _latitudeController = TextEditingController();
    _longitudeController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadInitialData();
      _isInitialized = true;
    }
  }

  Future<void> _loadInitialData() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;

    if (venueId != null) {
      final provider = context.read<AdminLocationProvider>();
      await provider.loadLocation(venueId);

      _addressController.text = provider.address;
      _latitudeController.text = provider.latitude.toString();
      _longitudeController.text = provider.longitude.toString();

      await _loadProvinces(provider.provinceId, provider.districtId);
    }
  }

  Future<void> _loadProvinces(
    int? initialProvinceId,
    String? initialDistrictId,
  ) async {
    setState(() => _isLoadingLocations = true);
    try {
      final repo = context.read<LocationRepository>();
      final provinces = await repo.fetchProvinces();

      setState(() {
        _provinces = provinces;
        if (initialProvinceId != null) {
          try {
            _selectedProvince = provinces.firstWhere(
              (p) => p.id == initialProvinceId,
            );
          } catch (_) {}
        }
      });

      if (_selectedProvince != null) {
        await _loadDistricts(_selectedProvince!.id, initialDistrictId);
      }
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _loadDistricts(int provinceId, String? initialDistrictId) async {
    setState(() => _isLoadingLocations = true);
    try {
      final repo = context.read<LocationRepository>();
      final districts = await repo.fetchDistrictsByProvince(provinceId);

      setState(() {
        _districts = districts;
        if (initialDistrictId != null) {
          try {
            _selectedDistrict = districts.firstWhere(
              (d) =>
                  d.id == initialDistrictId ||
                  d.name.toLowerCase() == initialDistrictId.toLowerCase(),
            );
          } catch (_) {
            _selectedDistrict = null;
          }
        } else {
          _selectedDistrict = null;
        }
      });
    } finally {
      setState(() => _isLoadingLocations = false);
    }
  }

  Future<void> _openMapPicker() async {
    final double lat = double.tryParse(_latitudeController.text) ?? 0;
    final double lng = double.tryParse(_longitudeController.text) ?? 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdminMapPicker(
        initialLocation: LatLng(lat, lng),
        onLocationSelected: (location, address) async {
          setState(() {
            _latitudeController.text = location.latitude.toStringAsFixed(6);
            _longitudeController.text = location.longitude.toStringAsFixed(6);
            if (address != null && _addressController.text.isEmpty) {
              _addressController.text = address;
            }
          });

          // Try to match province and district from coordinates
          final locationService = LocationService();
          final info = await locationService
              .extractProvinceAndDistrictFromCoordinates(
                latitude: location.latitude,
                longitude: location.longitude,
              );

          if (info != null) {
            final provinceName = info['province'];
            final districtName = info['district'];

            if (provinceName != null) {
              final repo = context.read<LocationRepository>();
              final matchedProvince = await repo.findProvinceByName(
                provinceName,
              );

              if (matchedProvince != null) {
                setState(() {
                  _selectedProvince = matchedProvince;
                });
                await _loadDistricts(matchedProvince.id, districtName);
              }
            }
          }
        },
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;
    if (venueId == null) return;

    final provider = context.read<AdminLocationProvider>();

    provider.updateAddress(_addressController.text.trim());
    provider.updateCoordinates(
      double.tryParse(_latitudeController.text) ?? 0,
      double.tryParse(_longitudeController.text) ?? 0,
    );

    if (_selectedProvince != null && _selectedDistrict != null) {
      provider.updateProvinceDistrict(
        _selectedProvince!.id,
        _selectedDistrict!.id,
      );
    }

    try {
      await provider.saveLocation(venueId);
      if (mounted) {
        _showSnackBar('Konum bilgileri başarıyla kaydedildi');
        await businessProvider.refreshVenue(venueId);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Hata: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Konum Yönetimi',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF1B0E11),
                size: 16,
              ),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Consumer<AdminLocationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.address.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Preview Section
                  _buildMapPreviewCard(),
                  const SizedBox(height: 32),

                  // Region Selection Section
                  _buildSectionTitle('Bölge Bilgileri'),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildDropdownField(
                          label: 'İl',
                          icon: Icons.map_outlined,
                          child: _buildProvinceDropdown(),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildDropdownField(
                          label: 'İlçe',
                          icon: Icons.location_city_outlined,
                          child: _buildDistrictDropdown(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Address Section
                  _buildSectionTitle('Açık Adres'),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: _buildInputField(
                      controller: _addressController,
                      label: 'Adres Detayı',
                      hint: 'Sokak, cadde, bina ve daire numarası...',
                      icon: Icons.home_outlined,
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Adres zorunludur'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Coordinates Section
                  _buildSectionTitle('Harita Koordinatları'),
                  const SizedBox(height: 8),
                  Text(
                    'Müşterilerinizin sizi haritada bulabilmesi için konum seçin',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                controller: _latitudeController,
                                label: 'Enlem (Lat)',
                                hint: '41.0082',
                                icon: Icons.explore_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Zorunlu'
                                    : null,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 80,
                              color: Colors.grey.shade200,
                            ),
                            Expanded(
                              child: _buildInputField(
                                controller: _longitudeController,
                                label: 'Boylam (Lng)',
                                hint: '28.9784',
                                icon: Icons.explore_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Zorunlu'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Save Button
                  _buildSaveButton(provider.isLoading),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapPreviewCard() {
    final lat = double.tryParse(_latitudeController.text) ?? 0;
    final lng = double.tryParse(_longitudeController.text) ?? 0;
    final hasLocation = lat != 0 && lng != 0;

    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Map Background or Placeholder
              hasLocation
                  ? Image.network(
                      'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=15&size=600x400&maptype=roadmap&markers=color:red%7C$lat,$lng&key=YOUR_API_KEY',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildMapPlaceholder(),
                    )
                  : _buildMapPlaceholder(),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Haritadan Konum Seç',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasLocation
                                ? 'Konum belirlendi • Değiştirmek için dokunun'
                                : 'Henüz konum seçilmedi',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Location Pin if has location
              if (hasLocation)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Konum Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.map_outlined,
                size: 40,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF9CA3AF),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.8)),
              const SizedBox(width: 12),
              Expanded(child: child),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProvinceDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<Province>(
        value: _selectedProvince,
        hint: Text(
          'İl seçin',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        isExpanded: true,
        icon: _isLoadingLocations
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B0E11),
        ),
        items: _provinces
            .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
            .toList(),
        onChanged: _isLoadingLocations
            ? null
            : (province) {
                setState(() {
                  _selectedProvince = province;
                  _selectedDistrict = null;
                });
                if (province != null) {
                  _loadDistricts(province.id, null);
                }
              },
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<District>(
        value: _selectedDistrict,
        hint: Text(
          _selectedProvince == null ? 'Önce il seçin' : 'İlçe seçin',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        isExpanded: true,
        icon: _isLoadingLocations
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            : Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade400,
              ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1B0E11),
        ),
        items: _districts
            .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
            .toList(),
        onChanged: _isLoadingLocations || _selectedProvince == null
            ? null
            : (district) {
                setState(() => _selectedDistrict = district);
              },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B0E11),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              prefixIconConstraints: const BoxConstraints(minWidth: 32),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  icon,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'KONUMU KAYDET',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
