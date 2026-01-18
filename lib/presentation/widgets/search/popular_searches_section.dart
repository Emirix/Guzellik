import 'package:flutter/material.dart';
import '../../../data/models/popular_service.dart';

class PopularSearchesSection extends StatelessWidget {
  final List<PopularService> services;
  final bool isLoading;
  final Function(PopularService) onServiceTap;

  const PopularSearchesSection({
    super.key,
    required this.services,
    required this.isLoading,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading && services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Popüler Aramalar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (isLoading)
          _buildLoadingState()
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: services
                  .map(
                    (service) => _PopularChip(
                      service: service,
                      onTap: () => onServiceTap(service),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          6,
          (index) => Container(
            width: 80,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  final PopularService service;
  final VoidCallback onTap;

  const _PopularChip({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (service.icon != null) ...[
                _buildIcon(context, service.icon!),
                const SizedBox(width: 6),
              ],
              Text(
                service.name,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, String iconName) {
    // Map Material icon string to IconData
    IconData icon;
    switch (iconName) {
      case 'content_cut':
        icon = Icons.content_cut;
        break;
      case 'face':
        icon = Icons.face;
        break;
      case 'spa':
        icon = Icons.spa;
        break;
      case 'brush':
        icon = Icons.brush;
        break;
      case 'auto_awesome':
        icon = Icons.auto_awesome;
        break;
      case 'colorize':
        icon = Icons.colorize;
        break;
      case 'clean_hands':
        icon = Icons.clean_hands;
        break;
      case 'bolt':
        icon = Icons.bolt;
        break;
      case 'remove_red_eye':
        icon = Icons.remove_red_eye;
        break;
      default:
        icon = Icons.search;
    }
    return Icon(icon, size: 16, color: Theme.of(context).primaryColor);
  }
}
