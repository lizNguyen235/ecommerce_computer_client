import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/product/product_reviews_screen.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:ecommerce_computer_client/widgets/circular_icon.dart';
import 'package:ecommerce_computer_client/widgets/color_button.dart';
import 'package:ecommerce_computer_client/widgets/curved_edges_widget.dart';
import 'package:ecommerce_computer_client/widgets/icon_button.dart';
import 'package:ecommerce_computer_client/widgets/product_price_text.dart';
import 'package:ecommerce_computer_client/widgets/product_title_text.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:ecommerce_computer_client/widgets/variant_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor, // Bottom section remains white
      /// Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.defaultSpace,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Sizes.cardRadiusLg),
            topRight: Radius.circular(Sizes.cardRadiusLg),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircularIcon(
                  width: 40,
                  height: 40,
                  icon: Icons.remove,
                  color: Colors.white,
                  backgroundColor: darkFontGrey.withOpacity(0.5),
                ),
                const SizedBox(width: Sizes.spaceBtwItems),
                Text(
                  '2',
                  style: TextStyle(
                    fontSize: 16,
                    color: darkFontGrey,
                    fontFamily: semibold,
                  ),
                ),
                const SizedBox(width: Sizes.spaceBtwItems),
                CircularIcon(
                  width: 40,
                  height: 40,
                  icon: Icons.add,
                  color: Colors.white,
                  backgroundColor: Colors.black.withOpacity(0.9),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.buttonRadius),
                ),
              ),
              onPressed: () {},
              child:
                  'Add to Cart'.text
                      .color(whiteColor)
                      .fontFamily(bold)
                      .size(16)
                      .make(),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1 - Product Image Slider
            TCurvedEdgesWidget(
              child: Container(
                color:
                    Colors.grey.shade50, // Lighter shade for the slider section
                child: Stack(
                  children: [
                    // Main Large Image
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: Image(image: AssetImage(imgP3))),
                      ),
                    ),

                    /// 2 - Product Image Slider
                    Positioned(
                      right: 0,
                      bottom: 30,
                      left: Sizes.defaultSpace,
                      child: SizedBox(
                        height: 80,
                        child: ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 12),
                          itemCount: 7,
                          itemBuilder:
                              (context, index) => RoundedImage(
                                width: 80,
                                backgroundColor: whiteColor,
                                border: Border.all(color: textfieldGrey),
                                padding: const EdgeInsets.all(Sizes.sm),
                                imageUrl: imgP3,
                              ),
                        ),
                      ),
                    ),

                    /// Appbar
                    TAppBar(
                      showBackArrow: true,
                      actions: [
                        CustomIconButton(
                          initialIcon: Icons.favorite_border_outlined,
                          alternateIcon: Icons.favorite,
                          iconColor: darkFontGrey,
                          backgroundColor: textfieldGrey,
                          padding: 2,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            /// 2 - Product Details
            Padding(
              padding: EdgeInsets.only(
                right: Sizes.defaultSpace,
                left: Sizes.defaultSpace,
                bottom: Sizes.defaultSpace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 2.1 - Rating and Share
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: Sizes.iconSm,
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems / 2),
                          Text.rich(
                            TextSpan(
                              text: "5.0",
                              style: TextStyle(
                                fontSize: 12,
                                color: darkFontGrey,
                                fontFamily: semibold,
                              ),
                              children: [
                                TextSpan(
                                  text: " (100)",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: darkFontGrey,
                                    fontFamily: regular,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      /// Share button
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share,
                          size: 20,
                          color: darkFontGrey,
                        ),
                      ),
                    ],
                  ),

                  /// 2.2 - Price, Title, Stock, Brand
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Price & Sale Price
                      Row(
                        children: [
                          /// Sale tag
                          RoundedContainer(
                            radius: Sizes.sm,
                            backgroundColor: Colors.yellow.shade600.withOpacity(
                              0.8,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: Sizes.xs,
                              horizontal: Sizes.sm,
                            ),
                            child: Text(
                              '25%',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: semibold,
                              ),
                            ),
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),

                          /// Price
                          Text(
                            '\$250',
                            style: TextStyle(
                              color: darkFontGrey,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: darkFontGrey,
                              fontFamily: semibold,
                            ),
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          ProductPriceText(price: '199', isLarge: true),
                        ],
                      ),
                      const SizedBox(width: Sizes.spaceBtwItems / 1.5),

                      /// Title
                      ProductTitleText(title: 'Asus ROG Strix G15'),
                      const SizedBox(width: Sizes.spaceBtwItems / 1.5),

                      /// Stock
                      Row(
                        children: [
                          ProductTitleText(title: 'Status:', smallSize: true),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          Text(
                            'In Stock',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontFamily: bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: Sizes.spaceBtwItems / 1.5),

                      /// Brand
                      Row(
                        children: [
                          Icon(
                            Icons.apple_outlined,
                            color: darkFontGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 16.0),

                          /// Brand Name
                          Text(
                            'Asus',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontFamily: semibold,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(
                            Iconsax.verify5,
                            color: Colors.blue.shade600,
                            size: 12,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),

                  /// 2.3 - Attributes
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -- Slected Attributes Pricing and Description
                      RoundedContainer(
                        padding: const EdgeInsets.all(Sizes.md),
                        backgroundColor: lightGrey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title, price, stock
                            Row(
                              children: [
                                'Variation'.text
                                    .color(Colors.black)
                                    .fontFamily(bold)
                                    .fontWeight(FontWeight.w700)
                                    .size(16)
                                    .make(),
                                const SizedBox(width: Sizes.spaceBtwItems),

                                /// Price
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        "Price:".text
                                            .color(darkFontGrey)
                                            .fontFamily(regular)
                                            .size(12)
                                            .make(),
                                        const SizedBox(
                                          width: Sizes.spaceBtwItems / 1.5,
                                        ),

                                        '\$250'.text
                                            .color(darkFontGrey)
                                            .fontFamily(semibold)
                                            .lineThrough
                                            .size(16)
                                            .make(),
                                        const SizedBox(
                                          width: Sizes.spaceBtwItems,
                                        ),

                                        /// Sale price
                                        '\$199'.text
                                            .color(Colors.black)
                                            .fontFamily(bold)
                                            .size(16)
                                            .make(),
                                      ],
                                    ),
                                    const SizedBox(width: Sizes.spaceBtwItems),

                                    /// Stock
                                    Row(
                                      children: [
                                        "Stock:".text
                                            .color(darkFontGrey)
                                            .fontFamily(regular)
                                            .size(12)
                                            .make(),

                                        const SizedBox(
                                          width: Sizes.spaceBtwItems / 1.5,
                                        ),

                                        'In Stock'.text
                                            .color(Colors.black)
                                            .fontFamily(semibold)
                                            .size(16)
                                            .make(),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            /// Variation Description
                            "This product is available in multiple colors and sizes and product is Goood, for you."
                                .text
                                .color(darkFontGrey)
                                .fontFamily(regular)
                                .size(12)
                                .maxLines(4)
                                .make(),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems),

                      /// -- Attibutes
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Colors Section
                          const Text(
                            'Colors',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ColorButton(Colors.green, true),
                              ColorButton(Colors.blue, false),
                              ColorButton(Colors.yellow, false),
                            ],
                          ),
                          const SizedBox(height: 16),

                          /// Variants Section
                          const Text(
                            'Variants',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              VariantButton('64GB', true),
                              VariantButton('128GB', false),
                              VariantButton('256GB', false),
                              VariantButton('512GB', false),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),

                  /// 2.4 - Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                        backgroundColor: Colors.red.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Sizes.buttonRadius,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          fontSize: 16,
                          color: whiteColor,
                          fontFamily: bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),

                  /// 2.5 - Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  ReadMoreText(
                    'This is a detailed description of the product. It includes all the features, specifications, and other important information that a customer might need to know before making a purchase decision.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Less',
                    moreStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    lessStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  /// 2.6 - Reviews
                  const Divider(),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews(100)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            () => Get.to(() => const ProductReviewsScreen()),
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
