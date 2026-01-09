import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/quote_request.dart';
import '../../../core/theme/app_colors.dart';

class QuoteCard extends StatelessWidget {
  final QuoteRequest quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final responseColor = quote.responseCount > 0
        ? AppColors.success
        : Colors.amber.shade700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/quote-detail', extra: quote),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(statusColor),
                    Text(
                      '#${quote.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray400,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  quote.services.map((s) => s.name).join(', '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      quote.preferredDate != null
                          ? '${DateFormat('d MMMM yyyy', 'tr_TR').format(quote.preferredDate!)}${quote.preferredTimeSlot != null ? ' • ${quote.preferredTimeSlot}' : ''}'
                          : 'Fark etmez',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: quote.responseCount > 0
                        ? Colors.green.shade50
                        : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            quote.responseCount > 0
                                ? Icons.check_circle_rounded
                                : Icons.hourglass_top_rounded,
                            size: 18,
                            color: responseColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            quote.responseCount > 0
                                ? '${quote.responseCount} Salon Teklif Verdi'
                                : 'Teklif Bekleniyor...',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: responseColor,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: responseColor.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (quote.status) {
      case QuoteStatus.active:
        return AppColors.success;
      case QuoteStatus.closed:
        return AppColors.gray400;
    }
  }

  Widget _buildStatusBadge(Color color) {
    final text = quote.status == QuoteStatus.active ? 'AÇIK' : 'KAPANDI';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
