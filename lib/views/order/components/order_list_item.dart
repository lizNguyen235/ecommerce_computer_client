import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrderListItem extends StatelessWidget {
  const OrderListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder:
          (context, index) => const SizedBox(height: Sizes.spaceBtwItems),
      shrinkWrap: true,
      itemCount: 10,
      itemBuilder:
          (context, index) => RoundedContainer(
            showBorder: true,
            backgroundColor: TColors.light,
            padding: const EdgeInsets.all(Sizes.sm),
            child: Column(
              children: [
                /// - Row 1
                Row(
                  children: [
                    /// -- Icon
                    Icon(Iconsax.ship),
                    const SizedBox(width: Sizes.spaceBtwItems),

                    /// -- Status & Date
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processing',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: TColors.primary,
                            ),
                          ),
                          Text(
                            '07 Nov 2023',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: bold,
                              color: TColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// -- Icon
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Iconsax.arrow_right_34,
                        size: Sizes.iconSm,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Sizes.spaceBtwItems),

                /// - Row 2
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Iconsax.tag),
                          const SizedBox(width: Sizes.spaceBtwItems),

                          /// -- Status & Date
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                                Text(
                                  '[#123456]',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: semibold,
                                    color: TColors.dark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar),
                          const SizedBox(width: Sizes.spaceBtwItems),

                          /// -- Status & Date
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Shipping Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                                Text(
                                  '03 Feb 2025',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: semibold,
                                    color: TColors.dark,
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
              ],
            ),
          ),
    );
  }
}
