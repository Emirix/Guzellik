import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/location_onboarding_provider.dart';
import '../../providers/auth_provider.dart';

class LocationServiceRequestBottomSheet extends StatelessWidget {
  const LocationServiceRequestBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Konum Servisiniz Kapalı',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.gray900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Message
          const Text(
            'Size en yakın güzellik merkezlerini gösterebilmemiz için konum servisinizi açmanızı öneririz.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Actions
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<LocationOnboardingProvider>();
              await provider.openLocationSettings();
              // After returning from settings, the user might have enabled it.
              // We'll handle the re-check in the screen.
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Cihaz Ayarlarını Aç',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              final onboardingProvider = context
                  .read<LocationOnboardingProvider>();
              final authProvider = context.read<AuthProvider>();

              Navigator.pop(context);

              // Fallback to profile location
              if (authProvider.isAuthenticated) {
                try {
                  final profile = await authProvider.getProfile();
                  if (profile != null) {
                    final int? provinceId = profile['province_id'] as int?;
                    final String? districtId =
                        profile['district_id'] as String?;

                    await onboardingProvider.useProfileLocation(
                      provinceId,
                      districtId,
                    );
                  } else {
                    onboardingProvider.showManualSelection();
                  }
                } catch (e) {
                  onboardingProvider.showManualSelection();
                }
              } else {
                onboardingProvider.showManualSelection();
              }
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              foregroundColor: AppColors.gray600,
            ),
            child: const Text(
              'Hayır, Manuel Seçmek İstiyorum',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
