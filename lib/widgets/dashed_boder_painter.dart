import 'package:flutter/material.dart';

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    final dashWidth = 5;
    final dashSpace = 5;
    double currentX = 0;

    // 上部の線
    while (currentX < size.width) {
      path.moveTo(currentX, 0);
      path.lineTo(currentX + dashWidth, 0);
      currentX += dashWidth + dashSpace;
    }

    // 他の3辺も同様に実装...

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
