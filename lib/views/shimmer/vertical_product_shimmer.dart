import 'package:ecommerce_computer_client/views/shimmer/shimmer_effect.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';

class TVerticalProductShimmer extends StatelessWidget {
  const TVerticalProductShimmer({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return CustomGridLayout(
      itemCount: itemCount,
      itemBuilder:
          (_, __) => const SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Image placeholder
                TShimmerEffect (width: 180, height: 180),

                SizedBox(height: Sizes.spaceBtwItems),

                /// First line of text placeholder
                TShimmerEffect(width: 160, height: 15),


                /// Second (shorter) line of text placeholder
                TShimmerEffect(width: 110, height: 15),
              ],
            ),
          ),
    );
  }
}
