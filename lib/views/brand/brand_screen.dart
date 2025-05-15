import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/custom_grid_layout.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BrandScreen extends StatelessWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Brand',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Heading
              const Text(
                'Brands',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),

              /// Brand List
              CustomGridLayout(
                itemCount: 10,
                mainAxisExtent: 80,
                itemBuilder:
                    (context, index) => RoundedContainer(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      showBorder: true,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// Brand Logo
                          Image.asset(
                            'assets/images/user.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: Sizes.spaceBtwItems),

                          /// Brand Name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Nike',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: Sizes.xs),
                                  const Icon(
                                    Iconsax.verify5,
                                    size: Sizes.iconXs,
                                    color: TColors.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '25 products',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: semibold,
                                  color: darkFontGrey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
