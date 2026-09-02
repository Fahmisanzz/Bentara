import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CameraOverlayPainter extends CustomPainter {
  final double scanAnimationValue;

  CameraOverlayPainter({this.scanAnimationValue = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = size.width * 0.76;
    final rectHeight = size.height * 0.48;
    final left = (size.width - rectWidth) / 2;
    final top = (size.height - rectHeight) / 2.8;

    final rect = Rect.fromLTWH(left, top, rectWidth, rectHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    // 1. Semi-transparent dark overlay outside the scanning box
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final innerPath = Path()..addRRect(rrect);
    final combinedPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(combinedPath, overlayPaint);

    // 2. Main rounded box border (Bentara Light Blue)
    final boxPaint = Paint()
      ..color = AppColors.lightBlue.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, boxPaint);

    // 3. Corner Brackets (Thicker solid highlights on 4 corners)
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 28.0;

    // Top-Left Corner
    canvas.drawLine(Offset(left, top + cornerLength), Offset(left, top + 16), cornerPaint);
    canvas.drawLine(Offset(left + 16, top), Offset(left + cornerLength, top), cornerPaint);

    // Top-Right Corner
    canvas.drawLine(Offset(left + rectWidth - cornerLength, top), Offset(left + rectWidth - 16, top), cornerPaint);
    canvas.drawLine(Offset(left + rectWidth, top + 16), Offset(left + rectWidth, top + cornerLength), cornerPaint);

    // Bottom-Left Corner
    canvas.drawLine(Offset(left, top + rectHeight - cornerLength), Offset(left, top + rectHeight - 16), cornerPaint);
    canvas.drawLine(Offset(left + 16, top + rectHeight), Offset(left + cornerLength, top + rectHeight), cornerPaint);

    // Bottom-Right Corner
    canvas.drawLine(Offset(left + rectWidth - cornerLength, top + rectHeight), Offset(left + rectWidth - 16, top + rectHeight), cornerPaint);
    canvas.drawLine(Offset(left + rectWidth, top + rectHeight - cornerLength), Offset(left + rectWidth, top + rectHeight - 16), cornerPaint);

    // 4. Animated Laser Line
    final laserY = top + (rectHeight * scanAnimationValue);
    final laserPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.lightBlue.withValues(alpha: 0.0),
          AppColors.lightBlue,
          AppColors.lightBlue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(left, laserY, rectWidth, 2.0))
      ..strokeWidth = 2.5;

    canvas.drawLine(Offset(left + 12, laserY), Offset(left + rectWidth - 12, laserY), laserPaint);
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return oldDelegate.scanAnimationValue != scanAnimationValue;
  }
}
