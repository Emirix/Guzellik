import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Helper widget that throttles AnimatedBuilder rebuilds to reduce GPU work
class _ThrottledAnimatedBuilder extends StatefulWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;
  final Duration throttleInterval;

  const _ThrottledAnimatedBuilder({
    required this.animation,
    required this.builder,
    this.child,
    this.throttleInterval = const Duration(milliseconds: 66), // ~15 FPS
  });

  @override
  State<_ThrottledAnimatedBuilder> createState() =>
      _ThrottledAnimatedBuilderState();
}

class _ThrottledAnimatedBuilderState extends State<_ThrottledAnimatedBuilder> {
  DateTime? _lastRebuildTime;
  double? _lastAnimationValue;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.animation,
      builder: (context, child) {
        // Throttle rebuilds to reduce GPU work from 60 FPS to 15 FPS
        final now = DateTime.now();
        final shouldRebuild =
            _lastRebuildTime == null ||
            now.difference(_lastRebuildTime!) >= widget.throttleInterval;

        // Also check if animation value changed significantly
        final valueChanged =
            _lastAnimationValue == null ||
            (widget.animation.value - _lastAnimationValue!).abs() > 0.05;

        if (!shouldRebuild && !valueChanged) {
          return child!;
        }

        _lastRebuildTime = now;
        _lastAnimationValue = widget.animation.value;

        return widget.builder(context, child);
      },
      child: widget.child,
    );
  }
}

/// Helper widget that builds a shimmer box with throttled animation
class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double radius;
  final Animation<double> animation;

  const _ShimmerBox({
    this.width,
    this.height,
    this.borderRadius,
    this.radius = 8,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    // PERF: Wrap with RepaintBoundary to isolate shimmer repaints
    return RepaintBoundary(
      child: _ThrottledAnimatedBuilder(
        animation: animation,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(radius),
            color: AppColors.gray100,
          ),
        ),
        builder: (context, child) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment(animation.value - 1, 0),
                end: Alignment(animation.value + 1, 0),
                colors: const [
                  AppColors.gray100,
                  AppColors.gray50,
                  AppColors.gray100,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          );
        },
      ),
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addObserver(this);
    startAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAnimation();
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.repeat();
  }

  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _controller.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause animation when app is not visible to reduce GPU work
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAnimation();
    } else if (state == AppLifecycleState.resumed && mounted) {
      startAnimation();
    }
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
              _ShimmerBox(width: 120, height: 20, animation: _animation),
              _ShimmerBox(width: 80, height: 16, animation: _animation),
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
    return RepaintBoundary(
      child: _ThrottledAnimatedBuilder(
        animation: _animation,
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: AppColors.gray100,
          ),
        ),
        builder: (context, child) {
          return Container(
            width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment(_animation.value - 1, 0),
                end: Alignment(_animation.value + 1, 0),
                colors: const [
                  AppColors.gray100,
                  AppColors.gray50,
                  AppColors.gray100,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
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
      ),
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addObserver(this);
    startAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAnimation();
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.repeat();
  }

  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _controller.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAnimation();
    } else if (state == AppLifecycleState.resumed && mounted) {
      startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _ShimmerBox(width: 100, height: 20, animation: _animation),
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
          _ShimmerBox(width: 64, height: 64, radius: 16, animation: _animation),
          const SizedBox(height: 8),
          _ShimmerBox(width: 60, height: 12, animation: _animation),
          const SizedBox(height: 4),
          _ShimmerBox(width: 40, height: 12, animation: _animation),
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    WidgetsBinding.instance.addObserver(this);
    startAnimation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopAnimation();
    _controller.dispose();
    super.dispose();
  }

  void startAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;
    _controller.repeat();
  }

  void stopAnimation() {
    if (!_isAnimating) return;
    _isAnimating = false;
    _controller.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAnimation();
    } else if (state == AppLifecycleState.resumed && mounted) {
      startAnimation();
    }
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
              _ShimmerBox(width: 140, height: 20, animation: _animation),
              _ShimmerBox(width: 80, height: 16, animation: _animation),
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
    return RepaintBoundary(
      child: _ThrottledAnimatedBuilder(
        animation: _animation,
        child: Container(
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
        ),
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
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment(_animation.value - 1, 0),
                      end: Alignment(_animation.value + 1, 0),
                      colors: const [
                        AppColors.gray100,
                        AppColors.gray50,
                        AppColors.gray100,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
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
                            _ShimmerBox(
                              width: 150,
                              height: 15,
                              animation: _animation,
                            ),
                            const SizedBox(height: 6),
                            _ShimmerBox(
                              width: 120,
                              height: 12,
                              animation: _animation,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _ShimmerBox(
                              width: 60,
                              height: 14,
                              animation: _animation,
                            ),
                            const Spacer(),
                            _ShimmerBox(
                              width: 50,
                              height: 14,
                              animation: _animation,
                            ),
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
      ),
    );
  }
}
