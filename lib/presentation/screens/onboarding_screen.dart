import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_onboarding_provider.dart';
import '../widgets/onboarding/phone_mockup_frame.dart';
import '../widgets/onboarding/page_indicators.dart';
import '../widgets/onboarding/onboarding_navigation.dart';
import '../widgets/onboarding/screens/welcome_onboarding_content.dart';
import '../widgets/onboarding/screens/campaigns_onboarding_content.dart';
import '../widgets/onboarding/screens/map_onboarding_content.dart';
import '../widgets/onboarding/screens/filtering_onboarding_content.dart';
import '../widgets/onboarding/screens/appointment_onboarding_content.dart';
import '../widgets/onboarding/screens/favorites_onboarding_content.dart';
import '../../core/theme/app_colors.dart';

/// Premium onboarding screen with PhoneMockupFrame and sleek layouts
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final provider = context.read<AppOnboardingProvider>();
    if (!provider.isLastPage) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _onComplete() async {
    final provider = context.read<AppOnboardingProvider>();
    await provider.completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Consumer<AppOnboardingProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              // Background pattern or subtle gradient (optional)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),

                    // Top Section: Page Indicators
                    OnboardingPageIndicators(
                      totalPages: AppOnboardingProvider.totalPages,
                      currentIndex: provider.currentPage,
                    ),

                    const SizedBox(height: 30),

                    // Middle Section: Content & Phone Mockup
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: AppOnboardingProvider.totalPages,
                        onPageChanged: (index) {
                          provider.goToPage(index);
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                // Title and Description placeholders
                                Text(
                                  _getPageTitle(index),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _getPageDescription(index),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.gray600,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 40),

                                // The Phone Mockup containing the specific feature preview
                                Expanded(
                                  child: PhoneMockupFrame(
                                    child: _getPagePreview(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Section: Navigation
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: OnboardingNavigation(
                        onNext: _onNext,
                        onComplete: _onComplete,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper methods for content
  String _getPageTitle(int index) {
    const titles = [
      'Güzelliğinize Değer Katan Adresler',
      'Özel Fırsatları Kaçırmayın',
      'Yakınınızdaki Salonları Keşfedin',
      'Tam İstediğiniz Gibi Filtreleyin',
      'Randevunuzu Hemen Oluşturun',
      'Favorilerinizi Kaydedin',
    ];
    return titles[index];
  }

  String _getPageDescription(int index) {
    const descriptions = [
      'Türkiye\'nin en seçkin güzellik salonlarını keşfedin ve premium hizmetin tadını çıkarın.',
      'Size özel kampanyalardan anında haberdar olun, bütçenizi korurken şıklığınızı artırın.',
      'Harita üzerinden size en yakın salonları görün, puanlarını inceleyin ve yol tarifi alın.',
      'İstediğiniz hizmeti kategori, fiyat ve popülerliğe göre kolayca bulun.',
      'Telefonla uğraşmadan, dilediğiniz uzman ve saat için saniyeler içinde rezervasyon yapın.',
      'Sevdiğiniz salonları listenize ekleyin, favori uzmanlarınızın takvimini takip edin.',
    ];
    return descriptions[index];
  }

  Widget _getPagePreview(int index) {
    switch (index) {
      case 0:
        return const WelcomeOnboardingContent();
      case 1:
        return const CampaignsOnboardingContent();
      case 2:
        return const MapOnboardingContent();
      case 3:
        return const FilteringOnboardingContent();
      case 4:
        return const AppointmentOnboardingContent();
      case 5:
        return const FavoritesOnboardingContent();
      default:
        return const WelcomeOnboardingContent();
    }
  }
}
