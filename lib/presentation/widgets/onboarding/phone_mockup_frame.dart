import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// A premium phone mockup frame to showcase UI elements in onboarding
class PhoneMockupFrame extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const PhoneMockupFrame({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Determine dimensions based on layout
    final double deviceWidth = width ?? MediaQuery.of(context).size.width * 0.7;
    final double deviceHeight = height ?? deviceWidth * 2.0;
    const double borderRadius = 32.0;
    const double borderThickness = 8.0;

    return Center(
      child: Container(
        width: deviceWidth,
        height: deviceHeight,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: 5,
            ),
          ],
          border: Border.all(color: AppColors.gray800, width: 1),
        ),
        padding: const EdgeInsets.all(borderThickness),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius - borderThickness),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // The actual content (UI Mockup)
              child,

              // Camera/Speaker notch area
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: deviceWidth * 0.35,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Speaker
                      Container(
                        width: 30,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.gray800,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1A1A1A),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
