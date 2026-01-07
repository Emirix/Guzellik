import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Login screen - Design based on design/login.html
class LoginScreen extends StatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          // Navigate to redirect path or home
          if (widget.redirectPath != null) {
            context.go(widget.redirectPath!);
          } else {
            context.go('/');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Giriş başarısız'),
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
      backgroundColor: const Color(0xFFF8F6F6),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 24),
                      onPressed: () => context.pop(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // Logo / Branding Area
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE6D1D6),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.spa,
                                size: 48,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B0E11),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Güzellik dünyasına tekrar hoş geldiniz',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF955062),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email/Phone Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'E-posta veya Telefon Numarası',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B0E11),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'isim@ornek.com',
                              hintStyle: TextStyle(
                                color: const Color(0xFF955062).withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF955062),
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D1D6),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D1D6),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
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
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Password Input
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'Şifre',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B0E11),
                              ),
                            ),
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                color: const Color(0xFF955062).withOpacity(0.6),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outlined,
                                color: Color(0xFF955062),
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF955062),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D1D6),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE6D1D6),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre gerekli';
                              }
                              if (value.length < 6) {
                                return 'Şifre en az 6 karakter olmalı';
                              }
                              return null;
                            },
                          ),
                          // Forgot Password Link
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/password-reset'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Şifremi Unuttum?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFC5A059),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          return SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 0,
                                shadowColor: AppColors.primary.withOpacity(0.2),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Giriş Yap',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 20),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Social Login Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFE6D1D6)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'VEYA ŞUNUNLA DEVAM ET',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF955062).withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFE6D1D6)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Social Buttons (UI only, disabled)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(Icons.g_mobiledata, 'Google'),
                          const SizedBox(width: 16),
                          _buildSocialButton(Icons.apple, 'Apple'),
                          const SizedBox(width: 16),
                          _buildSocialButton(Icons.facebook, 'Facebook'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Footer Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabın yok mu?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B0E11),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return Opacity(
      opacity: 0.5, // Disabled appearance
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE6D1D6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 28, color: const Color(0xFF1B0E11)),
      ),
    );
  }
}
