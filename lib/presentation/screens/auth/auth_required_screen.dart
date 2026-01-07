import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// Screen shown when user tries to access a protected route without authentication
class AuthRequiredScreen extends StatelessWidget {
  /// Description of what feature requires auth
  final String requiredFor;

  /// Path to redirect to after successful login
  final String? redirectPath;

  const AuthRequiredScreen({
    super.key,
    required this.requiredFor,
    this.redirectPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Giriş Yapmanız Gerekiyor',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'Bu sayfayı görüntülemek için giriş yapmanız gerekmektedir',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to login with redirect path
                    if (redirectPath != null) {
                      context.go('/login?redirect=$redirectPath');
                    } else {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    context.go('/register');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Kayıt Ol',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
