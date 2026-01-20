import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/onboarding_preferences.dart';

/// Splash screen shown on app launch
/// Shows maskot image transitioning to Lottie animation with app branding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _maskotController;
  late AnimationController _lottieController;
  late AnimationController _titleController;
  late AnimationController _subtitleController;

  late Animation<double> _maskotFadeOut;
  late Animation<double> _lottieFadeIn;
  late Animation<double> _titleFadeIn;
  late Animation<double> _subtitleFadeIn;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    // Maskot fade-out animation (200ms)
    _maskotController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _maskotFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _maskotController, curve: Curves.easeOut),
    );

    // Lottie fade-in animation (300ms)
    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _lottieFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lottieController, curve: Curves.easeIn));

    // Title fade-in animation (800ms)
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _titleFadeIn = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    // Subtitle fade-in animation (800ms)
    _subtitleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _subtitleFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeOut),
    );
  }

  void _startAnimationSequence() async {
    // Wait 600ms then fade out maskot
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _maskotController.forward();

    // Wait for maskot fade-out to complete, then start Lottie
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _lottieController.forward();

    // Wait 500ms after Lottie starts, then show title
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _titleController.forward();

    // Wait 800ms after title starts, then show subtitle
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _subtitleController.forward();

    // Wait for subtitle animation to complete, then check navigation
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Check if user has seen onboarding
    final onboardingPrefs = OnboardingPreferences();
    final hasSeenOnboarding = await onboardingPrefs.hasSeenOnboarding();

    // Navigate based on onboarding status
    if (mounted) {
      if (hasSeenOnboarding) {
        // User has seen onboarding, go to home
        context.go('/');
      } else {
        // First time user, show onboarding
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _maskotController.dispose();
    _lottieController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA), // background-light
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation Container (Maskot + Lottie)
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Maskot Image (fades out)
                      AnimatedBuilder(
                        animation: _maskotFadeOut,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _maskotFadeOut.value,
                            child: Image.asset(
                              'assets/images/maskot.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          );
                        },
                      ),
                      // Lottie Animation (fades in)
                      AnimatedBuilder(
                        animation: _lottieFadeIn,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _lottieFadeIn.value,
                            child: Lottie.asset(
                              'assets/animations/splash.json',
                              width: 240,
                              height: 240,
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // App Title
                AnimatedBuilder(
                  animation: _titleFadeIn,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleFadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - _titleFadeIn.value)),
                        child: const Text(
                          'Güzellik Haritam',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B0D11),
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // App Subtitle
                AnimatedBuilder(
                  animation: _subtitleFadeIn,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _subtitleFadeIn.value,
                      child: Transform.translate(
                        offset: Offset(0, 10 * (1 - _subtitleFadeIn.value)),
                        child: const Text(
                          'Güzelliğinize Değer Katan Mekanlar',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
