import 'dart:math';
import 'package:flutter/material.dart';
import 'package:assignment/core/theme/app_colors.dart';

class BmiProgressRing extends StatelessWidget {
  final double bmi;
  final double size;

  const BmiProgressRing({
    super.key,
    required this.bmi,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    // Normal BMI scale maps from 15.0 (start) to 35.0 (end)
    const double minBmi = 15.0;
    const double maxBmi = 35.0;
    final double fraction = ((bmi - minBmi) / (maxBmi - minBmi)).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _BmiRingPainter(
              fraction: fraction,
              activeColor: AppColors.primary,
              inactiveColor: const Color(0xFFE5E7EB), // light gray background arc
              strokeWidth: 14.0,
            ),
          ),
          // Heart icon inside a light teal circle at the center of the progress ring
          Container(
            width: size * 0.45,
            height: size * 0.45,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite,
              color: AppColors.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _BmiRingPainter extends CustomPainter {
  final double fraction;
  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;

  _BmiRingPainter({
    required this.fraction,
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    // Draw 270 degree arc starting from bottom-left (135 degrees)
    const startAngle = 3 * pi / 4;
    const sweepAngle = 3 * pi / 2; // 270 degrees

    // Background track paint
    final paintBackground = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paintBackground,
    );

    // Active track paint (if fraction > 0)
    if (fraction > 0) {
      final paintActive = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * fraction,
        false,
        paintActive,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BmiRingPainter oldDelegate) {
    return oldDelegate.fraction != fraction ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
