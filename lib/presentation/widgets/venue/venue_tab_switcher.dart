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
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.backgroundLight,
      alignment: Alignment.center,
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.nude),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.gray600,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          labelPadding: EdgeInsets.zero,
          labelStyle: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: AppTextStyles.subtitle2.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 13,
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
