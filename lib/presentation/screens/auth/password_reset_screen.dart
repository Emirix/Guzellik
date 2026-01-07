import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Password reset screen
class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.resetPassword(
        _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          setState(() => _emailSent = true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Bir hata oluştu'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),

          // Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            'Şifremi Unuttum',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'E-posta adresinizi girin, size şifre sıfırlama linki gönderelim',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'E-posta',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'E-posta adresi gerekli';
              }
              if (!value.contains('@')) {
                return 'Geçerli bir e-posta adresi girin';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handlePasswordReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Şifre Sıfırlama Linki Gönder',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.send, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),

        // Success Icon
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.green[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.green[600],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Success Title
        Text(
          'E-posta Gönderildi!',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Success Message
        Text(
          'Şifre sıfırlama linki ${_emailController.text} adresine gönderildi. Lütfen e-postanızı kontrol edin.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        // Back to Login Button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Giriş Sayfasına Dön',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
