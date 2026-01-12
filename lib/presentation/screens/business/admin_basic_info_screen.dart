import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    String cleanInstagram(String value) {
      String clean = value.trim();
      if (clean.contains('instagram.com/')) {
        clean = clean.split('instagram.com/').last;
      }
      if (clean.startsWith('@')) {
        clean = clean.substring(1);
      }
      if (clean.contains('?')) {
        clean = clean.split('?').first;
      }
      if (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      return clean;
    }

    try {
      await provider.updateBasicInfo(
        venueId: venueId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        socialLinks: {
          'instagram': cleanInstagram(_instagramController.text),
          'whatsapp': _whatsappController.text.trim(),
          'facebook': _facebookController.text.trim(),
          'website': _websiteController.text.trim(),
        },
      );

      if (mounted) {
        _showSnackBar('Değişiklikler başarıyla kaydedildi');
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
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
          'Temel Bilgiler',
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
      body: Consumer<AdminBasicInfoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.venueData == null) {
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
                  _buildSectionTitle('Görünüm ve Tanıtım'),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _nameController,
                          label: 'İşletme Adı',
                          hint: 'Örn: Hair Salon Vibe',
                          icon: Icons.storefront_rounded,
                          validator: (v) =>
                              v?.isEmpty == true ? 'Zorunlu alan' : null,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildInputField(
                          controller: _descriptionController,
                          label: 'Hakkında',
                          hint: 'İşletmenizi kısaca tanıtın...',
                          icon: Icons.subject_rounded,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('İletişim Kanalları'),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Telefon Numarası',
                          hint: '+90 5xx ...',
                          icon: Icons.phone_iphone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildInputField(
                          controller: _emailController,
                          label: 'E-Posta Adresi',
                          hint: 'hello@isletme.com',
                          icon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Sosyal Medya & Web'),
                  const SizedBox(height: 16),
                  _buildCard(
                    child: Column(
                      children: [
                        _buildInputField(
                          controller: _instagramController,
                          label: 'Instagram Kullanıcı Adı',
                          hint: 'kullanici_adi',
                          icon: FontAwesomeIcons.instagram,
                          isFa: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildInputField(
                          controller: _whatsappController,
                          label: 'WhatsApp Hattı',
                          hint: '+90 5xx ...',
                          icon: FontAwesomeIcons.whatsapp,
                          isFa: true,
                          keyboardType: TextInputType.phone,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1),
                        ),
                        _buildInputField(
                          controller: _websiteController,
                          label: 'Web Sitesi',
                          hint: 'www.isletme.com',
                          icon: Icons.language_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
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
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isFa = false,
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
                  color: AppColors.primary.withOpacity(0.8),
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
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
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
            : const Text(
                'AYARLARI GÜNCELLE',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
