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

  // Get status color based on status
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PROCESSING':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.yellow;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return TColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);

    return GestureDetector(
      onTap: () => Get.to(() => OrderDetailScreen(orderId: orderId, order: order)),
      child: RoundedContainer(
        showBorder: true,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(Sizes.md),
        margin: const EdgeInsets.symmetric(horizontal: Sizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.ship, color: TColors.primary, size: 24),
                const SizedBox(width: Sizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor, // Status text color matches status
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(order.createdAt),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: regular,
                          color: darkFontGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
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
                        color: TColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Sizes.spaceBtwItems),
            Row(
              children: [
                const Icon(Iconsax.tag, color: TColors.primary, size: 20),
                const SizedBox(width: Sizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ID',
                        style: TextStyle(
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