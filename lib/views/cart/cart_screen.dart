import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/address_controller.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/checkout/checkout_screen.dart';
import 'package:ecommerce_computer_client/widgets/circular_icon.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();
    final ProductController productController = Get.find<ProductController>();
    // Initialize AddressController to ensure it's available for CheckoutController
    Get.put(AddressController());

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
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 18,
                fontFamily: bold,
                color: darkFontGrey,
              ),
            ),
          );
        }

        final cartEntries = cartController.cartItems.entries.toList();

        return Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: cartEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: Sizes.spaceBtwSections),
            itemBuilder: (context, index) {
              final ProductModel product = cartEntries[index].key;
              final int quantity = cartEntries[index].value;
              // Tính giá sale dựa trên phần trăm giảm giá
              final double itemPrice = productController.calculateSalePrice(
                product.price,
                product.salePrice,
              );

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icon(
                                  Iconsax.verify5,
                                  color: Colors.blue,
                                  size: 14,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: bold,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Iconsax.trash,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  style: IconButton.styleFrom(
                                    padding: const EdgeInsets.all(4),
                                    backgroundColor: Colors.red.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: Text('Are you sure you want to remove ${product.title} from cart?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      cartController.removeFromCart(product);
                                      Get.snackbar(
                                        'Deleted',
                                        '${product.title} has been removed from cart',
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red.shade500,
                                        colorText: whiteColor,
                                        duration: const Duration(seconds: 2),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                            onPressed: () {
                              if (quantity > 1) {
                                cartController.updateQuantity(product, quantity - 1);
                              }
                            },
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          Text(
                            quantity.toString(),
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
                            onPressed: () {
                              if (quantity < product.stock) {
                                cartController.updateQuantity(product, quantity + 1);
                              } else {
                                Get.snackbar(
                                  'Limit Reached',
                                  'Cannot add more items. Stock limit reached!',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red.shade500,
                                  colorText: whiteColor,
                                  duration: const Duration(seconds: 2),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Text(
                        '\$${(itemPrice * quantity).toStringAsFixed(2)}',
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
              );
            },
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final total = cartController.cartItems.entries.fold(0.0, (sum, entry) {
          final ProductModel product = entry.key;
          final int quantity = entry.value;
          // Tính giá sale dựa trên phần trăm giảm giá
          final double itemPrice = productController.calculateSalePrice(
            product.price,
            product.salePrice,
          );
          return sum + (itemPrice * quantity);
        });

        return Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: ElevatedButton(
            onPressed: total > 0
                ? () => Get.to(() => const CheckoutScreen(), arguments: {'userId': 'user123'})
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: total > 0 ? TColors.primary : Colors.grey.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Checkout \$${total.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, fontFamily: bold, color: whiteColor),
            ),
          ),
        );
      }),
    );
  }
}