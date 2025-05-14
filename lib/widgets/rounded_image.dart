import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:flutter/material.dart';

class RoundedImage extends StatelessWidget {
  const RoundedImage({
    super.key,
    this.width,
    this.height,
    this.imageUrl,
    this.applyImageRadius = false,
    this.border,
    this.backgroundColor,
    this.fit,
    this.padding,
    this.isNetworkImage = false,
    this.onPressed,
    this.borderRadius = Sizes.md,
  });

  final double? width, height;
  final String? imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: ClipRRect(
          borderRadius:
              applyImageRadius
                  ? BorderRadius.circular(borderRadius)
                  : BorderRadius.zero,
          child:
              isNetworkImage
                  ? Image.network(imageUrl!, fit: fit ?? BoxFit.cover)
                  : Image.asset(imageUrl!, fit: fit ?? BoxFit.cover),
        ),
      ),
    );
  }
}
