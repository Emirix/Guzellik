import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_onboarding_provider.dart';

/// Main onboarding screen with PageView
/// Shows 6 onboarding pages to introduce app features
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AppOnboardingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // PageView (placeholder for now)
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: AppOnboardingProvider.totalPages,
                    onPageChanged: (index) {
                      provider.goToPage(index);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Onboarding Page ${index + 1}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Page ${index + 1} of ${AppOnboardingProvider.totalPages}',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators (placeholder)
                      Row(
                        children: List.generate(
                          AppOnboardingProvider.totalPages,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: provider.currentPage == index ? 12 : 8,
                            height: provider.currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: provider.currentPage == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),

                      // Next/Complete button
                      ElevatedButton(
                        onPressed: () async {
                          if (provider.isLastPage) {
                            // Complete onboarding
                            await provider.completeOnboarding();
                            if (context.mounted) {
                              context.go('/');
                            }
                          } else {
                            // Go to next page
                            provider.nextPage();
                            _pageController.animateToPage(
                              provider.currentPage,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Text(
                          provider.isLastPage ? 'Hadi Başlayalım!' : 'İleri',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
