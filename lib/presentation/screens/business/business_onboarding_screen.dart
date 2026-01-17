import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/business_onboarding_provider.dart';
import '../../widgets/business/onboarding_step.dart';
import '../../../core/theme/app_colors.dart';

/// Business account onboarding carousel screen
/// Shows 4 steps explaining business account benefits
class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<BusinessOnboardingProvider>();
    _pageController = PageController(initialPage: provider.currentStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    final provider = context.read<BusinessOnboardingProvider>();
    if (page > provider.currentStep) {
      provider.nextStep();
    } else if (page < provider.currentStep) {
      provider.previousStep();
    }
  }

  void _handleNext() {
    final provider = context.read<BusinessOnboardingProvider>();
    if (provider.currentStep < BusinessOnboardingProvider.totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to business info form
      context.push('/business-info-form');
    }
  }

  void _handleSkip() {
    // Navigate directly to business info form
    context.push('/business-info-form');
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
        actions: [
          TextButton(
            onPressed: _handleSkip,
            child: const Text(
              'Atla',
              style: TextStyle(
                color: Color(0xFF6B6B6B),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Carousel
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              children: [
                // Step 1: Campaign Management
                OnboardingStep(
                  title: 'Kampanyalarınızı Yönetin',
                  description:
                      'Takipçilerinize özel kampanyalar oluşturun ve anında bildirim gönderin',
                  iconData: Icons.campaign,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),

                // Step 2: Analytics
                OnboardingStep(
                  title: 'Performansınızı Takip Edin',
                  description:
                      'Mekanınızın görüntülenme, takipçi ve değerlendirme istatistiklerini görün',
                  iconData: Icons.analytics,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),

                // Step 3: Team Management
                OnboardingStep(
                  title: 'Ekibinizi ve Hizmetlerinizi Yönetin',
                  description:
                      'Uzmanlarınızı ekleyin, hizmetlerinizi düzenleyin ve fiyatlandırma yapın',
                  iconData: Icons.groups,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),

                // Step 4: Premium Features
                OnboardingStep(
                  title: 'Premium Özelliklere Erişin',
                  description:
                      'Öne çıkan listeleme, öncelikli destek ve daha fazlası',
                  iconData: Icons.star,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gold,
                      AppColors.gold.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Dot indicators
          Consumer<BusinessOnboardingProvider>(
            builder: (context, provider, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    BusinessOnboardingProvider.totalSteps,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: provider.currentStep == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.currentStep == index
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Devam Et',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
