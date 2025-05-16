import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/success/success_screen.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: Text(
          'Order Review',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            children: [
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
                          Icon(Iconsax.verify5, color: Colors.blue, size: 14),
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

                      /// Quantity
                      Text.rich(
                        TextSpan(
                          text: 'x1',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: semibold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Sizes.spaceBtwSections),

              /// - Coupon Textfield
              RoundedContainer(
                showBorder: true,
                backgroundColor: whiteColor,
                padding: const EdgeInsets.only(
                  top: Sizes.sm,
                  bottom: Sizes.sm,
                  right: Sizes.sm,
                  left: Sizes.md,
                ),

                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Have a promo code? Enter here',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    // Button
                    SizedBox(
                      width: 80,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade50.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: Sizes.sm,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          foregroundColor: TColors.dark.withOpacity(0.5),
                          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),

              /// - Billing
              RoundedContainer(
                showBorder: true,
                backgroundColor: whiteColor,
                padding: const EdgeInsets.all(Sizes.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$256.0',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),

                    /// - Shipping Fee
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shipping Fee',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$6.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),

                    /// - Order Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '\$262.0',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: Sizes.spaceBtwItems),

                    /// - Payment Method
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Payment Method',
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: regular,
                                fontSize: 14,
                                color: darkFontGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),

                        Row(
                          children: [
                            RoundedContainer(
                              width: 60,
                              height: 35,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(Sizes.sm),
                              child: const Image(
                                image: AssetImage('assets/images/paypal.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems / 2),
                            Text(
                              'PayPal',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: semibold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),

                    /// - Shipping Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping Address',
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Change',
                              style: TextStyle(
                                fontFamily: regular,
                                fontSize: 14,
                                color: darkFontGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 1.5),
                        Text(
                          'Coding with Q',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: semibold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.call,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems),
                            Text(
                              '0123456789',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),
                        Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems),
                            Text(
                              '123 Main St, City, Country',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: ElevatedButton(
          onPressed:
              () => Get.to(
                () => SuccessScreen(
                  title: 'Payment Successful',
                  subtitle: 'Your order has been placed successfully.',
                  buttonText: 'Continue Shopping',
                  onPressed: () => Get.back(),
                ),
              ),
          style: ElevatedButton.styleFrom(
            backgroundColor: TColors.primary,
            padding: const EdgeInsets.symmetric(vertical: Sizes.md),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            'Pay Now',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
