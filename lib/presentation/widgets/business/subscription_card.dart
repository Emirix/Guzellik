import 'package:flutter/material.dart';

/// Subscription card widget
/// Displays subscription details with progress bar
class SubscriptionCard extends StatelessWidget {
  final String subscriptionType;
  final String subscriptionName;
  final int daysRemaining;
  final DateTime? expiresAt;
  final bool isActive;

  const SubscriptionCard({
    super.key,
    required this.subscriptionType,
    required this.subscriptionName,
    required this.daysRemaining,
    this.expiresAt,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final progress = daysRemaining > 0
        ? (daysRemaining / 30).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFE8B4BC).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'AKTİF ABONELİK' : 'PASİF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? const Color(0xFFE8B4BC) : Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.verified,
                color: isActive ? const Color(0xFFE8B4BC) : Colors.grey,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subscription Name
          Text(
            subscriptionName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B0E11),
            ),
          ),
          const SizedBox(height: 8),

          // Days Remaining
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF6B6B6B),
              ),
              const SizedBox(width: 6),
              Text(
                daysRemaining > 0 ? '$daysRemaining Gün Kaldı' : 'Süresi Doldu',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B6B6B)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                daysRemaining < 7 ? Colors.orange : const Color(0xFFE8B4BC),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Renewal Date
          if (expiresAt != null)
            Text(
              'Yenileme Tarihi: ${_formatDate(expiresAt!)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B6B6B)),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
