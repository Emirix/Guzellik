import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../widgets/business/business_mode_dialog.dart';
import '../../../core/enums/business_mode.dart';

/// Login screen - Design based on design/login.html with navbar
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
      final emailOrPhone = _emailController.text.trim();
      final bool success;

      // Detect if input is phone number or email
      if (Validators.isPhoneNumber(emailOrPhone)) {
        // Phone login
        success = await authProvider.signInWithPhone(
          phone: emailOrPhone,
          password: _passwordController.text,
        );
      } else {
        // Email login
        success = await authProvider.signIn(
          email: emailOrPhone,
          password: _passwordController.text,
        );
      }

      if (mounted) {
        if (success) {
          // Check if profile is complete
          final isComplete = await authProvider.isProfileComplete();
          if (!mounted) return;

          if (!isComplete) {
            context.go(
              '/complete-profile${widget.redirectPath != null ? "?redirect=${widget.redirectPath}" : ""}',
            );
            return;
          }

          // Check if business account
          final userId = authProvider.currentUser?.id;
          if (userId != null) {
            final businessProvider = context.read<BusinessProvider>();
            final isBusinessAccount = await businessProvider
                .checkBusinessAccount(userId);

            if (isBusinessAccount && mounted) {
              // Show mode selection dialog
              final selectedMode = await BusinessModeSelectionDialog.show(
                context,
              );

              if (selectedMode != null && mounted) {
                await businessProvider.switchMode(selectedMode, userId);

                // Navigate based on selected mode
                if (selectedMode == BusinessMode.business) {
                  context.go('/business/subscription');
                } else {
                  context.go(widget.redirectPath ?? '/');
                }
                return;
              }
            }
          }

          // Navigate to redirect path or home (normal flow)
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

  Future<void> _handleGoogleLogin() async {
    final authProvider = context.read<AuthProvider>();

    // Start loading
    final success = await authProvider.signInWithGoogle();

    if (!mounted) return;

    if (success) {
      debugPrint('✅ Google Login Success - Checking profile completion...');

      // Check if profile is complete
      final isComplete = await authProvider.isProfileComplete();

      if (!mounted) return;

      if (!isComplete) {
        debugPrint(
          '⚠️ Profile incomplete - Redirecting to profile completion...',
        );
        context.go(
          '/complete-profile${widget.redirectPath != null ? "?redirect=${widget.redirectPath}" : ""}',
        );
        return;
      }

      debugPrint('✅ Profile complete - Checking business account...');

      // Check if business account
      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        final businessProvider = context.read<BusinessProvider>();
        final isBusinessAccount = await businessProvider.checkBusinessAccount(
          userId,
        );

        if (isBusinessAccount && mounted) {
          // Show mode selection dialog
          final selectedMode = await BusinessModeSelectionDialog.show(context);

          if (selectedMode != null && mounted) {
            await businessProvider.switchMode(selectedMode, userId);

            // Navigate based on selected mode
            if (selectedMode == BusinessMode.business) {
              context.go('/business/subscription');
            } else {
              context.go(widget.redirectPath ?? '/');
            }
            return;
          }
        }
      }

      // Navigate to redirect path or home (normal flow)
      if (widget.redirectPath != null) {
        context.go(widget.redirectPath!);
      } else {
        context.go('/');
      }
    } else {
      debugPrint('❌ Google Login Failed: ${authProvider.errorMessage}');
      if (authProvider.errorMessage != null &&
          authProvider.errorMessage != 'null') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF5F0), // Cream
              Color(0xFFFFE8E0), // Soft pink
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Mascot / Branding Area
                  Center(
                    child: Column(
                      children: [
                        // Mascot Image
                        Image.asset(
                          'assets/images/mascot/mascot_full.png',
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to SVG logo if mascot not found
                            return Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFE6D1D6),
                                  width: 2,
                                ),
                              ),
                              child: SvgPicture.asset(
                                'assets/logo-transparent.svg',
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Güzellik Haritam',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A574), // Gold color
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hoş Geldiniz',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF955062),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'E-posta veya Telefon',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B0E11),
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'isim@ornek.com veya 905XXXXXXXXX',
                          hintStyle: TextStyle(
                            color: const Color(
                              0xFF955062,
                            ).withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFF955062),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6D1D6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6D1D6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'E-posta veya telefon numarası gerekli';
                          }
                          // Allow both email and phone formats
                          final isPhone = Validators.isPhoneNumber(value);
                          final isEmail = value.contains('@');
                          if (!isPhone && !isEmail) {
                            return 'Geçerli bir e-posta veya telefon numarası girin';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Password Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Şifre',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
                            color: const Color(
                              0xFF955062,
                            ).withValues(alpha: 0.5),
                            fontSize: 14,
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
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6D1D6),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE6D1D6),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
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
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC5A059),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, Color(0xFFFF6B8A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
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
                  const SizedBox(height: 24),

                  // Social Login Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Color(0xFFE6D1D6))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VEYA',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(
                              0xFF955062,
                            ).withValues(alpha: 0.8),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider(color: Color(0xFFE6D1D6))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Google Login Button (Prominent)
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Container(
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFFE6D1D6),
                            width: 1.5,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1B0E11),
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 24,
                                      width: 24,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.g_mobiledata,
                                              size: 28,
                                              color: Color(0xFF1B0E11),
                                            );
                                          },
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Google ile Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
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
      ),
    );
  }
}
