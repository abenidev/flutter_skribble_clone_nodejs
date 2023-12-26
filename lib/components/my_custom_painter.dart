import 'package:flutter/material.dart';
import 'package:scribble_clone/constants/constants.dart';
import 'package:scribble_clone/models/touch_point.dart';
import 'dart:ui';

class MyCustomPainter extends CustomPainter {
  MyCustomPainter({required this.pointsList});
  List<TouchPoint> pointsList;
  List<Offset> offsetPoints = [];

  @override
  void paint(Canvas canvas, Size size) {
    Paint background = Paint();
    background.color = Colors.white;
    Rect rect = Rect.fromLTWH(0, 0, size.width > paintBoxWidth ? paintBoxWidth : size.width, size.height);
    canvas.drawRect(rect, background);
    canvas.clipRect(rect);

    //
    for (int i = 0; i < pointsList.length - 1; i++) {
      // if (pointsList[i] != null && pointsList[i + 1] != null) {
      // This is a line
      canvas.drawLine(pointsList[i].points, pointsList[i + 1].points, pointsList[i].paint);
      // } else if (pointsList[i] != null && pointsList[i + 1] == null) {
      // This is a point
      offsetPoints.clear();
      offsetPoints.add(pointsList[i].points);
      offsetPoints.add(Offset(pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));

      canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      // }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
