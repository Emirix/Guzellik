import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

/// Content for the first onboarding screen: Welcome
class WelcomeOnboardingContent extends StatefulWidget {
  const WelcomeOnboardingContent({super.key});

  @override
  State<WelcomeOnboardingContent> createState() =>
      _WelcomeOnboardingContentState();
}

class _WelcomeOnboardingContentState extends State<WelcomeOnboardingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Stack(
        children: [
          // Background subtle gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.05),
                    AppColors.white,
                  ],
                ),
              ),
            ),
          ),

          // Main content: Lottie and Logo preview
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie Animation Placeholder
                SizedBox(
                  height: 250,
                  child: Lottie.asset(
                    'assets/animations/welcome.json',
                    errorBuilder: (context, error, stackTrace) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _animation,
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 100,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Güzellik Haritam',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Pulsing glowing background for the icon
                ScaleTransition(
                  scale: _animation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
