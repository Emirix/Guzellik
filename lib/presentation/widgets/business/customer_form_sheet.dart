import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/customer.dart';
import '../../providers/customer_provider.dart';

class CustomerFormSheet extends StatefulWidget {
  final Customer? customer;

  const CustomerFormSheet({super.key, this.customer});

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;
  int _gender = 0; // 0: Kadın, 1: Erkek

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name);
    _phoneController = TextEditingController(text: widget.customer?.phone);
    _notesController = TextEditingController(text: widget.customer?.notes);
    _selectedDate = widget.customer?.birthDate;
    _gender = widget.customer?.gender ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveCustomer() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<CustomerProvider>();

      final customer =
          widget.customer?.copyWith(
            name: _nameController.text,
            phone: _phoneController.text,
            gender: _gender,
            birthDate: _selectedDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
          ) ??
          Customer(
            id: '', // Service will handle
            ownerId: '', // Service will handle
            name: _nameController.text,
            phone: _phoneController.text,
            gender: _gender,
            birthDate: _selectedDate,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
            createdAt: DateTime.now(),
          );

      bool success;
      if (widget.customer != null) {
        success = await provider.updateCustomer(customer);
      } else {
        success = await provider.addCustomer(customer);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.customer != null
                  ? 'Müşteri güncellendi'
                  : 'Müşteri başarıyla eklendi',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Bir hata oluştu'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'Ad Soyad',
                      validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefon',
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildGenderAndDate(),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Müşteri Hakkında Notlar',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 48,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer != null ? 'Müşteriyi Düzenle' : 'Yeni Müşteri',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Outfit',
                  color: AppColors.black,
                ),
              ),
              const Text(
                'Müşteri bilgilerini giriniz',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.secondary, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.gray200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildGenderAndDate() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CİNSİYET',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderButton('Kadın', 0),
                  const SizedBox(width: 8),
                  _buildGenderButton('Erkek', 1),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DOĞUM TARİHİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray200, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate == null
                            ? 'Seç'
                            : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, int value) {
    final isSelected = _gender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _gender = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.gray200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.secondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveCustomer,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.customer != null ? 'Güncelle' : 'Müşteriyi Kaydet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.check, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
