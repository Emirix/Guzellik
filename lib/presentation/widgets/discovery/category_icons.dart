import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({super.key});

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Saç', 'icon': Icons.content_cut, 'color': Color(0xFFFF6B9D)},
    {'name': 'Cilt Bakımı', 'icon': Icons.spa, 'color': Color(0xFF9C27B0)},
    {
      'name': 'Kaş-Kirpik',
      'icon': Icons.remove_red_eye,
      'color': Color(0xFFE91E63),
    },
    {'name': 'Makyaj', 'icon': Icons.brush, 'color': Color(0xFFFF5722)},
    {'name': 'Tırnak', 'icon': Icons.back_hand, 'color': Color(0xFFFF9800)},
    {'name': 'Estetik', 'icon': Icons.favorite, 'color': Color(0xFF00BCD4)},
    {
      'name': 'Masaj',
      'icon': Icons.self_improvement,
      'color': Color(0xFF4CAF50),
    },
    {'name': 'Spa', 'icon': Icons.hot_tub, 'color': Color(0xFF3F51B5)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Kategoriler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryIconItem(
                name: category['name'] as String,
                icon: category['icon'] as IconData,
                color: category['color'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }
}

class CategoryIconItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryIconItem({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        return GestureDetector(
          onTap: () {
            // Filter by category and switch to list view
            provider.updateFilter(provider.filter.copyWith(categories: [name]));
            provider.setViewMode(DiscoveryViewMode.list);
          },
          child: Container(
            width: 80,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
