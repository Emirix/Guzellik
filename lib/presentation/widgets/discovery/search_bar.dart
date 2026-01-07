import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'filter_bottom_sheet.dart';

class DiscoverySearchBar extends StatelessWidget {
  const DiscoverySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.white),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: AppColors.secondary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                context.read<DiscoveryProvider>().setSearchQuery(value);
              },
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.gray900,
              ),
              decoration: const InputDecoration(
                hintText: 'Mekan, hizmet veya bölge ara...',
                hintStyle: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Container(height: 24, width: 1, color: AppColors.nudeDark),
          IconButton(
            icon: const Icon(Icons.tune, color: AppColors.secondary, size: 22),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const FilterBottomSheet(),
              );
            },
          ),
        ],
      ),
    );
  }
}
