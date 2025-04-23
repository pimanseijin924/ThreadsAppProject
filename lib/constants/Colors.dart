import 'package:flutter/material.dart';

Color borderColor(int rating) {
  switch (rating) {
    case 5:
      return Colors.red;
    case 4:
      return Colors.orange;
    case 3:
      return Colors.yellow;
    case 2:
      return Colors.green;
    case 1:
      return Colors.blue;
    default:
      return Colors.transparent;
  }
}
