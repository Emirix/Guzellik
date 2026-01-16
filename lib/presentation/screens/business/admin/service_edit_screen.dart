import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_services_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/venue_service.dart';
import '../../../../data/models/service_category.dart';
import '../../../../core/utils/image_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceEditScreen extends StatefulWidget {
  final VenueService? service;

  const ServiceEditScreen({super.key, this.service});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();

  ServiceCategory? _selectedCategory;
  final _customNameController = TextEditingController();
  final _customDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isActive = true;
  bool _isLoading = false;

  bool get isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final service = widget.service!;
    _customNameController.text = service.customName ?? '';
    _customDescriptionController.text = service.customDescription ?? '';
    _priceController.text = service.price?.toString() ?? '';
    _durationController.text = service.durationMinutes?.toString() ?? '';
    _currentImageUrl = service.customImageUrl;
    _isActive = service.isActive;
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customDescriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final compressed = await ImageUtils.compressImage(
        File(pickedFile.path),
        quality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );
      setState(() {
        _selectedImage = compressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Hizmeti Düzenle' : 'Yeni Hizmet Ekle',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Section: Service Selection
                    _buildSectionTitle('Hizmet Seçimi'),
                    const SizedBox(height: 12),
                    _buildCategorySelectionSection(),

                    const SizedBox(height: 24),

                    // Section: Custom Details
                    _buildSectionTitle('Özelleştirme (Opsiyonel)'),
                    const SizedBox(height: 12),
                    _buildCustomDetailsSection(),

                    const SizedBox(height: 24),

                    // Section: Pricing & Duration
                    _buildSectionTitle('Fiyatlandırma & Süre (Opsiyonel)'),
                    const SizedBox(height: 12),
                    _buildPricingSection(),

                    const SizedBox(height: 24),

                    // Section: Visibility
                    _buildSectionTitle('Görünürlük'),
                    const SizedBox(height: 12),
                    _buildVisibilitySection(),

                    const SizedBox(height: 40),

                    _buildSubmitButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : _currentImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: _currentImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Hizmet Fotoğrafı Ekle',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelectionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            _buildInfoTile('Seçili Hizmet', widget.service!.serviceName ?? '-'),
            const SizedBox(height: 8),
            _buildInfoTile('Kategori', widget.service!.serviceCategory ?? '-'),
          ] else ...[
            GestureDetector(
              onTap: _showSearchableCategoryDialog,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedCategory != null
                            ? '${_selectedCategory!.subCategory} > ${_selectedCategory!.name}'
                            : 'Arama yaparak hizmet seçin...',
                        style: TextStyle(
                          color: _selectedCategory != null
                              ? Colors.black87
                              : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Icon(Icons.expand_more, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSearchableCategoryDialog() {
    final provider = context.read<AdminServicesProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchableCategoryList(
          categories: provider.allCategories,
          onSelected: (cat) {
            setState(() => _selectedCategory = cat);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildCustomDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _customNameController,
            label: 'Özel İsim',
            hint: isEditing
                ? widget.service!.serviceName
                : 'Örn: Ekspres Manikür',
            icon: Icons.edit_note,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _customDescriptionController,
            label: 'Açıklama',
            hint: 'Hizmet hakkında detaylı bilgi...',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _priceController,
              label: 'Fiyat (₺)',
              hint: '0.00',
              icon: Icons.payments_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildTextField(
              controller: _durationController,
              label: 'Süre (Dakika)',
              hint: '30',
              icon: Icons.access_time,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilitySection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        title: const Text(
          'Hizmeti Aktifleştir',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          _isActive ? 'Aktif' : 'Pasif',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        value: _isActive,
        activeThumbColor: AppColors.primary,
        onChanged: (v) => setState(() => _isActive = v),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveService,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          isEditing ? 'KAYDET' : 'HİZMETİ OLUŞTUR',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    if (!isEditing && _selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir hizmet seçin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminServicesProvider>();
      final venueId = context.read<BusinessProvider>().currentVenue?.id;
      if (venueId == null) throw Exception('Venue ID bulunamadı');

      String? imageUrl = _currentImageUrl;
      if (_selectedImage != null) {
        imageUrl = await provider.uploadServiceImage(venueId, _selectedImage!);
      }

      final priceValue = double.tryParse(_priceController.text);
      final durationValue = int.tryParse(_durationController.text);
      final customName = _customNameController.text.trim().isEmpty
          ? null
          : _customNameController.text.trim();
      final customDesc = _customDescriptionController.text.trim().isEmpty
          ? null
          : _customDescriptionController.text.trim();

      if (isEditing) {
        await provider.updateService(
          widget.service!.id,
          customName: customName,
          customDescription: customDesc,
          customImageUrl: imageUrl,
          price: priceValue,
          durationMinutes: durationValue,
          isActive: _isActive,
        );
      } else {
        await provider.addService(
          venueId,
          _selectedCategory!.id,
          customName: customName,
          customDescription: customDesc,
          customImageUrl: imageUrl,
          price: priceValue,
          durationMinutes: durationValue,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _SearchableCategoryList extends StatefulWidget {
  final List<ServiceCategory> categories;
  final Function(ServiceCategory) onSelected;

  const _SearchableCategoryList({
    required this.categories,
    required this.onSelected,
  });

  @override
  State<_SearchableCategoryList> createState() =>
      _SearchableCategoryListState();
}

class _SearchableCategoryListState extends State<_SearchableCategoryList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.categories.where((cat) {
      final match =
          cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cat.subCategory.toLowerCase().contains(_searchQuery.toLowerCase());
      return match;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Hizmet veya kategori ara...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final cat = filtered[index];
                return ListTile(
                  title: Text(
                    cat.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cat.subCategory,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18),
                  onTap: () => widget.onSelected(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
