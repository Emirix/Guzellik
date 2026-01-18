import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/services/onboarding_preferences.dart';

/// Splash screen shown on app launch
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    // Wait for initialization (slightly longer than animation to feel smooth)
    await Future.delayed(const Duration(milliseconds: 2500));

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
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFDCAD2E);
    const Color brandPink = Color(0xFFD88C8C);
    const Color textColor = Color(0xFF2D2A26);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFFFFFFFF),
                  Color(0xFFFDF5F2),
                  Color(0xFFF7EBE1),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // Top Left Floral Pattern
          Positioned(
            top: -40,
            left: -40,
            width: 180,
            height: 180,
            child: Opacity(
              opacity: 0.15,
              child: SvgPicture.string(
                '''<svg fill="none" stroke="#dcad2e" stroke-width="0.5" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                  <path d="M10,90 Q40,40 90,10 M30,80 Q50,50 80,30 M50,70 Q60,60 70,50"></path>
                  <circle cx="90" cy="10" fill="#dcad2e" r="2"></circle>
                  <circle cx="80" cy="30" fill="#dcad2e" r="1.5"></circle>
                </svg>''',
              ),
            ),
          ),

          // Bottom Right Floral Pattern
          Positioned(
            bottom: -50,
            right: -50,
            width: 240,
            height: 240,
            child: Opacity(
              opacity: 0.15,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees
                child: SvgPicture.string(
                  '''<svg fill="none" stroke="#dcad2e" stroke-width="0.3" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
                    <path d="M50,90 C20,80 10,50 40,20 C60,40 90,50 50,90 Z"></path>
                    <path d="M45,85 C15,75 5,45 35,15"></path>
                    <path d="M55,85 C85,75 95,45 65,15"></path>
                  </svg>''',
                ),
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Glow
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withValues(alpha: 0.1),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    // Logo Container
                    Container(
                      width: 140,
                      height: 140,
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldColor.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: goldColor.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(
                        'assets/logo.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Brand Name
                Text(
                  'GÜZELLİK HARİTAM',
                  style: GoogleFonts.epilogue(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Tagline
                Text(
                  'Güzelliğin Modern Adresi'.toUpperCase(),
                  style: GoogleFonts.epilogue(
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 3.5,
                      color: brandPink.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Loading Section
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                children: [
                  // Elegant Loading Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 1.5,
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: goldColor.withValues(alpha: 0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              goldColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'YÜKLENİYOR',
                    style: GoogleFonts.epilogue(
                      textStyle: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                        color: goldColor.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
