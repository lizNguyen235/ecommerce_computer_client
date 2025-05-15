import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:flutter/material.dart';

class CircularIcon extends StatelessWidget {
  const CircularIcon({
    super.key,
    this.width,
    this.height,
    this.size = Sizes.lg,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.onPressed,
  });

  final double? width, height, size;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color:
            backgroundColor != null
                ? backgroundColor!
                : Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: IconButton(
        icon: Icon(icon, size: size, color: color ?? Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
