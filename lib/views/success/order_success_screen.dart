import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/order/order_screen.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final OrderModel order;

  const OrderSuccessScreen({Key? key, required this.orderId, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total quantity of items
    final totalQuantity = order.items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

    // Get status color based on status
    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'PENDING':
          return Colors.orange;
        case 'DELIVERED':
          return Colors.green;
        case 'CANCELLED':
          return Colors.red;
        default:
          return TColors.primary;
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Order Confirmed',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: TColors.primary,
        elevation: 2,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [TColors.primary, TColors.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Header
              Container(
                padding: const EdgeInsets.all(Sizes.lg),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(0.1),
                ),
                child: const Icon(Iconsax.verify5, color: Colors.green, size: 80),
              ),
              const SizedBox(height: Sizes.spaceBtwItems),
              Text(
                'Order Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: TColors.dark,
                ),
              ),
              Text(
                'Thank you for your purchase',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: regular,
                  color: darkFontGrey,
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Order Summary Card
              RoundedContainer(
                padding: const EdgeInsets.all(Sizes.md),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.info_circle, color: TColors.primary, size: 24),
                        const SizedBox(width: Sizes.sm),
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    Row(
                      children: [
                        const Icon(Iconsax.tag, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Order ID: $orderId',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(fontSize: 16, fontFamily: semibold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: getStatusColor(order.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor(order.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      children: [
                        const Icon(Iconsax.dollar_circle, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Total Amount: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(order.totalAmount)}',
                            style: const TextStyle(fontSize: 16, fontFamily: semibold, color: TColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Products Card
              RoundedContainer(
                padding: const EdgeInsets.all(Sizes.md),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.shopping_bag, color: TColors.primary, size: 24),
                        const SizedBox(width: Sizes.sm),
                        Text(
                          'Products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    ...order.items.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                      child: InkWell(
                        onTap: () {}, // Placeholder for potential future interactivity
                        child: Container(
                          padding: const EdgeInsets.all(Sizes.sm),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: bold,
                                        color: TColors.dark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Qty: ${item['quantity']} x ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(item['price'])}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: regular,
                                        color: darkFontGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'en_US', symbol: '\$').format(item['quantity'] * item['price']),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: semibold,
                                  color: TColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Quantity:',
                          style: const TextStyle(fontSize: 16, fontFamily: semibold),
                        ),
                        Text(
                          '$totalQuantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: semibold,
                            color: TColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Shipping & Payment Card
              RoundedContainer(
                padding: const EdgeInsets.all(Sizes.md),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.truck, color: TColors.primary, size: 24),
                        const SizedBox(width: Sizes.sm),
                        Text(
                          'Shipping & Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    Row(
                      children: [
                        const Icon(Iconsax.location, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Address: ${order.shippingAddress.address}',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      children: [
                        const Icon(Iconsax.profile, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Recipient: ${order.shippingAddress.name} (${order.shippingAddress.phone})',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      children: [
                        const Icon(Iconsax.card, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Payment: ${order.paymentMethod}',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => OrderScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.white,
                        elevation: 2,
                      ),
                      child: const Text(
                        'View Orders',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: Sizes.spaceBtwItems),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => (), // Assumes '/home' is the home route
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: Sizes.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: TColors.primary),
                        foregroundColor: TColors.primary,
                      ),
                      child: const Text(
                        'Continue Shopping',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}