import 'package:flutter/material.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';

class CircularImage extends StatelessWidget {
  const CircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    required this.imageUrl,
    this.backgroundColor,
    this.padding = Sizes.sm,
    this.isNetworkImage = false,
    this.fit = BoxFit.cover,
    this.overlayColor,
  });

  final BoxFit? fit;
  final double width, height, padding;
  final String imageUrl;
  final Color? overlayColor;
  final Color? backgroundColor;
  final bool isNetworkImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(color: backgroundColor),
      child: Center(
        child: Image(
          image:
              isNetworkImage
                  ? NetworkImage(imageUrl)
                  : AssetImage(imageUrl) as ImageProvider,
          fit: fit,
          color: overlayColor,
        ),
      ),
    );
  }
}
