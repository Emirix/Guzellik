import 'package:flutter/material.dart';
import '../../presentation/providers/subscription_provider.dart';

/// Service responsible for managing feature access and gating
/// Provides utilities to check access and trigger UI feedback
class FeatureGatingService {
  final SubscriptionProvider subscriptionProvider;

  FeatureGatingService(this.subscriptionProvider);

  /// Check if a feature is accessible
  bool hasAccess(String feature) {
    if (subscriptionProvider.subscription == null) return false;
    return subscriptionProvider.subscription!.hasFeature(feature);
  }

  /// Get the limit for a specific feature key
  int getLimit(String feature, String limitKey) {
    if (subscriptionProvider.subscription == null) return 0;
    return subscriptionProvider.subscription!.getFeatureLimit(
      feature,
      limitKey,
    );
  }

  /// Helper to check if a feature is locked and potentially show a dialog
  /// Returns [true] if allowed, [false] if locked
  bool checkAndPrompt(
    BuildContext context,
    String feature, {
    String? customMessage,
  }) {
    if (hasAccess(feature)) return true;

    _showUpgradeDialog(context, feature, customMessage);
    return false;
  }

  /// Show a premium upgrade dialog
  void _showUpgradeDialog(
    BuildContext context,
    String feature,
    String? customMessage,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Premium Özellik'),
          ],
        ),
        content: Text(
          customMessage ??
              'Bu özellik seçtiğiniz üyelik paketinde bulunmuyor. Devam etmek için üyeliğinizi yükseltin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to store/subscription screen
              // context.push('/business/store');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37), // Gold
              foregroundColor: Colors.white,
            ),
            child: const Text('Üyeliği Yükselt'),
          ),
        ],
      ),
    );
  }
}
