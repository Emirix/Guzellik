import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../data/models/venue.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class VenueHeroV2 extends StatelessWidget {
  final Venue venue;

  const VenueHeroV2({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gallery / main image
            Hero(
              tag: 'venue_image_${venue.id}',
              child: venue.imageUrl != null
                  ? Image.network(venue.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.gray200,
                      child: const Icon(
                        Icons.image,
                        size: 100,
                        color: AppColors.gray400,
                      ),
                    ),
            ),

            // Gradient Overlay (Bottom to Top)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0x99000000), Colors.transparent],
                  stops: [0.0, 0.4],
                ),
              ),
            ),

            // Pagination Dots
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: true),
                  _buildDot(isActive: false),
                  _buildDot(isActive: false),
                ],
              ),
            ),

            // Top Actions
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGlassButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.pop(context),
                    ),
                    Row(
                      children: [
                        _buildGlassButton(icon: Icons.favorite, onTap: () {}),
                        const SizedBox(width: 12),
                        _buildGlassButton(
                          icon: Icons.ios_share,
                          onTap: () {
                            Share.share(
                              '${venue.name}\n${venue.address}\n\nDaima uygulamasında keşfet!',
                              subject: venue.name,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(0.3),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}
