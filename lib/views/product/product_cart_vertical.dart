import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/product/product_detail_screen.dart';
import 'package:ecommerce_computer_client/widgets/product_title_text.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:ecommerce_computer_client/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProductCartVertical extends StatelessWidget {
  ProductCartVertical({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final hasSale = product.salePrice > 0 && product.salePrice < product.price;
    final salePercent = hasSale
        ? controller.calculateSalePercentage(product.price, product.salePrice)
        : 0.0;

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product,)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Hình và badge sale
            RoundedContainer(
              height: 180,
              backgroundColor: TColors.light,
              child: Stack(
                children: [
                  // Ảnh
                  RoundedImage(
                    imageUrl: product.thumbnail,
                    applyImageRadius: true,
                    isNetworkImage: true,
                  ),
                  // Badge % nếu có sale
                  if (hasSale)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: RoundedContainer(
                        radius: Sizes.sm,
                        backgroundColor: Colors.redAccent.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: Sizes.sm,
                          vertical: Sizes.xs,
                        ),
                        child: Text(
                          '-${salePercent.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Icon yêu thích

                ],
              ),
            ),

            // Thông tin phía dưới
            Padding(
              padding: const EdgeInsets.all(Sizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductTitleText(
                    title: product.title,
                    maxLines: 1,
                    smallSize: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.brand,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: semibold,
                      color: darkFontGrey,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasSale) ...[
                        // Giá gốc gạch ngang
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: darkFontGrey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        // Giá sale nổi bật
                        Text(
                          '\$${product.salePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: bold,
                            color: redColor,
                          ),
                        ),
                      ] else ...[
                        // Chỉ hiển thị giá thường
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: bold,
                            color: Colors.black,
                          ),
                        ),
                      ],

                      // Nút thêm vào giỏ
                      Container(
                        decoration: BoxDecoration(
                          color: TColors.primary,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Iconsax.add,
                            color: Colors.white,
                            size: 20,
                          ),
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
