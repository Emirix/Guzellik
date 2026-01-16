import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// PERFORMANS TESTİ: Animasyonsuz shimmer loading
/// Shimmer animasyonları lockHardwareCanvas'a sebep oluyor
/// Bu versiyon tamamen statik, animasyon yok
class SearchShimmerLoading extends StatelessWidget {
  final int itemCount;

  const SearchShimmerLoading({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    // PERF: Statik shimmer - animasyon yok, repaint yok
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder - statik
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildShimmerBox(width: 180, height: 20),
                    _buildShimmerBox(width: 60, height: 20),
                  ],
                ),
                const SizedBox(height: 8),
                // Location
                _buildShimmerBox(width: 140, height: 14),
                const SizedBox(height: 12),
                // Service tags
                Row(
                  children: [
                    _buildShimmerBox(width: 80, height: 28, radius: 10),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 70, height: 28, radius: 10),
                    const SizedBox(width: 8),
                    _buildShimmerBox(width: 60, height: 28, radius: 10),
                  ],
                ),
                const SizedBox(height: 14),
                // Bottom row
                Row(
                  children: [
                    Expanded(child: _buildShimmerBox(height: 44, radius: 12)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildShimmerBox(height: 44, radius: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({double? width, double? height, double radius = 8}) {
    // PERF: Statik box - gradient yok, animasyon yok
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
