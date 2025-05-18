import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
import 'package:ecommerce_computer_client/controller/checkout_controller.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/address/address_screen.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CheckoutController controller = Get.put(CheckoutController());
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          'Checkout',
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
              // Cart Items
              ...cartController.cartItems.entries.map((entry) {
                final ProductModel product = entry.key;
                final int quantity = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                  child: Row(
                    children: [
                      RoundedImage(
                        imageUrl: product.thumbnail,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        padding: const EdgeInsets.all(Sizes.sm),
                        backgroundColor: Colors.grey.shade200,
                        isNetworkImage: true,
                      ),
                      const SizedBox(width: Sizes.spaceBtwItems),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  product.brand,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                                const SizedBox(width: Sizes.spaceBtwItems / 2),
                                const Icon(Iconsax.verify5, color: Colors.blue, size: 14),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '\$${(product.salePrice > 0 ? (product.price - product.price * (1 - product.salePrice)) : product.price).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: semibold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const TextSpan(text: '  x'),
                                  TextSpan(
                                    text: '$quantity',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: regular,
                                      color: darkFontGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Coupon
              RoundedContainer(
                showBorder: true,
                backgroundColor: whiteColor,
                padding: const EdgeInsets.only(
                  top: Sizes.sm,
                  bottom: Sizes.sm,
                  right: Sizes.sm,
                  left: Sizes.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Row(
                      children: [
                        Flexible(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text(
                              'Select a coupon',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            value: controller.selectedCouponCode.value.isEmpty
                                ? null
                                : controller.selectedCouponCode.value,
                            items: controller.availableCoupons.map((coupon) {
                              final remainingUses = coupon['maxUses'] - coupon['usedCount'];
                              return DropdownMenuItem<String>(
                                value: coupon['code'],
                                child: Text(
                                  '${coupon['code']} (-\$${coupon['discountAmount'].toStringAsFixed(0)}, $remainingUses uses left)',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.applyCoupon(value);
                              } else {
                                controller.removeCoupon();
                              }
                            },
                          ),
                        ),
                      ],
                    )),
                    Obx(() {
                      if (controller.couponError.value.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: Sizes.sm),
                          child: Text(
                            controller.couponError.value,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Loyalty Points
              RoundedContainer(
                showBorder: true,
                backgroundColor: whiteColor,
                padding: const EdgeInsets.all(Sizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Loyalty Points',
                          style: TextStyle(
                            fontFamily: bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() => Text(
                          'Available: ${controller.loyaltyPoints.value} points (\$${controller.loyaltyPoints.value})',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: regular,
                            color: darkFontGrey,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Points to Redeem',
                              border: OutlineInputBorder(),
                              hintText: 'Enter points to redeem',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final points = int.tryParse(value) ?? 0; // Parse as int
                              controller.applyLoyaltyPoints(points);
                            },
                          ),
                        ),
                        const SizedBox(width: Sizes.spaceBtwItems),
                        ElevatedButton(
                          onPressed: () {
                            final textField = context.findAncestorWidgetOfExactType<TextFormField>();
                            if (textField != null && textField.controller?.text.isNotEmpty == true) {
                              final points = int.tryParse(textField.controller!.text) ?? 0; // Parse as int
                              controller.applyLoyaltyPoints(points);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: Sizes.sm, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(fontSize: 16, color: whiteColor),
                          ),
                        ),
                      ],
                    ),
                    Obx(() {
                      if (controller.pointAmount.value > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: Sizes.sm),
                          child: Text(
                            'Loyalty Points Discount: ${controller.pointsToRedeem.value} points (\$${controller.pointAmount.value.toStringAsFixed(0)})',
                            style: const TextStyle(color: Colors.green, fontSize: 14),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Billing
              RoundedContainer(
                showBorder: true,
                backgroundColor: whiteColor,
                padding: const EdgeInsets.all(Sizes.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() => Text(
                          '\$${controller.subtotal.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tax (5%)',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() => Text(
                          '\$${controller.tax.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shipping Fee',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() => Text(
                          '\$${controller.shippingFee.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: regular,
                            color: Colors.black,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),
                    Obx(() {
                      if (controller.discountAmount.value > 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Coupon Discount',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '-\$${controller.discountAmount.value.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    Obx(() {
                      if (controller.pointAmount.value > 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Loyalty Points Discount',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '-\$${controller.pointAmount.value.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: Sizes.spaceBtwItems / 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: bold,
                            color: Colors.black,
                          ),
                        ),
                        Obx(() => Text(
                          '\$${controller.totalAmount.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: bold,
                            color: Colors.black,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    const Divider(color: Colors.grey, thickness: 1),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    // Shipping Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Shipping Address',
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Get.to(() => const AddressScreen());
                                controller.loadUserData(); // Update address after selection
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  fontFamily: regular,
                                  fontSize: 14,
                                  color: darkFontGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 1.5),
                        Obx(() => Text(
                          controller.recipientName.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: semibold,
                            color: Colors.black,
                          ),
                        )),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),
                        Obx(() => Row(
                          children: [
                            const Icon(
                              Iconsax.call,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems),
                            Text(
                              controller.phoneNumber.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontFamily: regular,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),
                        Obx(() => Row(
                          children: [
                            const Icon(
                              Iconsax.location,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems),
                            Flexible(
                              child: Text(
                                controller.shippingAddress.value,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: regular,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    // Payment Method
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(
                                fontFamily: bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.showPaymentMethodSheet(context);
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(
                                  fontFamily: regular,
                                  fontSize: 14,
                                  color: darkFontGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.spaceBtwItems / 2),
                        Obx(() => Row(
                          children: [
                            RoundedContainer(
                              width: 60,
                              height: 35,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.all(Sizes.sm),
                              child: Image(
                                image: AssetImage(controller.paymentImage.value),
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: Sizes.spaceBtwItems / 2),
                            Text(
                              controller.paymentMethod.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: semibold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => controller.placeOrder(),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColors.primary,
              padding: const EdgeInsets.symmetric(vertical: Sizes.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Place Order',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}