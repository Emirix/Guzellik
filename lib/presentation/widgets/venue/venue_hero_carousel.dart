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
  // PERF: ValueNotifier kullanarak sadece gerekli widget'ları rebuild et
  late final ValueNotifier<int> _currentPageNotifier;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPageNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
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
            // Image carousel - RepaintBoundary ile izole et
            RepaintBoundary(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  // PERF: setState yerine ValueNotifier kullan - sadece badge ve dots rebuild olur
                  _currentPageNotifier.value = index;
                },
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return _buildImageItem(widget.imageUrls[index]);
                },
              ),
            ),

            // Gradient overlay at bottom - const yapılamaz ama RepaintBoundary ile izole et
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _GradientOverlay(),
            ),

            // Photo count badge - ValueListenableBuilder ile sadece bu rebuild olur
            if (widget.imageUrls.length > 1)
              Positioned(
                top: 16,
                right: 16,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${currentPage + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Pagination dots - ValueListenableBuilder ile sadece bu rebuild olur
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: ValueListenableBuilder<int>(
                  valueListenable: _currentPageNotifier,
                  builder: (context, currentPage, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                        (index) => _buildDot(index, currentPage),
                      ),
                    );
                  },
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
      // PERF: Placeholder'ı RepaintBoundary ile izole et
      // CircularProgressIndicator 60 FPS animasyon yapar
      placeholder: (context, url) => RepaintBoundary(
        child: Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildDot(int index, int currentPage) {
    final isActive = index == currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
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

// PERF: Gradient overlay'i const widget olarak ayır
class _GradientOverlay extends StatelessWidget {
  const _GradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
        ),
      ),
    );
  }
}
