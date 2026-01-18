import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

class MapMarkerUtils {
  /// Creates a Google Maps style teardrop marker with a category icon
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String label, {
    bool isActive = false,
    IconData? categoryIcon,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    // Size for the marker
    const double width = 120.0;
    const double height = 150.0;

    final center = Offset(width / 2, width / 2);
    final double radius = width * 0.4;

    // Pin Color (Google uses specific colors for categories, beauty/health is usually magenta/pink)
    final Color pinColor = isActive
        ? const Color(0xFFC2185B)
        : AppColors.primary;

    // 1. Draw Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final Path shadowPath = Path();
    shadowPath.moveTo(width / 2, height - 10);
    shadowPath.conicTo(
      width / 2 + 25,
      height - 40,
      width / 2 + radius,
      width / 2,
      1,
    );
    shadowPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      0,
      -3.14159,
      false,
    );
    shadowPath.conicTo(width / 2 - 25, height - 40, width / 2, height - 10, 1);
    canvas.drawPath(shadowPath.shift(const Offset(0, 4)), shadowPaint);

    // 2. Draw Teardrop Pin Shape
    final Paint pinPaint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill;

    final Path pinPath = Path();
    pinPath.moveTo(width / 2, height - 10);
    // Right side of the pin
    pinPath.conicTo(
      width / 2 + 25,
      height - 40,
      width / 2 + radius,
      width / 2,
      1,
    );
    // Top circle part
    pinPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      0,
      -3.14159,
      false,
    );
    // Left side of the pin
    pinPath.conicTo(width / 2 - 25, height - 40, width / 2, height - 10, 1);
    canvas.drawPath(pinPath, pinPaint);

    // 3. Draw a small dot at the bottom tip (optional, Google sometimes has it)
    final Paint tipPaint = Paint()..color = Colors.black.withValues(alpha: 0.1);
    canvas.drawCircle(Offset(width / 2, height - 10), 4, tipPaint);

    // 4. Draw White Circle for Icon
    final Paint circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.7, circlePaint);

    // 5. Draw Category Icon in the middle of the white circle
    if (categoryIcon != null) {
      final TextPainter iconPainter = TextPainter(
        textDirection: TextDirection.ltr,
      );

      iconPainter.text = TextSpan(
        text: String.fromCharCode(categoryIcon.codePoint),
        style: TextStyle(
          fontSize: radius * 0.9, // Size based on the circle
          fontFamily: categoryIcon.fontFamily,
          package: categoryIcon.fontPackage,
          color: pinColor, // Icon color matches pin color
        ),
      );

      iconPainter.layout();
      iconPainter.paint(
        canvas,
        Offset(
          center.dx - iconPainter.width / 2,
          center.dy - iconPainter.height / 2,
        ),
      );
    }

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      height.toInt(),
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(data!.buffer.asUint8List());
  }

  /// Keep the simple marker for other uses if needed
  static Future<BitmapDescriptor> createSimpleMarkerBitmap({
    required IconData icon,
    bool isActive = false,
  }) async {
    // Re-use the main logic but smaller or simpler
    return createCustomMarkerBitmap("", isActive: isActive, categoryIcon: icon);
  }
}
