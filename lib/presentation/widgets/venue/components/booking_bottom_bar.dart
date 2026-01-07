import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Fixed bottom bar with booking button
/// Displays total price (if available) and booking action button
class BookingBottomBar extends StatelessWidget {
  final VoidCallback onBookingTap;
  final double? totalPrice;
  final String? priceLabel;

  const BookingBottomBar({
    super.key,
    required this.onBookingTap,
    this.totalPrice,
    this.priceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          // Price Section (if available)
          if (totalPrice != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  priceLabel ?? 'Hizmet Başlangıç',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₺${totalPrice!.toStringAsFixed(0)}',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '/seans',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gray400,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
          ],

          // Booking Button
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onBookingTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 20, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Randevu Oluştur',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
