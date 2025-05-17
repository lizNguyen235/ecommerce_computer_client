import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TShimmerEffect extends StatelessWidget {
  /// Chiều ngang và chiều cao của placeholder
  final double width;
  final double height;

  /// Bán kính bo góc (mặc định 15)
  final double radius;

  /// Màu nền thay thế (nếu không muốn dùng màu mặc định)
  final Color? color;

  const TShimmerEffect({
    Key? key,
    required this.width,
    required this.height,
    this.radius = 15,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra chế độ sáng/tối
    final bool isDark = HelperFunction.isDarkMode(context);

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? (isDark ? TColors.dark : whiteColor),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
