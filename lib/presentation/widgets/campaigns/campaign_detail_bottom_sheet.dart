import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/campaign.dart';

/// Bottom sheet showing campaign details
class CampaignDetailBottomSheet extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailBottomSheet({super.key, required this.campaign});

  static Future<void> show(BuildContext context, Campaign campaign) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CampaignDetailBottomSheet(campaign: campaign),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campaign image
                  _buildImage(),
                  const SizedBox(height: 20),

                  // Discount badge
                  _buildDiscountBadge(),
                  const SizedBox(height: 16),

                  // Campaign title
                  Text(
                    campaign.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  if (campaign.description?.isNotEmpty == true) ...[
                    Text(
                      campaign.description!,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.gray700,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Validity period
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Geçerlilik Tarihi',
                    content: campaign.formattedDateRange,
                    trailing: campaign.isExpiringSoon
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${campaign.daysRemaining} gün kaldı',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Venue info
                  if (campaign.venue != null) ...[
                    _buildVenueCard(context),
                    const SizedBox(height: 24),
                  ],

                  // Action button
                  _buildActionButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: campaign.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: campaign.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(),
              errorWidget: (context, url, error) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryLight, AppColors.nudeLight],
        ),
      ),
      child: Icon(
        Icons.local_offer,
        size: 80,
        color: AppColors.primary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildDiscountBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFE91E63)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Text(
            campaign.formattedDiscount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'İNDİRİM',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildVenueCard(BuildContext context) {
    final venue = campaign.venue!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200, width: 1.5),
      ),
      child: Row(
        children: [
          // Venue image/icon
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: venue.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: venue.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.gray100,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: AppColors.gray100,
                      child: const Icon(Icons.store, color: AppColors.gray400),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: AppColors.gray100,
                    child: const Icon(Icons.store, color: AppColors.gray400),
                  ),
          ),
          const SizedBox(width: 12),

          // Venue info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: AppColors.gray500),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            if (campaign.venue != null) {
              context.push('/venue/${campaign.venueId}');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFE91E63)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'İşletmeye Git',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
