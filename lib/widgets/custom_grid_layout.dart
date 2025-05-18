
import 'package:flutter/material.dart';

class CustomGridLayout extends StatelessWidget {
  const CustomGridLayout({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisExtent = 288,
    this.scrollController, ScrollController? controller,
  });

  final int itemCount;
  final int crossAxisCount;
  final double mainAxisExtent;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController ?? ScrollController(),
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: mainAxisExtent,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

