import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class VenueTabSwitcher extends StatelessWidget {
  final TabController tabController;

  const VenueTabSwitcher({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _VenueTabSwitcherDelegate(tabController),
    );
  }
}

class _VenueTabSwitcherDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;

  _VenueTabSwitcherDelegate(this.tabController);

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.nude, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.gray600,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          padding: const EdgeInsets.all(3),
          labelStyle: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'Hakkında'),
            Tab(text: 'Hizmetler'),
            Tab(text: 'Yorumlar'),
            Tab(text: 'Uzmanlar'),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _VenueTabSwitcherDelegate oldDelegate) {
    return false;
  }
}
