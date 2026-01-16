import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

class BeforeAfterViewer extends StatefulWidget {
  final String beforeImageUrl;
  final String afterImageUrl;
  final String serviceName;
  final String? description;
  final VoidCallback? onClose;

  const BeforeAfterViewer({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    required this.serviceName,
    this.description,
    this.onClose,
  });

  @override
  State<BeforeAfterViewer> createState() => _BeforeAfterViewerState();
}

class _BeforeAfterViewerState extends State<BeforeAfterViewer> {
  double _sliderPosition = 0.5; // 0.0 = all before, 1.0 = all after
  bool _isVertical = false;
  bool _showMetadata = true;

  @override
  void initState() {
    super.initState();

    // Auto-hide metadata after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showMetadata = false;
        });
      }
    });
  }

  void _toggleMetadata() {
    setState(() {
      _showMetadata = !_showMetadata;
    });
  }

  void _toggleOrientation() {
    setState(() {
      _isVertical = !_isVertical;
    });
  }

  void _shareComparison() {
    Share.share(
      'Önce/Sonra Karşılaştırma\n${widget.serviceName}\n${widget.description ?? ""}\nÖnce: ${widget.beforeImageUrl}\nSonra: ${widget.afterImageUrl}',
      subject: '${widget.serviceName} - Önce/Sonra',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main comparison view
          GestureDetector(
            onTap: _toggleMetadata,
            child: Center(
              child: GestureDetector(
                onHorizontalDragUpdate: !_isVertical
                    ? (details) {
                        setState(() {
                          _sliderPosition =
                              (_sliderPosition +
                                      details.delta.dx /
                                          MediaQuery.of(context).size.width)
                                  .clamp(0.0, 1.0);
                        });
                      }
                    : null,
                onVerticalDragUpdate: _isVertical
                    ? (details) {
                        setState(() {
                          _sliderPosition =
                              (_sliderPosition +
                                      details.delta.dy /
                                          MediaQuery.of(context).size.height)
                                  .clamp(0.0, 1.0);
                        });
                      }
                    : null,
                child: _buildComparisonView(),
              ),
            ),
          ),

          // Top bar
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
                  colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed:
                        widget.onClose ?? () => Navigator.of(context).pop(),
                  ),
                  const Text(
                    'Önce / Sonra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isVertical ? Icons.swap_horiz : Icons.swap_vert,
                      color: Colors.white,
                    ),
                    onPressed: _toggleOrientation,
                  ),
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
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.serviceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.share,
                        label: 'Paylaş',
                        onTap: _shareComparison,
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

  Widget _buildComparisonView() {
    return Stack(
      children: [
        // After image (background)
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: widget.afterImageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.error, color: Colors.white, size: 64),
            ),
          ),
        ),

        // Before image (clipped)
        if (_isVertical)
          ClipRect(
            clipper: _VerticalClipper(_sliderPosition),
            child: Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.beforeImageUrl,
                fit: BoxFit.contain,
              ),
            ),
          )
        else
          ClipRect(
            clipper: _HorizontalClipper(_sliderPosition),
            child: Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: widget.beforeImageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),

        // Divider line and handle
        _buildDivider(),

        // Labels
        _buildLabels(),
      ],
    );
  }

  Widget _buildDivider() {
    return _isVertical
        ? Positioned(
            top: MediaQuery.of(context).size.height * _sliderPosition,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(height: 4, color: Colors.white),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.unfold_more, color: Colors.black),
                ),
              ],
            ),
          )
        : Positioned(
            left: MediaQuery.of(context).size.width * _sliderPosition,
            top: 0,
            bottom: 0,
            child: Row(
              children: [
                Container(width: 4, color: Colors.white),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.unfold_more, color: Colors.black),
                ),
              ],
            ),
          );
  }

  Widget _buildLabels() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('ÖNCE', Colors.red),
            _buildLabel('SONRA', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
}

// Custom clipper for horizontal comparison
class _HorizontalClipper extends CustomClipper<Rect> {
  final double position;

  _HorizontalClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * position, size.height);
  }

  @override
  bool shouldReclip(_HorizontalClipper oldClipper) {
    return oldClipper.position != position;
  }
}

// Custom clipper for vertical comparison
class _VerticalClipper extends CustomClipper<Rect> {
  final double position;

  _VerticalClipper(this.position);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width, size.height * position);
  }

  @override
  bool shouldReclip(_VerticalClipper oldClipper) {
    return oldClipper.position != position;
  }
}
