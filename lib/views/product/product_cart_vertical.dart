import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/product/product_detail_screen.dart';
import 'package:ecommerce_computer_client/widgets/circular_icon.dart';
import 'package:ecommerce_computer_client/widgets/product_title_text.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProductCartVertical extends StatelessWidget {
  const ProductCartVertical({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ProductDetailScreen()),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          children: [
            RoundedContainer(
              height: 180,
              backgroundColor: TColors.light,
              child: Stack(
                children: [
                  /// Thumbnail
                  RoundedImage(
                    imageUrl: 'assets/images/p5.jpeg',
                    applyImageRadius: true,
                  ),

                  /// Sale tag
                  Positioned(
                    top: 12,
                    child: RoundedContainer(
                      radius: Sizes.sm,
                      backgroundColor: TColors.secondary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.sm,
                        vertical: Sizes.xs,
                      ),
                      child: Text(
                        '25%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  /// Favorite icon
                  const Positioned(
                    top: 0,
                    right: 0,
                    child: CircularIcon(
                      icon: Iconsax.heart5,
                      color: Colors.red,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),

            /// Details
            Padding(
              padding: const EdgeInsets.only(left: Sizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductTitleText(
                    title: 'Green Nike Air Shoes',
                    maxLines: 1,
                    smallSize: true,
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems / 2),
                  Row(
                    children: [
                      Text(
                        'Nike',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: semibold,
                          color: darkFontGrey,
                        ),
                      ),
                      const SizedBox(width: Sizes.xs),
                      const Icon(
                        Iconsax.verify5,
                        size: Sizes.iconXs,
                        color: TColors.primary,
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Price
                      Text(
                        '\$99.99',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: bold,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: TColors.dark,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Sizes.cardRadiusMd),
                            bottomRight: Radius.circular(
                              Sizes.productImageRadius,
                            ),
                          ),
                        ),
                        child: SizedBox(
                          width: Sizes.iconLg * 1.2,
                          height: Sizes.iconLg * 1.2,
                          child: const Icon(Iconsax.add, color: whiteColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
