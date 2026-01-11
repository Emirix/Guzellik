import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_basic_info_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/auth_provider.dart';

class AdminBasicInfoScreen extends StatefulWidget {
  const AdminBasicInfoScreen({super.key});

  @override
  State<AdminBasicInfoScreen> createState() => _AdminBasicInfoScreenState();
}

class _AdminBasicInfoScreenState extends State<AdminBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _instagramController;
  late TextEditingController _whatsappController;
  late TextEditingController _facebookController;
  late TextEditingController _websiteController;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _instagramController = TextEditingController();
    _whatsappController = TextEditingController();
    _facebookController = TextEditingController();
    _websiteController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;

    if (venueId != null) {
      final provider = context.read<AdminBasicInfoProvider>();
      await provider.loadVenueBasicInfo(venueId);

      // Populate controllers
      _nameController.text = provider.name;
      _descriptionController.text = provider.description;
      _phoneController.text = provider.phone;
      _emailController.text = provider.email;
      _instagramController.text = provider.instagramUrl;
      _whatsappController.text = provider.whatsappNumber;
      _facebookController.text = provider.facebookUrl;
      _websiteController.text = provider.websiteUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final businessProvider = context.read<BusinessProvider>();
    final venueId = businessProvider.businessVenue?.id;

    if (venueId == null) {
      _showSnackBar('Hata: İşletme bilgisi bulunamadı', isError: true);
      return;
    }

    final provider = context.read<AdminBasicInfoProvider>();

    try {
      await provider.updateBasicInfo(
        venueId: venueId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        socialLinks: {
          'instagram': _instagramController.text.trim(),
          'whatsapp': _whatsappController.text.trim(),
          'facebook': _facebookController.text.trim(),
          'website': _websiteController.text.trim(),
        },
      );

      if (mounted) {
        _showSnackBar('Değişiklikler kaydedildi');
        // Refresh business provider to update venue details
        final authProvider = context.read<AuthProvider>();
        if (authProvider.currentUser != null) {
          await businessProvider.refreshVenue(authProvider.currentUser!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Hata: ${e.toString()}', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Temel Bilgiler',
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
          Consumer<AdminBasicInfoProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle, color: AppColors.primary),
                onPressed: provider.isLoading ? null : _saveChanges,
              );
            },
          ),
        ],
      ),
      body: Consumer<AdminBasicInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.venueData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // İşletme Adı
                _buildTextField(
                  controller: _nameController,
                  label: 'İşletme Adı',
                  hint: 'Örn: Güzellik Salonu',
                  icon: Icons.store,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'İşletme adı zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tanıtım Yazısı
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Tanıtım Yazısı',
                  hint: 'İşletmenizi tanıtın...',
                  icon: Icons.description,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),

                // Telefon
                _buildTextField(
                  controller: _phoneController,
                  label: 'Telefon',
                  hint: '+90 555 123 45 67',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validatePhone(value)) {
                      return 'Geçerli bir telefon numarası girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-posta
                _buildTextField(
                  controller: _emailController,
                  label: 'E-posta',
                  hint: 'ornek@email.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validateEmail(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Sosyal Medya Başlığı
                const Text(
                  'Sosyal Medya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B0E11),
                  ),
                ),
                const SizedBox(height: 16),

                // Instagram
                _buildTextField(
                  controller: _instagramController,
                  label: 'Instagram',
                  hint: 'https://instagram.com/kullaniciadi',
                  icon: Icons.camera_alt,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validateUrl(value)) {
                      return 'Geçerli bir URL girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // WhatsApp
                _buildTextField(
                  controller: _whatsappController,
                  label: 'WhatsApp',
                  hint: '+90 555 123 45 67',
                  icon: Icons.chat,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validatePhone(value)) {
                      return 'Geçerli bir telefon numarası girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Facebook
                _buildTextField(
                  controller: _facebookController,
                  label: 'Facebook (Opsiyonel)',
                  hint: 'https://facebook.com/sayfa',
                  icon: Icons.facebook,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validateUrl(value)) {
                      return 'Geçerli bir URL girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Website
                _buildTextField(
                  controller: _websiteController,
                  label: 'Website (Opsiyonel)',
                  hint: 'https://example.com',
                  icon: Icons.language,
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !provider.validateUrl(value)) {
                      return 'Geçerli bir URL girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Alt Menü Butonları (Çalışma Saatleri & Konum)
                _buildSubMenuButton(
                  title: 'Çalışma Saatlerini Düzenle',
                  subtitle: 'Haftalık açılış ve kapanış saatleri',
                  icon: Icons.schedule,
                  onTap: () => context.push('/business/admin/working-hours'),
                ),
                const SizedBox(height: 12),
                _buildSubMenuButton(
                  title: 'Konum ve Adres Düzenle',
                  subtitle: 'Harita konumu ve açık adres',
                  icon: Icons.location_on,
                  onTap: () => context.push('/business/admin/location'),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: provider.isLoading ? null : _saveChanges,
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 20),
                    label: Text(
                      provider.isLoading ? 'KAYDEDİLİYOR...' : 'KAYDET',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSubMenuButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B0E11),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
