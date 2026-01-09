import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/discovery_provider.dart';
import '../../../core/theme/app_colors.dart';

/// Harita önizleme kartı widget'ı
/// Ana sayfada kategorilerin altında gösterilir
/// Tıklandığında harita görünümüne geçiş yapar
class MapPreviewCard extends StatelessWidget {
  const MapPreviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiscoveryProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GestureDetector(
            onTap: () => provider.setViewMode(DiscoveryViewMode.map),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Harita arka plan görüntüsü
                    _buildMapBackground(),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                    // Harita Görünümü butonu ve konum (ortada)
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Harita Görünümü butonu
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.navigation_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Harita Görünümü',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Konum adı (ortada, butonun altında)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.currentLocationName,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  /// Harita arka plan görüntüsünü oluşturur
  Widget _buildMapBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE0EEE0), // Temel kara parçası rengi
      ),
      child: CustomPaint(painter: _MapPatternPainter(), size: Size.infinite),
    );
  }
}

/// Harita benzeri desen çizen gelişmiş custom painter
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..color = const Color(0xFFB2EBF2).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final mainRoadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final smallRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final buildingPaint = Paint()
      ..color = const Color(0xFFC8E6C9).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // 1. Su Alanı (Sol taraf veya bir köşe)
    final waterPath = Path();
    waterPath.moveTo(0, size.height * 0.2);
    waterPath.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.4,
      0,
      size.height * 0.8,
    );
    waterPath.lineTo(0, size.height);
    waterPath.lineTo(size.width * 0.3, size.height);
    waterPath.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.4,
      size.height * 0.5,
    );
    waterPath.quadraticBezierTo(
      size.width * 0.1,
      size.height * 0.3,
      0,
      size.height * 0.2,
    );
    canvas.drawPath(waterPath, waterPaint);

    // 2. Bloklar / Yapılar
    void drawBlock(double x, double y, double w, double h) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h),
          const Radius.circular(2),
        ),
        buildingPaint,
      );
    }

    // Izgara şeklinde bloklar yerleştirelim
    for (int i = 0; i < 6; i++) {
      for (int j = 0; j < 4; j++) {
        if ((i + j) % 3 == 0) continue;
        drawBlock(
          size.width * 0.4 + (i * 30),
          size.height * 0.1 + (j * 25),
          15,
          12,
        );
      }
    }

    // 3. Yollar (Katmanlı yapı)

    // Ana yollar
    final mainPaths = [
      Path()
        ..moveTo(0, size.height * 0.5)
        ..lineTo(size.width, size.height * 0.45),
      Path()
        ..moveTo(size.width * 0.5, 0)
        ..lineTo(size.width * 0.55, size.height),
      Path()
        ..moveTo(0, size.height * 0.1)
        ..quadraticBezierTo(size.width * 0.5, size.height * 0.2, size.width, 0),
    ];

    for (var path in mainPaths) {
      canvas.drawPath(path, mainRoadPaint);
    }

    // Ara yollar
    final smallPaths = [
      Path()
        ..moveTo(size.width * 0.3, 0)
        ..lineTo(size.width * 0.35, size.height),
      Path()
        ..moveTo(size.width * 0.7, 0)
        ..lineTo(size.width * 0.75, size.height),
      Path()
        ..moveTo(0, size.height * 0.3)
        ..lineTo(size.width, size.height * 0.25),
      Path()
        ..moveTo(0, size.height * 0.7)
        ..lineTo(size.width, size.height * 0.75),
      Path()
        ..moveTo(size.width * 0.4, size.height * 0.4)
        ..lineTo(size.width, size.height * 0.9),
    ];

    for (var path in smallPaths) {
      canvas.drawPath(path, smallRoadPaint);
    }

    // Pin Shadow
    final markerShadowPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.45),
      15,
      markerShadowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
