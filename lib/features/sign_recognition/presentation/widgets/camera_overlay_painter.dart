import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CameraOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final rectWidth = size.width * 0.7;
    final rectHeight = size.height * 0.5;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, rectWidth, rectHeight),
      const Radius.circular(24),
    );

    // Draw the rounded rectangle
    canvas.drawRRect(rrect, paint);
    
    // Draw semi-transparent overlay outside the box
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
      
    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()..addRRect(rrect);
    final combinedPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    
    canvas.drawPath(combinedPath, overlayPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
