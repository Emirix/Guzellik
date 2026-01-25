import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// A reusable header component featuring the mascot and app name
class GuzellikHaritamHeader extends StatelessWidget {
  final bool showBottomBorder;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const GuzellikHaritamHeader({
    super.key,
    this.showBottomBorder = true,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: showBottomBorder
            ? const Border(
                bottom: BorderSide(color: AppColors.gray200, width: 1),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding ?? const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/maskot.png', width: 40, height: 40),
              const SizedBox(width: 12),
              Text(
                'Güzellik Haritam',
                style: GoogleFonts.outfit(
                  color: AppColors.primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
