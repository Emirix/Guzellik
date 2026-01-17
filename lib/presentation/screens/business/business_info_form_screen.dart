import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/business_onboarding_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Business information form screen
/// Collects business name and type before account conversion
class BusinessInfoFormScreen extends StatefulWidget {
  const BusinessInfoFormScreen({super.key});

  @override
  State<BusinessInfoFormScreen> createState() => _BusinessInfoFormScreenState();
}

class _BusinessInfoFormScreenState extends State<BusinessInfoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch categories when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessOnboardingProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<BusinessOnboardingProvider>();

    debugPrint('🔔 Handle Submit called');

    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      debugPrint('❌ No userId found in AuthProvider');
      _showError('Kullanıcı oturumu bulunamadı');
      return;
    }

    debugPrint('⌛ Calling convertToBusinessAccount...');
    final success = await onboardingProvider.convertToBusinessAccount(userId);
    debugPrint('🎯 Conversion result: $success');

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İşletme hesabınız başarıyla oluşturuldu!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Auth state will be automatically updated via listener
      // Navigate to business dashboard or venue setup
      if (mounted) {
        context.go('/business/admin');
      }
    } else {
      _showError(
        onboardingProvider.errorMessage ??
            'Bir hata oluştu. Lütfen tekrar deneyin.',
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B0E11)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'İşletme Bilgileri',
          style: TextStyle(
            color: Color(0xFF1B0E11),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<BusinessOnboardingProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'İşletme hesabınızı oluşturmak için aşağıdaki bilgileri doldurun',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6B6B6B),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Business Name Field
                  const Text(
                    'İşletme Adı',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B0E11),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(
                      hintText: 'Örn: Güzellik Merkezi',
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'İşletme adı gereklidir';
                      }
                      if (value.trim().length < 2) {
                        return 'İşletme adı en az 2 karakter olmalıdır';
                      }
                      if (value.trim().length > 100) {
                        return 'İşletme adı en fazla 100 karakter olabilir';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      provider.setBusinessName(value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Business Type Field
                  const Text(
                    'İşletme Türü',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B0E11),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (provider.isFetchingCategories)
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.categories.isEmpty)
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Kategoriler yüklenemedi',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      value: provider.businessType,
                      decoration: InputDecoration(
                        hintText: 'Seçiniz',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: provider.categories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'İşletme türü seçilmelidir';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        provider.setBusinessType(value);
                      },
                    ),
                  const SizedBox(height: 32),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '1 yıllık ücretsiz deneme süresi ile başlayacaksınız',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B0E11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              debugPrint('🔘 Button clicked');
                              debugPrint(
                                '📝 Form valid state: ${provider.isFormValid}',
                              );
                              debugPrint(
                                '🏷️ Category selected: ${provider.businessType}',
                              );
                              debugPrint(
                                '✍️ Name entered: ${provider.businessName}',
                              );

                              if (_formKey.currentState!.validate() &&
                                  provider.isFormValid) {
                                _handleSubmit();
                              } else if (!provider.isFormValid) {
                                _showError(
                                  provider.errorMessage ??
                                      'Lütfen tüm alanları doldurun',
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primary.withValues(
                          alpha: 0.5,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'İşletme Hesabını Oluştur',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
