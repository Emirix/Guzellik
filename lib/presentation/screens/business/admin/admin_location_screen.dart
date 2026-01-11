import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/province.dart';
import '../../../../data/models/district.dart';
import '../../../../data/repositories/location_repository.dart';
import '../../../providers/admin_location_provider.dart';
import '../../../providers/business_provider.dart';

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
              (d) => d.id == initialDistrictId,
            );
          } catch (_) {}
        } else {
          _selectedDistrict = null;
        }
      });
    } finally {
      setState(() => _isLoadingLocations = false);
    }
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum bilgileri kaydedildi')),
        );
        await businessProvider.refreshVenue(venueId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Konum Yönetimi',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1B0E11),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          Consumer<AdminLocationProvider>(
            builder: (context, provider, _) => IconButton(
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle, color: AppColors.primary),
              onPressed: provider.isLoading ? null : _saveChanges,
            ),
          ),
        ],
      ),
      body: Consumer<AdminLocationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.address.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // İl Seçimi
                const Text(
                  'Bölge Bilgileri',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Province>(
                  value: _selectedProvince,
                  decoration: _buildInputDecoration('İl', Icons.map),
                  items: _provinces
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
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
                  validator: (value) =>
                      value == null ? 'İl seçimi zorunludur' : null,
                ),
                const SizedBox(height: 16),

                // İlçe Seçimi
                DropdownButtonFormField<District>(
                  value: _selectedDistrict,
                  decoration: _buildInputDecoration(
                    'İlçe',
                    Icons.location_city,
                  ),
                  items: _districts
                      .map(
                        (d) => DropdownMenuItem(value: d, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: _isLoadingLocations
                      ? null
                      : (district) {
                          setState(() => _selectedDistrict = district);
                        },
                  validator: (value) =>
                      value == null ? 'İlçe seçimi zorunludur' : null,
                ),
                const SizedBox(height: 32),

                // Açık Adres
                const Text(
                  'Açık Adres',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Adres Detayı', Icons.home),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Adres zorunludur'
                      : null,
                ),
                const SizedBox(height: 32),

                // Koordinatlar
                const Text(
                  'Harita Koordinatları',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Müşterilerinizin sizi haritada bulabilmesi için koordinatları girin.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _buildInputDecoration(
                          'Enlem (Lat)',
                          Icons.explore,
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Zorunlu' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _longitudeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _buildInputDecoration(
                          'Boylam (Lng)',
                          Icons.explore,
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Zorunlu' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Save Button Helper
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'DEĞİŞİKLİKLERİ KAYDET',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
