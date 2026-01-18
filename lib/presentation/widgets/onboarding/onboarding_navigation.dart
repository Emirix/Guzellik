import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Navigation buttons for onboarding screen
class OnboardingNavigation extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onComplete;

  const OnboardingNavigation({
    super.key,
    required this.onNext,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppOnboardingProvider>(
      builder: (context, provider, _) {
        final bool isLast = provider.isLastPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isLast ? 200 : 70,
          height: 70,
          child: ElevatedButton(
            onPressed: isLast ? onComplete : onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLast ? 35 : 35),
              ),
              padding: EdgeInsets.zero,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: isLast
                  ? const Text(
                      'Hadi Başlayalım!',
                      key: ValueKey('cta_text'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios_rounded,
                      key: ValueKey('arrow_icon'),
                      size: 24,
                    ),
            ),
          ),
        );
      },
    );
  }
}
