import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
Widget ColorButton(Color color, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        if (isSelected) const Icon(Icons.check, size: 16, color: Colors.white),
      ],
    ),
  );
}
