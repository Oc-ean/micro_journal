import 'package:flutter/material.dart';
import 'package:micro_journal/src/common/common.dart';

class CursiveMPainter extends CustomPainter {
  final Animation<double> progress;
  final BuildContext context;

  CursiveMPainter({required this.progress, required this.context})
      : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = context.theme.textTheme.titleMedium!.color!
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final startX = size.width * 0.1;
    final endX = size.width * 0.9;
    final midY = size.height * 0.5;
    final topY = size.height * 0.15;
    final bottomY = size.height * 0.85;

    path.moveTo(startX, bottomY);

    path.quadraticBezierTo(
      size.width * 0.15,
      topY,
      size.width * 0.3,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.35,
      bottomY,
      size.width * 0.5,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      topY,
      size.width * 0.7,
      midY,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      bottomY,
      endX,
      midY,
    );

    final metrics = path.computeMetrics().toList();
    final drawPath = Path();

    for (final metric in metrics) {
      final length = metric.length * progress.value;
      drawPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(drawPath, paint);
  }

  @override
  bool shouldRepaint(covariant CursiveMPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
