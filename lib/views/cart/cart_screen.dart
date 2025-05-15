import 'package:ecommerce_computer_client/consts/colors.dart';
import 'package:ecommerce_computer_client/consts/styles.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/checkout/checkout_screen.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:ecommerce_computer_client/widgets/circular_icon.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Cart',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: 6,
          separatorBuilder:
              (_, __) => const SizedBox(height: Sizes.spaceBtwSections),
          itemBuilder:
              (context, index) => Column(
                children: [
                  /// Product Image, Title, Price, Variant
                  Row(
                    children: [
                      /// Product Image
                      RoundedImage(
                        imageUrl: 'assets/images/user.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        padding: EdgeInsets.all(Sizes.sm),
                        backgroundColor: Colors.grey.shade200,
                      ),
                      const SizedBox(width: Sizes.spaceBtwItems),

                      /// Title, Price, Variant
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Brand name
                          Row(
                            children: [
                              Text(
                                'Dell',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: regular,
                                  color: darkFontGrey,
                                ),
                              ),
                              const SizedBox(width: Sizes.spaceBtwItems / 2),
                              Icon(
                                Iconsax.verify5,
                                color: Colors.blue,
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          /// Product name
                          Text(
                            'Dell Inspiron 15',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),

                          /// Variants
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Color ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Black ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: semibold,
                                    color: Colors.black,
                                  ),
                                ),

                                TextSpan(
                                  text: 'Storage ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                                TextSpan(
                                  text: '512GB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: semibold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  /// Quantity and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 76),
                          CircularIcon(
                            icon: Iconsax.minus,
                            width: 32,
                            height: 32,
                            size: Sizes.md,
                            color: darkFontGrey,
                            backgroundColor: Colors.grey.shade300,
                            onPressed: () {},
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          Text(
                            '2',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: semibold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          CircularIcon(
                            icon: Iconsax.add,
                            width: 32,
                            height: 32,
                            size: Sizes.md,
                            color: whiteColor,
                            backgroundColor: Colors.blue,
                            onPressed: () {},
                          ),
                        ],
                      ),

                      /// Price
                      Text(
                        '\$256',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: bold,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () => Get.to(() => CheckoutScreen()),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: TColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Checkout \$256.0',
          style: TextStyle(fontSize: 16, fontFamily: bold, color: whiteColor),
        ),
      ),
    );
  }
}
