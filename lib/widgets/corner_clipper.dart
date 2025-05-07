import 'package:flutter/material.dart';

class CornerClipper extends CustomClipper<Path> {
  // 切り出す三角形の辺の長さ
  final double triangleSize;

  CornerClipper({this.triangleSize = 24.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    // 全体を一度矩形で確保(ClipRect 相当)
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    // 右上角に三角形を追加
    final triangle =
        Path()
          // 左下コーナーの頂点（0, size.height）
          ..moveTo(0, size.height)
          // 底辺の右端（triangleSize, size.height）
          ..lineTo(triangleSize, size.height)
          // 頂点の上側（0, size.height - triangleSize）
          ..lineTo(0, size.height - triangleSize)
          ..close();
    // 矩形から三角形領域を「差し引く」ためにevenOdd fillTypeを指定
    path.addPath(triangle, Offset.zero);
    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(covariant CornerClipper oldClipper) =>
      triangleSize != oldClipper.triangleSize;
}
