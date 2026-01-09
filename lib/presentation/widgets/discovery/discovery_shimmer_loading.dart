import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Base shimmer mixin for discovery widgets
mixin ShimmerMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late AnimationController shimmerController;
  late Animation<double> shimmerAnimation;

  void initShimmer() {
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: shimmerController, curve: Curves.easeInOutSine),
    );
  }

  void disposeShimmer() {
    shimmerController.dispose();
  }

  Widget buildShimmerBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    double radius = 8,
  }) {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(shimmerAnimation.value - 1, 0),
              end: Alignment(shimmerAnimation.value + 1, 0),
              colors: [AppColors.gray100, AppColors.gray50, AppColors.gray100],
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer loading for Featured Venues section
class FeaturedVenuesShimmer extends StatefulWidget {
  const FeaturedVenuesShimmer({super.key});

  @override
  State<FeaturedVenuesShimmer> createState() => _FeaturedVenuesShimmerState();
}

class _FeaturedVenuesShimmerState extends State<FeaturedVenuesShimmer>
    with SingleTickerProviderStateMixin, ShimmerMixin {
  @override
  void initState() {
    super.initState();
    initShimmer();
  }

  @override
  void dispose() {
    disposeShimmer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildShimmerBox(width: 120, height: 20),
              buildShimmerBox(width: 80, height: 16),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 260,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildShimmerCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment(shimmerAnimation.value - 1, 0),
              end: Alignment(shimmerAnimation.value + 1, 0),
              colors: [AppColors.gray100, AppColors.gray50, AppColors.gray100],
            ),
          ),
          child: Stack(
            children: [
              // Bottom content area
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shimmer loading for Category Icons section
class CategoryIconsShimmer extends StatefulWidget {
  const CategoryIconsShimmer({super.key});

  @override
  State<CategoryIconsShimmer> createState() => _CategoryIconsShimmerState();
}

class _CategoryIconsShimmerState extends State<CategoryIconsShimmer>
    with SingleTickerProviderStateMixin, ShimmerMixin {
  @override
  void initState() {
    super.initState();
    initShimmer();
  }

  @override
  void dispose() {
    disposeShimmer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildShimmerBox(width: 100, height: 20),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildCategoryShimmer(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryShimmer() {
    return SizedBox(
      width: 80,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildShimmerBox(width: 64, height: 64, radius: 16),
          const SizedBox(height: 8),
          buildShimmerBox(width: 60, height: 12),
          const SizedBox(height: 4),
          buildShimmerBox(width: 40, height: 12),
        ],
      ),
    );
  }
}

/// Shimmer loading for Nearby Venues section
class NearbyVenuesShimmer extends StatefulWidget {
  final int itemCount;

  const NearbyVenuesShimmer({super.key, this.itemCount = 3});

  @override
  State<NearbyVenuesShimmer> createState() => _NearbyVenuesShimmerState();
}

class _NearbyVenuesShimmerState extends State<NearbyVenuesShimmer>
    with SingleTickerProviderStateMixin, ShimmerMixin {
  @override
  void initState() {
    super.initState();
    initShimmer();
  }

  @override
  void dispose() {
    disposeShimmer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildShimmerBox(width: 140, height: 20),
              buildShimmerBox(width: 80, height: 16),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: widget.itemCount,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _buildNearbyVenueShimmer(),
        ),
      ],
    );
  }

  Widget _buildNearbyVenueShimmer() {
    return AnimatedBuilder(
      animation: shimmerAnimation,
      builder: (context, child) {
        return Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment(shimmerAnimation.value - 1, 0),
                    end: Alignment(shimmerAnimation.value + 1, 0),
                    colors: [
                      AppColors.gray100,
                      AppColors.gray50,
                      AppColors.gray100,
                    ],
                  ),
                ),
              ),
              // Info placeholder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildShimmerBox(width: 150, height: 15),
                          const SizedBox(height: 6),
                          buildShimmerBox(width: 120, height: 12),
                        ],
                      ),
                      Row(
                        children: [
                          buildShimmerBox(width: 60, height: 14),
                          const Spacer(),
                          buildShimmerBox(width: 50, height: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
