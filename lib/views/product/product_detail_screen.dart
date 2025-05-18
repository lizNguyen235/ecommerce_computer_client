import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:ecommerce_computer_client/widgets/product_price_text.dart';
import 'package:ecommerce_computer_client/widgets/product_title_text.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:readmore/readmore.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final ProductController controller = Get.find<ProductController>();
    final CartController cartController = Get.find<CartController>();
    final RxInt quantity = 1.obs;
    final RxBool isButtonPressed = false.obs;

    return Scaffold(
      backgroundColor: whiteColor,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace, vertical: 8.0),
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
                    if (quantity.value > 1) quantity.value--;
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
                        'Cannot add product. Stock limit exceeded!',
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
                isButtonPressed.value = true;
                Future.delayed(const Duration(milliseconds: 300), () {
                  isButtonPressed.value = false;
                });
                for (int i = 0; i < quantity.value; i++) {
                  cartController.addToCart(product);
                }
                Get.snackbar(
                  'Success',
                  'Added ${quantity.value} products to cart!',
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
            TCurvedEdgesWidget(
              child: Container(
                color: Colors.grey.shade50,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Center(
                          child: RoundedImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            isNetworkImage: true,
                          ),
                        ),
                      ),
                    ),
                    const TAppBar(showBackArrow: true),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: Sizes.defaultSpace,
                left: Sizes.defaultSpace,
                bottom: Sizes.defaultSpace,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(product.id)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();
                      final data = snapshot.data!.data() as Map<String, dynamic>?;
                      final averageRating = data?['averageRating']?.toDouble() ?? 0.0;
                      final reviewCount = data?['reviewCount'] ?? 0;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: Sizes.iconSm),
                              const SizedBox(width: Sizes.spaceBtwItems / 2),
                              Text.rich(
                                TextSpan(
                                  text: averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: darkFontGrey,
                                    fontFamily: semibold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: " ($reviewCount)",
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
                            icon: const Icon(Icons.share, size: 20, color: darkFontGrey),
                          ),
                        ],
                      );
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (product.discountPercentageDisplay > 0)
                            RoundedContainer(
                              radius: Sizes.sm,
                              backgroundColor: Colors.yellow.shade600.withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(vertical: Sizes.xs, horizontal: Sizes.sm),
                              child: Text(
                                '-${product.discountPercentageDisplay.toStringAsFixed(0)}%',
                                style: TextStyle(color: Colors.black, fontSize: 12, fontFamily: semibold),
                              ),
                            ),
                          if (product.discountPercentageDisplay > 0) const SizedBox(width: Sizes.spaceBtwItems),
                          if (product.discountPercentageDisplay > 0)
                            Text(
                              '\$${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red.shade300,
                                fontFamily: semibold,
                              ),
                            ),
                          if (product.discountPercentageDisplay > 0) const SizedBox(width: Sizes.spaceBtwItems),
                          ProductPriceText(price: product.effectivePrice.toStringAsFixed(0), isLarge: true, currencySign: '\$'),
                        ],
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),
                      ProductTitleText(title: product.title),
                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),
                      Row(
                        children: [
                          const ProductTitleText(title: 'Stock:', smallSize: true),
                          const SizedBox(width: Sizes.spaceBtwItems),
                          Text(
                            controller.checkProductStockStatus(product.stock),
                            style: TextStyle(color: Colors.black, fontSize: 14.0, fontFamily: bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sizes.spaceBtwItems / 1.5),
                      Row(
                        children: [
                          Text(
                            product.brand,
                            style: TextStyle(color: Colors.black, fontSize: 14.0, fontFamily: semibold),
                          ),
                          const SizedBox(width: 4.0),
                          Icon(Iconsax.verify5, color: Colors.blue.shade600, size: 12),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  ReadMoreText(
                    product.description ?? 'No description available.',
                    trimLines: 2,
                    trimMode: TrimMode.Line,
                    trimCollapsedText: ' Show more',
                    trimExpandedText: ' Show less',
                    moreStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                    lessStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                        backgroundColor: Colors.red.shade500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.buttonRadius),
                        ),
                      ),
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(fontSize: 16, color: whiteColor, fontFamily: bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: Sizes.spaceBtwSections),
                  const Divider(),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .doc(product.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Text('Reviews (0)');
                          final data = snapshot.data!.data() as Map<String, dynamic>?;
                          final reviewCount = data?['reviewCount'] ?? 0;
                          return Text(
                            'Reviews ($reviewCount)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () => Get.to(() => ProductReviewsScreen(productId: product.id)),
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: Sizes.spaceBtwItems),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .doc(product.id)
                        .collection('reviews')
                        .orderBy('timestamp', descending: true)
                        .limit(3)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No reviews yet.', style: TextStyle(color: darkFontGrey));
                      }
                      final reviews = snapshot.data!.docs;
                      return Column(
                        children: reviews.map((doc) {
                          final review = doc.data() as Map<String, dynamic>;
                          return _buildReviewCard(
                            username: review['username'],
                            rating: review['rating']?.toDouble() ?? 0.0,
                            date: DateTime.fromMillisecondsSinceEpoch(
                                (review['timestamp'] as Timestamp).millisecondsSinceEpoch)
                                .toString()
                                .substring(0, 10),
                            reviewText: review['comment'] ?? '',
                          );
                        }).toList(),
                      );
                    },
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

  Widget _buildReviewCard({
    required String username,
    required double rating,
    required String date,
    required String reviewText,
  }) {
    return Container(
      padding: const EdgeInsets.all(Sizes.md),
      margin: const EdgeInsets.only(bottom: Sizes.sm),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(Sizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                username,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
          if (rating > 0) ...[
            const SizedBox(height: Sizes.sm),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.floor() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
          ],
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: Sizes.sm),
            Text(
              reviewText,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ],
      ),
    );
  }
}