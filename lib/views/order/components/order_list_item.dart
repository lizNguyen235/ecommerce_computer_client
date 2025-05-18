import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/order/order_detail_screen.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class OrderListItem extends StatelessWidget {
  final OrderModel order;
  final String orderId;

  const OrderListItem({super.key, required this.order, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailScreen(orderId: orderId, order: order)),
      child: RoundedContainer(
        showBorder: true,
        backgroundColor: TColors.light,
        padding: const EdgeInsets.all(Sizes.sm),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Iconsax.ship),
                const SizedBox(width: Sizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.status,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: TColors.primary,
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM yyyy').format(order.createdAt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: bold,
                          color: TColors.dark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Sizes.spaceBtwItems),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: regular,
                        color: darkFontGrey,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'en_US', symbol: '\$').format(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: semibold,
                        color: TColors.dark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            Row(
              children: [
                const Icon(Iconsax.tag),
                const SizedBox(width: Sizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: regular,
                          color: darkFontGrey,
                        ),
                      ),
                      Text(
                        '[#$orderId]',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: semibold,
                          color: TColors.dark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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