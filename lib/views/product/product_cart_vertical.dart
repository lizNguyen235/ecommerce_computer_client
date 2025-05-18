import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/controller/cart_controller.dart';
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
    final hasSale = product.salePrice > 0 && product.salePrice <= 1;
    final salePrice = hasSale
        ? controller.calculateSalePrice(product.price, product.salePrice)
        : product.price;
    final salePercent = (product.salePrice * 100).toInt(); // Phần trăm giảm giá
    final CartController cartController = Get.find<CartController>();
    final RxBool isButtonPressed = false.obs; // Trạng thái hiệu ứng nút

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600; // Kiểm tra nếu là thiết bị di động
    final isTablet = screenWidth >= 600 && screenWidth < 1100; // Kiểm tra nếu là thiết bị máy tính bảng
    final isDesktop = screenWidth >= 1100; // Kiểm tra nếu là thiết bị máy tính để bàn
    final double imageSize = isMobile
        ? 100
        : isTablet
            ? 150
            : 200; // Kích thước hình ảnh tùy thuộc vào thiết bị
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth; // Kiểm tra nếu là chế độ dọc
    final isLandscape = screenHeight < screenWidth; // Kiểm tra nếu là chế độ ngang
    final double padding = isMobile
        ? 8
        : isTablet
            ? 12
            : 16; // Padding tùy thuộc vào thiết bị

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailScreen(product: product)),
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
                      top: MediaQuery.of(context).size.width * 0.01 > 4 ? 4 : MediaQuery.of(context).size.width * 0.01,
                      left: MediaQuery.of(context).size.width * 0.01 > 4 ? 4 : MediaQuery.of(context).size.width * 0.01,
                      child: RoundedContainer(
                        radius: Sizes.sm,
                        backgroundColor: Colors.yellow.withOpacity(0.8),
                        padding: EdgeInsets.symmetric(
                          horizontal: Sizes.sm,
                          vertical: Sizes.xs,
                        ),
                        child: Text(
                          '-$salePercent%',
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width < 600 ? 10 : 12, // Kích thước chữ responsive
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              '\$${salePrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: bold,
                                color: redColor,
                              ),
                            ),
                          ],
                          if (!hasSale) ...[
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
                        ],
                      ),

                      // Nút thêm vào giỏ
                      Obx(() => InkWell(
                        onTap: () {
                          // Hiệu ứng nhấn nút
                          isButtonPressed.value = true;
                          Future.delayed(const Duration(milliseconds: 200), () {
                            isButtonPressed.value = false;
                          });

                          // Thêm sản phẩm vào giỏ hàng
                          cartController.addToCart(product);

                          // Hiển thị thông báo
                          Get.snackbar(
                            'Success',
                            'Added 1 item to cart successfully!',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green.shade500,
                            colorText: whiteColor,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isButtonPressed.value
                                ? TColors.primary.withOpacity(0.7)
                                : TColors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Iconsax.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )),
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

