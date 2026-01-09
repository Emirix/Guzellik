import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Shimmer loading effect for search results
/// Provides skeleton loading cards while data is being fetched
class SearchShimmerLoading extends StatefulWidget {
  final int itemCount;

  const SearchShimmerLoading({super.key, this.itemCount = 3});

  @override
  State<SearchShimmerLoading> createState() => _SearchShimmerLoadingState();
}

class _SearchShimmerLoadingState extends State<SearchShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
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
              // Image placeholder
              _buildShimmerBox(
                height: 180,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
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
                        Expanded(
                          child: _buildShimmerBox(height: 44, radius: 12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildShimmerBox(height: 44, radius: 12),
                        ),
                      ],
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

  Widget _buildShimmerBox({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [AppColors.gray100, AppColors.gray50, AppColors.gray100],
        ),
      ),
    );
  }
}
