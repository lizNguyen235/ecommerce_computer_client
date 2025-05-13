import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/consts/lists.dart';
import 'package:ecommerce_computer_client/widgets/home_buttons.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: lightGrey,
      width: context.screenHeight,
      height: context.screenHeight,
      child: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Container(
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
                      height: 150,
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

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            homeButtons(
                              icon: icTodaysDeal,
                              title: todayDeals,
                              onPress: () {},
                            ),
                            const SizedBox(
                              width: 16,
                            ), // Increased spacing between buttons
                            homeButtons(
                              icon: icFlashDeal,
                              title: flashsales,
                              onPress: () {},
                            ),
                            const SizedBox(width: 16),
                            homeButtons(
                              icon: icTopCategories,
                              title: "Categories",
                              onPress: () {},
                            ),
                            const SizedBox(width: 16),
                            homeButtons(
                              icon: icBrands,
                              title: brand,
                              onPress: () {},
                            ),
                            const SizedBox(width: 16),
                            homeButtons(
                              icon: icTopSeller,
                              title: topSellers,
                              onPress: () {},
                            ),
                            const SizedBox(width: 16),
                            homeButtons(
                              icon: icCoupon,
                              title: "Coupons",
                              onPress: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    20.heightBox,
                    // New products
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          "New products".text
                              .color(darkFontGrey)
                              .size(18)
                              .fontFamily(semibold)
                              .make(),
                    ),

                    10.heightBox,
                    // Featured categories list
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          6,
                          (index) =>
                              Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        imgP5,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                      10.heightBox,
                                      "Laptop 4GB/64GB".text
                                          .fontFamily(semibold)
                                          .color(darkFontGrey)
                                          .make(),
                                      10.heightBox,
                                      "\$600".text
                                          .fontFamily(bold)
                                          .color(redColor)
                                          .size(16)
                                          .make(),
                                    ],
                                  ).box.white.roundedSM
                                  .margin(
                                    const EdgeInsets.symmetric(horizontal: 4),
                                  )
                                  .padding(const EdgeInsets.all(8))
                                  .make(),
                        ),
                      ),
                    ),

                    20.heightBox,

                    // Best selling products
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: redColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          bestSellers.text.white
                              .fontFamily(bold)
                              .size(18)
                              .make(),
                          10.heightBox,
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                6,
                                (index) =>
                                    Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              imgP5,
                                              width: 150,
                                              fit: BoxFit.cover,
                                            ),
                                            10.heightBox,
                                            "Laptop 4GB/64GB".text
                                                .fontFamily(semibold)
                                                .color(darkFontGrey)
                                                .make(),
                                            10.heightBox,
                                            "\$600".text
                                                .fontFamily(bold)
                                                .color(redColor)
                                                .size(16)
                                                .make(),
                                          ],
                                        ).box.white.roundedSM
                                        .margin(
                                          const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                        )
                                        .padding(const EdgeInsets.all(8))
                                        .make(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    20.heightBox,
                    // New products
                    Align(
                      alignment: Alignment.centerLeft,
                      child:
                          "All products".text
                              .color(darkFontGrey)
                              .size(18)
                              .fontFamily(semibold)
                              .make(),
                    ),

                    10.heightBox,
                    // All products
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 6,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 300,
                      ),
                      itemBuilder: (context, index) {
                        return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.asset(
                                  imgP3,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                const Spacer(),
                                "Laptop 4GB/64GB".text
                                    .fontFamily(semibold)
                                    .color(darkFontGrey)
                                    .make(),
                                10.heightBox,
                                "\$600".text
                                    .fontFamily(bold)
                                    .color(redColor)
                                    .size(16)
                                    .make(),
                              ],
                            ).box.white.roundedSM
                            .margin(const EdgeInsets.symmetric(horizontal: 4))
                            .padding(const EdgeInsets.all(8))
                            .make();
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
