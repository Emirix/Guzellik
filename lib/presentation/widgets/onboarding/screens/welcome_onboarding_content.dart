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
          // Map Background - Light theme (Google Maps style)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF5F5F5), Color(0xFFE8E8E8)],
                ),
              ),
            ),
          ),

          // Map Roads and Streets Pattern
          CustomPaint(size: Size.infinite, painter: _MapPainter()),

          // Location Pins - Beauty Salons
          Positioned(top: 80, left: 60, child: _buildLocationPin()),
          Positioned(top: 160, right: 70, child: _buildLocationPin()),
          Positioned(bottom: 180, left: 80, child: _buildLocationPin()),
          Positioned(bottom: 120, right: 90, child: _buildLocationPin()),
          Positioned(top: 240, left: 140, child: _buildLocationPin()),
        ],
      ),
    );
  }

  Widget _buildLocationPin() {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: AppColors.white, size: 22),
      ),
    );
  }
}

/// Custom painter for map-style roads and streets
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final thinRoadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Main horizontal roads
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
      roadPaint,
    );

    // Main vertical roads
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.4, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );

    // Smaller streets (diagonal and curved)
    canvas.drawLine(
      Offset(0, size.height * 0.15),
      Offset(size.width, size.height * 0.25),
      thinRoadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.75),
      Offset(size.width, size.height * 0.85),
      thinRoadPaint,
    );

    // Area fills (parks, buildings)
    final areaPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.35,
        size.width * 0.2,
        size.height * 0.2,
      ),
      areaPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.15,
        size.height * 0.15,
      ),
      areaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
