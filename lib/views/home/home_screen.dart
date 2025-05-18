import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/consts/lists.dart';
import 'package:ecommerce_computer_client/controller/product_controller.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/views/brand/brand_screen.dart';
import 'package:ecommerce_computer_client/views/product/product_cart_vertical.dart';
import 'package:ecommerce_computer_client/views/product/product_catalog_screen.dart';
import 'package:ecommerce_computer_client/views/shimmer/vertical_product_shimmer.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';
import 'package:ecommerce_computer_client/widgets/home_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the ProductController
    final controller = ProductController.instance;
    // Fetch featured products
    return Container(
      padding: const EdgeInsets.all(12),
      color: TColors.light,
      width: context.screenWidth,
      height: context.screenHeight,
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar
            SizedBox(
              width: double.infinity,
              child: Container(
                alignment: Alignment.center,
                height: 50,
                color: lightGrey,
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: searchAnything,
                    hintStyle: TextStyle(color: textfieldGrey),
                    filled: true,
                    fillColor: whiteColor,
                    suffixIcon: Icon(Icons.search, color: darkFontGrey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),

            10.heightBox,

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Swiper brands
                    VxSwiper.builder(
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      height: context.screenWidth > 1100 ? 400 : context.screenWidth > 756 ? 300: context.screenWidth > 600 ? 200 : 150,
                      enlargeCenterPage: true,
                      itemCount: sliderList.length,
                      itemBuilder: (context, index) {
                        return Image.asset(sliderList[index], fit: BoxFit.fill)
                            .box
                            .rounded
                            .clip(Clip.antiAlias)
                            .margin(const EdgeInsets.symmetric(horizontal: 8))
                            .make();
                      },
                    ),

                    10.heightBox,

                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(12),
                    //   decoration: BoxDecoration(
                    //     color: whiteColor,
                    //     borderRadius: BorderRadius.circular(8),
                    //   ),
                    //   child: SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     padding: const EdgeInsets.symmetric(vertical: 8),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: [
                    //         homeButtons(
                    //           icon: icTodaysDeal,
                    //           title: todayDeals,
                    //           onPress: () {},
                    //         ),
                    //         const SizedBox(
                    //           width: 16,
                    //         ), // Increased spacing between buttons
                    //         homeButtons(
                    //           icon: icFlashDeal,
                    //           title: flashsales,
                    //           onPress: () {},
                    //         ),
                    //         const SizedBox(width: 16),
                    //         homeButtons(
                    //           icon: icTopCategories,
                    //           title: "Categories",
                    //           onPress: () {},
                    //         ),
                    //         const SizedBox(width: 16),
                    //         homeButtons(
                    //           icon: icBrands,
                    //           title: brand,
                    //           onPress: () => Get.to(const BrandScreen()),
                    //         ),
                    //         const SizedBox(width: 16),
                    //         homeButtons(
                    //           icon: icTopSeller,
                    //           title: topSellers,
                    //           onPress: () {},
                    //         ),
                    //         const SizedBox(width: 16),
                    //         homeButtons(
                    //           icon: icCoupon,
                    //           title: "Coupons",
                    //           onPress: () {},
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    20.heightBox,
                    // New products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "New products".text
                            .color(Colors.black)
                            .size(18)
                            .fontFamily(semibold)
                            .make(),
                        InkWell(
                          child:
                          "View all".text
                              .color(darkFontGrey)
                              .fontFamily(regular)
                              .make(),
                          onTap: () => Get.to(const ProductCatalogScreen()),
                        ),
                      ],
                    ).box.padding(const EdgeInsets.all(8)).make(),

                    10.heightBox,
                    // New products
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() {
                        if (controller.isLoadingNew.value) {
                          return const TVerticalProductShimmer();
                        }
                        if (controller.newProducts.isEmpty) {
                          return "No products found".text
                              .color(Colors.black)
                              .fontFamily(bold)
                              .makeCentered();
                        }
                        return Row(
                          children: List.generate(
                            controller.newProducts.length,
                                (index) => ProductCartVertical(
                              product: controller.newProducts[index],
                            ).marginOnly(
                              left: index == 0 ? 0 : 6,
                              right: 6,
                            ),
                          ),
                        );
                      }),
                    ),

                    20.heightBox,

                    // Best selling products
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: redColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              "Best seller".text
                                  .color(whiteColor)
                                  .size(20)
                                  .fontWeight(FontWeight.w600)
                                  .make(),
                              InkWell(
                                child:
                                "View all".text
                                    .color(whiteColor)
                                    .fontFamily(regular)
                                    .make(),
                                onTap: () => Get.to(const ProductCatalogScreen()),
                              ),
                            ],
                          ),
                          10.heightBox,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Obx(() {
                              if (controller.isLoadingFeatured.value) {
                                return const TVerticalProductShimmer();
                              }
                              if (controller.featuredProducts.isEmpty) {
                                return "No products found".text
                                    .color(Colors.black)
                                    .fontFamily(bold)
                                    .makeCentered();
                              }
                              return Row(
                                children: List.generate(
                                  controller.featuredProducts.length,
                                      (index) => ProductCartVertical(
                                    product: controller.featuredProducts[index],
                                  ).marginOnly(
                                    left: index == 0 ? 0 : 6,
                                    right: 6,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    20.heightBox,

                    // New products
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        "All products".text
                            .color(Colors.black)
                            .size(18)
                            .fontFamily(semibold)
                            .make(),
                        InkWell(
                          child:
                          "View all".text
                              .color(darkFontGrey)
                              .fontFamily(regular)
                              .make(),
                          onTap: () => Get.to(const ProductCatalogScreen()),
                        ),
                      ],
                    ).box.padding(const EdgeInsets.all(8)).make(),

                    10.heightBox,
                    // All products
                    Obx(
                          () {
                        if (controller.isLoadingHome.value) {
                          return const TVerticalProductShimmer();
                        }
                        if (controller.homeProducts.isEmpty) {
                          return "No products found".text
                              .color(Colors.black)
                              .fontFamily(bold)
                              .makeCentered();
                        }
                        return CustomGridLayout(
                          crossAxisCount: context.screenWidth > 1200 ? 6 : context.screenWidth > 992 ? 5 : context.screenWidth > 768 ? 4 : context.screenWidth > 600 ? 3 : 2,
                          itemCount: controller.homeProducts.length,
                          itemBuilder: (context, index) => ProductCartVertical(
                            product: controller.homeProducts[index],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


