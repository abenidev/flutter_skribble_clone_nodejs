import 'package:flutter/material.dart';

class TouchPoint {
  Paint paint;
  Offset points;
  TouchPoint({required this.paint, required this.points});

  Map<String, dynamic> toJson() {
    return {
      'point': {'dx': '${points.dx}', 'dy': '${points.dy}'}
    };
  }
}
