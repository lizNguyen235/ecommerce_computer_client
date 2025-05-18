import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/widgets/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.orderId, required this.order});

  @override
  Widget build(BuildContext context) {
    // Calculate total quantity of items
    final totalQuantity = order.items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

    // Get status color based on status
    Color getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'PENDING':
          return Colors.deepOrange; // Vibrant orange for awaiting action
        case 'CONFIRMED':
          return Colors.blueAccent; // Bright blue for confirmation
        case 'SHIPPING':
          return Colors.purpleAccent; // Distinct purple for transit
        case 'DELIVERED':
          return Colors.green; // Standard green for success
        case 'CANCELLED':
          return Colors.redAccent; // Bold red for termination
        default:
          return TColors.primary; // Fallback for undefined statuses
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'Order #$orderId',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    Text(
                      'Order Date: ${DateFormat('dd MMM yyyy').format(order.createdAt)}',
                      style: TextStyle(fontSize: 16, fontFamily: regular, color: darkFontGrey),
                    ),
                    const SizedBox(height: Sizes.sm),
                    Text(
                      'Total Amount: ${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(order.totalAmount)}',
                      style: const TextStyle(fontSize: 16, fontFamily: semibold, color: TColors.primary),
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
              // Shipping Information Card
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
                          'Shipping Information',
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
                        const Icon(Iconsax.profile, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Recipient: ${order.shippingAddress.name}',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
                    Row(
                      children: [
                        const Icon(Iconsax.call, size: 20, color: darkFontGrey),
                        const SizedBox(width: Sizes.sm),
                        Expanded(
                          child: Text(
                            'Phone: ${order.shippingAddress.phone}',
                            style: TextStyle(fontSize: 16, fontFamily: regular, color: TColors.dark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.sm),
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
                  ],
                ),
              ),
              const SizedBox(height: Sizes.spaceBtwSections),
              // Status History Card
              RoundedContainer(
                padding: const EdgeInsets.all(Sizes.md),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Iconsax.clock, color: TColors.primary, size: 24),
                        const SizedBox(width: Sizes.sm),
                        Text(
                          'Status History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: TColors.dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Sizes.spaceBtwItems),
                    ...order.statusHistory.reversed.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: Sizes.spaceBtwItems),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4, right: 12),
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getStatusColor(entry['status']),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['status'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: semibold,
                                    color: TColors.dark,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(entry['timestamp']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: regular,
                                    color: darkFontGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}