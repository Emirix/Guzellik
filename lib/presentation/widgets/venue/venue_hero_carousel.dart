import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class VenueHeroCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback? onTap;
  final double height;

  const VenueHeroCarousel({
    super.key,
    required this.imageUrls,
    this.onTap,
    this.height = 300,
  });

  @override
  State<VenueHeroCarousel> createState() => _VenueHeroCarouselState();
}

class _VenueHeroCarouselState extends State<VenueHeroCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return _buildPlaceholder();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            // Image carousel
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return _buildImageItem(widget.imageUrls[index]);
              },
            ),

            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            ),

            // Photo count badge
            if (widget.imageUrls.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            // Pagination dots
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.imageUrls.length,
                    (index) => _buildDot(index),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
      ),
    );
  }
}
