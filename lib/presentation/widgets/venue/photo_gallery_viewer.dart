import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../data/models/venue_photo.dart';
import '../../../core/services/photo_actions_service.dart';

class PhotoGalleryViewer extends StatefulWidget {
  final List<VenuePhoto> photos;
  final int initialIndex;
  final String venueName;
  final Function(String photoId)? onLike;
  final Function(String photoId)? onDownload;

  const PhotoGalleryViewer({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    required this.venueName,
    this.onLike,
    this.onDownload,
  });

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showMetadata = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Auto-hide metadata after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMetadata = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  VenuePhoto get _currentPhoto => widget.photos[_currentIndex];

  void _toggleMetadata() {
    setState(() {
      _showMetadata = !_showMetadata;
    });
  }

  void _sharePhoto() {
    PhotoActionsService.sharePhoto(
      _currentPhoto.url,
      widget.venueName,
      title: _currentPhoto.title,
    );
  }

  Future<void> _downloadPhoto() async {
    final success = await PhotoActionsService.downloadPhoto(
      _currentPhoto.url,
      'photo_${_currentPhoto.id}.jpg',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Fotoğraf kaydedildi' : 'Kaydetme başarısız oldu',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }

    if (success && widget.onDownload != null) {
      widget.onDownload?.call(_currentPhoto.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo gallery
          GestureDetector(
            onTap: _toggleMetadata,
            child: PhotoViewGallery.builder(
              pageController: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              builder: (context, index) {
                final photo = widget.photos[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(photo.url),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 3,
                  heroAttributes: PhotoViewHeroAttributes(tag: photo.id),
                );
              },
              scrollPhysics: const BouncingScrollPhysics(),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => Shimmer.fromColors(
                baseColor: Colors.grey[900]!,
                highlightColor: Colors.grey[850]!,
                child: Container(
                  color: Colors.black,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // Top bar (close button, counter)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showMetadata ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),
          ),

          // Bottom metadata and actions
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _showMetadata ? 0 : -200,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Photo metadata
                  if (_currentPhoto.title != null)
                    Text(
                      _currentPhoto.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _currentPhoto.category.displayName,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _formatDate(_currentPhoto.uploadedAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'Paylaş',
                        onTap: _sharePhoto,
                      ),
                      _buildActionButton(
                        icon: Icons.download,
                        label: 'İndir',
                        onTap: _downloadPhoto,
                      ),
                      if (widget.onLike != null)
                        _buildActionButton(
                          icon: Icons.favorite_border,
                          label: '${_currentPhoto.likesCount}',
                          onTap: () => widget.onLike?.call(_currentPhoto.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} hafta önce';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else {
      return '${(difference.inDays / 365).floor()} yıl önce';
    }
  }
}
