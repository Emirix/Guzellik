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
      color: AppColors.background,
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.subtitle2.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.subtitle2,
            tabs: const [
              Tab(text: 'Hizmetler'),
              Tab(text: 'Hakkında'),
              Tab(text: 'Yorumlar'),
              Tab(text: 'Uzmanlar'),
            ],
          ),
          Divider(height: 1, color: AppColors.gray100),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _VenueTabSwitcherDelegate oldDelegate) {
    return false;
  }
}
