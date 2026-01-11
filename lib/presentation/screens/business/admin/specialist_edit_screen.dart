import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_specialists_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/specialist.dart';
import '../../../../core/utils/image_utils.dart';

class SpecialistEditScreen extends StatefulWidget {
  final Specialist? specialist;

  const SpecialistEditScreen({super.key, this.specialist});

  @override
  State<SpecialistEditScreen> createState() => _SpecialistEditScreenState();
}

class _SpecialistEditScreenState extends State<SpecialistEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _professionController = TextEditingController();
  final _bioController = TextEditingController();
  String _gender = 'female';

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;

  bool get isEditing => widget.specialist != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final specialist = widget.specialist!;
    _nameController.text = specialist.name;
    _professionController.text = specialist.profession;
    _bioController.text = specialist.bio ?? '';
    _gender = specialist.gender?.toLowerCase() ?? 'female';
    _currentImageUrl = specialist.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _professionController.dispose();
    _bioController.dispose();
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
        maxWidth: 600,
        maxHeight: 600,
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
          isEditing ? 'Uzmanı Düzenle' : 'Yeni Uzman Ekle',
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Temel Bilgiler'),
                    const SizedBox(height: 12),
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Cinsiyet'),
                    const SizedBox(height: 12),
                    _buildGenderSection(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
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
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: _selectedImage != null
                  ? FileImage(_selectedImage!)
                  : (_currentImageUrl != null
                            ? NetworkImage(_currentImageUrl!)
                            : null)
                        as ImageProvider?,
              child: (_selectedImage == null && _currentImageUrl == null)
                  ? Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary.withOpacity(0.5),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
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

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Ad Soyad',
            hint: 'Ebru Yılmaz',
            icon: Icons.person_outline,
            validator: (v) =>
                v?.isEmpty == true ? 'Lütfen ad soyad girin' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _professionController,
            label: 'Uzmanlık Alanı',
            hint: 'Cilt Bakım Uzmanı',
            icon: Icons.work_outline,
            validator: (v) =>
                v?.isEmpty == true ? 'Lütfen uzmanlık alanı girin' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bioController,
            label: 'Hakkında (Opsiyonel)',
            hint: 'Uzman hakkında kısa bilgi...',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildGenderButton('Kadın', 'female', Icons.female)),
          const SizedBox(width: 12),
          Expanded(child: _buildGenderButton('Erkek', 'male', Icons.male)),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String label, String value, IconData icon) {
    final isSelected = _gender == value;
    return GestureDetector(
      onTap: () => setState(() => _gender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey[400],
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSpecialist,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          isEditing ? 'KAYDET' : 'UZMANI OLUŞTUR',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveSpecialist() async {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('🔵 [_saveSpecialist] Başlıyor...');
    debugPrint('📋 [_saveSpecialist] Form validasyonu başarılı');

    setState(() => _isLoading = true);

    try {
      debugPrint('🏢 [_saveSpecialist] Provider ve venue bilgisi alınıyor...');
      final provider = context.read<AdminSpecialistsProvider>();
      final venueId = context.read<BusinessProvider>().currentVenue?.id;

      if (venueId == null) {
        debugPrint('❌ [_saveSpecialist] Venue ID bulunamadı!');
        throw Exception('Venue ID bulunamadı');
      }

      debugPrint('✅ [_saveSpecialist] Venue ID: $venueId');
      debugPrint(
        'ℹ️ [_saveSpecialist] İşlem tipi: ${isEditing ? "GÜNCELLEME" : "EKLEME"}',
      );

      if (isEditing) {
        debugPrint(
          '📝 [_saveSpecialist] Uzman güncelleniyor: ${widget.specialist!.id}',
        );
        await provider.updateSpecialist(
          widget.specialist!.id,
          name: _nameController.text.trim(),
          profession: _professionController.text.trim(),
          gender: _gender,
          bio: _bioController.text.trim(),
          newImageFile: _selectedImage,
        );
        debugPrint('✅ [_saveSpecialist] Uzman güncellendi');
      } else {
        debugPrint('➕ [_saveSpecialist] Yeni uzman ekleniyor...');
        debugPrint('👤 [_saveSpecialist] Ad: ${_nameController.text.trim()}');
        debugPrint(
          '💼 [_saveSpecialist] Meslek: ${_professionController.text.trim()}',
        );
        debugPrint('⚧ [_saveSpecialist] Cinsiyet: $_gender');
        debugPrint(
          '📷 [_saveSpecialist] Resim: ${_selectedImage != null ? "Var" : "Yok"}',
        );

        await provider.addSpecialist(
          venueId,
          name: _nameController.text.trim(),
          profession: _professionController.text.trim(),
          gender: _gender,
          bio: _bioController.text.trim(),
          imageFile: _selectedImage,
        );
        debugPrint('✅ [_saveSpecialist] Uzman eklendi');
      }

      if (mounted) {
        debugPrint('🔙 [_saveSpecialist] Geri dönülüyor...');
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ [_saveSpecialist] HATA OLUŞTU: $e');
      debugPrint('❌ [_saveSpecialist] Hata tipi: ${e.runtimeType}');
      debugPrint('❌ [_saveSpecialist] Stack trace: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      debugPrint(
        '🏁 [_saveSpecialist] İşlem tamamlandı, loading kapatılıyor...',
      );
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
