import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/product/product_reviews_screen.dart';
import 'package:ecommerce_computer_client/widgets/appbar.dart';
import 'package:ecommerce_computer_client/widgets/circular_icon.dart';
import 'package:ecommerce_computer_client/widgets/curved_edges_widget.dart';
import 'package:ecommerce_computer_client/widgets/icon_button.dart';
import 'package:ecommerce_computer_client/widgets/product_price_text.dart';
import 'package:ecommerce_computer_client/widgets/product_title_text.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final CartController cartController = Get.find<CartController>();
    final hasSale = product.salePrice > 0 && product.salePrice <= 1;
    final double effectiveSalePrice = hasSale
        ? controller.calculateSalePrice(product.price, product.salePrice)
        : product.price;
    final double salePercentage = product.salePrice * 100; // Phần trăm giảm giá
    final stockStatus = controller.checkProductStockStatus(product.stock);

    // Quản lý số lượng và trạng thái nút "Add to Cart"
    final RxInt quantity = 1.obs; // Số lượng ban đầu là 1
    final RxBool isButtonPressed = false.obs; // Trạng thái để tạo hiệu ứng nút

    return Scaffold(
      backgroundColor: whiteColor,
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
                  onPressed: () {
                    if (quantity.value > 1) {
                      quantity.value--;
                    }
                  },
                ),
                const SizedBox(width: Sizes.spaceBtwItems),
                Obx(() => Text(
                  quantity.value.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    color: darkFontGrey,
                    fontFamily: semibold,
                  ),
                )),
                const SizedBox(width: Sizes.spaceBtwItems),
                CircularIcon(
                  width: 40,
                  height: 40,
                  icon: Icons.add,
                  color: Colors.white,
                  backgroundColor: TColors.primary.withOpacity(0.9),
                  onPressed: () {
                    if (quantity.value < product.stock) {
                      quantity.value++;
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
            Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                backgroundColor: isButtonPressed.value ? TColors.primary.withOpacity(0.7) : TColors.primary,
                side: const BorderSide(color: Colors.blueAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Sizes.buttonRadius),
                ),
              ),
              onPressed: () {
                // Hiệu ứng nhấn nút
                isButtonPressed.value = true;
                Future.delayed(const Duration(milliseconds: 300), () {
                  isButtonPressed.value = false;
                });

                // Thêm sản phẩm vào giỏ hàng với số lượng
                for (int i = 0; i < quantity.value; i++) {
                  cartController.addToCart(product);
                }

                // Hiển thị thông báo
                Get.snackbar(
                  'Success',
                  'Added ${quantity.value} item${quantity.value > 1 ? 's' : ''} to cart successfully!',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.green.shade500,
                  colorText: whiteColor,
                  duration: const Duration(seconds: 2),
                );
              },
              child: 'Add to Cart'
                  .text
                  .color(whiteColor)
                  .fontFamily(bold)
                  .size(16)
                  .make(),
            )),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1 - Product Image Slider
            TCurvedEdgesWidget(
              child: Container(
                color: Colors.grey.shade50,
                child: Stack(
                  children: [
                    // Main Large Image
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: RoundedImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            isNetworkImage: true,
                          ),
                        ),
                      ),
                    ),

                    /// Appbar
                    TAppBar(
                      showBackArrow: true,
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
                          if (hasSale)
                            RoundedContainer(
                              radius: Sizes.sm,
                              backgroundColor: Colors.yellow.shade600.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(
                                vertical: Sizes.xs,
                                horizontal: Sizes.sm,
                              ),
                              child: Text(
                                '-${salePercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontFamily: semibold,
                                ),
                              ),
                            ),
                          if (hasSale) const SizedBox(width: Sizes.spaceBtwItems),
                          if (hasSale)
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red.shade300,
                                fontFamily: semibold,
                              ),
                            ),
                          if (hasSale) const SizedBox(width: Sizes.spaceBtwItems),
                          ProductPriceText(
                            price: effectiveSalePrice.toStringAsFixed(2),
                            isLarge: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),

                      /// Title
                      ProductTitleText(title: product.title),
                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),

                      /// Stock
                      Row(
                        children: [
                          ProductTitleText(title: 'Status:', smallSize: true),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          Text(
                            stockStatus,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.0,
                              fontFamily: bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),

                      /// Brand
                      Row(
                        children: [
                          Text(
                            product.brand,
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

                  const SizedBox(height: Sizes.spaceBtwItems),
                  ReadMoreText(
                    product.description ?? 'No description available.',
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
                        onPressed: () => Get.to(() => const ProductReviewsScreen()),
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