import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';

/// Content for the second onboarding screen: Campaigns
class CampaignsOnboardingContent extends StatefulWidget {
  const CampaignsOnboardingContent({super.key});

  @override
  State<CampaignsOnboardingContent> createState() =>
      _CampaignsOnboardingContentState();
}

class _CampaignsOnboardingContentState extends State<CampaignsOnboardingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: -10,
      end: 10,
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
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 300,
                  child: Lottie.asset(
                    'assets/animations/campaigns.json',
                    errorBuilder: (context, error, stackTrace) =>
                        _buildMockup(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockup(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mockup Campaign Card 1
            Transform.translate(
              offset: Offset(0, _animation.value),
              child: _buildCampaignCard(
                title: '%50 İndirim',
                subtitle: 'İlk Randevuna Özel',
                color: AppColors.primary,
                icon: Icons.local_offer_rounded,
                rotation: -0.05,
              ),
            ),
            const SizedBox(height: -30), // Overlap effect
            // Mockup Campaign Card 2
            Transform.translate(
              offset: Offset(0, -_animation.value),
              child: _buildCampaignCard(
                title: 'Ücretsiz Cilt Bakımı',
                subtitle: '3 Randevu Alana 1 Hediye',
                color: AppColors.gold,
                icon: Icons.card_giftcard_rounded,
                rotation: 0.05,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Size Özel Fırsatlar',
              style: TextStyle(
                color: AppColors.gray400,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCampaignCard({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required double rotation,
  }) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
