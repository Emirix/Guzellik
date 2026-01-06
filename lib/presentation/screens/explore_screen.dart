import 'package:flutter/material.dart';
import '../widgets/common/custom_header.dart';

/// Explore screen - Map-based venue discovery
class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomHeader(
            title: 'Keşfet',
            subtitle: 'Yakınınızdaki mekanları keşfedin',
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.explore,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keşfet Ekranı',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Harita tabanlı mekan keşfi burada görünecek',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
