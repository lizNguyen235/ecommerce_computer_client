import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:flutter/material.dart';

class CustomGridLayout extends StatelessWidget {
  const CustomGridLayout({
    super.key,
    required this.itemCount,
    this.mainAxisExtent = 288,
    required this.itemBuilder,
  });

  final int itemCount;
  final double? mainAxisExtent;
  final Widget? Function(BuildContext, int) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
