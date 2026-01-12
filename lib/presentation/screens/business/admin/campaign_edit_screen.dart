import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/admin_campaigns_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/campaign.dart';

class CampaignEditScreen extends StatefulWidget {
  final Campaign? campaign;

  const CampaignEditScreen({super.key, this.campaign});

  @override
  State<CampaignEditScreen> createState() => _CampaignEditScreenState();
}

class _CampaignEditScreenState extends State<CampaignEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();

  bool _isPercentage = true;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;

  bool get isEditing => widget.campaign != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final campaign = widget.campaign!;
    _titleController.text = campaign.title;
    _descriptionController.text = campaign.description ?? '';
    _isPercentage = campaign.discountPercentage != null;
    _discountValueController.text = _isPercentage
        ? campaign.discountPercentage.toString()
        : campaign.discountAmount.toString();
    _startDate = campaign.startDate;
    _endDate = campaign.endDate;
    _currentImageUrl = campaign.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Kampanyayı Düzenle' : 'Yeni Kampanya Ekle',
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
                    _buildSectionTitle('Kampanya Detayları'),
                    const SizedBox(height: 12),
                    _buildDetailsSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('İndirim Oranı/Tutarı'),
                    const SizedBox(height: 12),
                    _buildDiscountSection(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Geçerlilik Tarihi'),
                    const SizedBox(height: 12),
                    _buildDateSection(),
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
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: _selectedImage != null
              ? Image.file(_selectedImage!, fit: BoxFit.cover)
              : (_currentImageUrl != null
                    ? Image.network(_currentImageUrl!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 50,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Kampanya Görseli Ekle',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
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
            controller: _titleController,
            label: 'Kampanya Başlığı',
            hint: 'Yaz Fırsatı: Tüm Bakımlarda %20 İndirim',
            icon: Icons.title,
            validator: (v) => v?.isEmpty == true ? 'Başlık gerekli' : null,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _descriptionController,
            label: 'Açıklama (Opsiyonel)',
            hint: 'Kampanya detayları...',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
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
          Row(
            children: [
              Expanded(child: _buildTypeToggle('Yüzde (%)', true)),
              const SizedBox(width: 12),
              Expanded(child: _buildTypeToggle('Tutar (₺)', false)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _discountValueController,
            label: _isPercentage ? 'İndirim Yüzdesi' : 'İndirim Tutarı',
            hint: _isPercentage ? '20' : '100',
            icon: _isPercentage ? Icons.percent : Icons.payments_outlined,
            keyboardType: TextInputType.number,
            validator: (v) => v?.isEmpty == true ? 'Değer gerekli' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(String label, bool value) {
    final isSelected = _isPercentage == value;
    return GestureDetector(
      onTap: () => setState(() => _isPercentage = value),
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
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final dateFormat = DateFormat('dd.MM.yyyy');
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
      child: Row(
        children: [
          Expanded(
            child: _buildDateButton(
              'Başlangıç',
              dateFormat.format(_startDate),
              true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDateButton(
              'Bitiş',
              dateFormat.format(_endDate),
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, String value, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
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
        onPressed: _isLoading ? null : _saveCampaign,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          isEditing ? 'KAYDET' : 'KAMPANYAYI OLUŞTUR',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _saveCampaign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AdminCampaignsProvider>();
      final venueId = context.read<BusinessProvider>().currentVenue?.id;
      if (venueId == null) throw Exception('Venue ID bulunamadı');

      final discountValue = double.tryParse(_discountValueController.text) ?? 0;

      if (isEditing) {
        await provider.updateCampaign(
          widget.campaign!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          discountPercentage: _isPercentage
              ? discountValue.toInt().toDouble()
              : null,
          discountAmount: _isPercentage ? null : discountValue,
          startDate: _startDate,
          endDate: _endDate,
          newImageFile: _selectedImage,
        );
      } else {
        await provider.createCampaign(
          venueId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          discountPercentage: _isPercentage
              ? discountValue.toInt().toDouble()
              : null,
          discountAmount: _isPercentage ? null : discountValue,
          startDate: _startDate,
          endDate: _endDate,
          imageFile: _selectedImage,
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
