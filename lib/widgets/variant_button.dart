import 'package:flutter/material.dart';

Widget VariantButton(String variant, bool isSelected) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.redAccent : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.red.shade700 : Colors.grey.shade400,
        ),
      ),
      child: Text(
        variant,
        style: TextStyle(fontSize: 14, color: isSelected ? Colors.white : null),
      ),
    ),
  );
}
