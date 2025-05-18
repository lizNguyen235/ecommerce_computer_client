import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/service/OrderService.dart';
import '../data/orderModels/order_model.dart';
// import '../utils/colors.dart'; // TColors
// import '../utils/sizes.dart'; // Sizes
// Import Product model and service if you want to display product names/images
// import '../models/product_model.dart';
// import '../services/product_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  // final ProductService _productService = ProductService(); // If fetching product details

  // Function to get product details (name, image) - Placeholder
  Future<Map<String, String>> _fetchProductDetails(String productId) async {
    // In a real app, you would fetch from ProductService
    // await _productService.getProductById(productId);
    // For now, return placeholder data
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate network delay
    return {
      'name': 'Product Name for $productId', // Replace with actual name
      'imageUrl': 'https://via.placeholder.com/80?text=No+Image', // Replace with actual image URL or default
    };
  }


  void _showUpdateStatusDialog(OrderModel currentOrder) {
    OrderStatus selectedStatus = currentOrder.status; // Default to current status

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Use StatefulBuilder for dialog state
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Update Order Status'),
                content: DropdownButton<OrderStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: OrderStatus.values
                      .where((s) => s != OrderStatus.UNKNOWN) // Exclude UNKNOWN
                      .map((OrderStatus status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Text(orderStatusToString(status)),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? newValue) {
                    if (newValue != null) {
                      setDialogState(() { // Use setDialogState to update dialog's UI
                        selectedStatus = newValue;
                      });
                    }
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  ElevatedButton(
                    child: const Text('Update'),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close dialog first
                      bool success = await _orderService.updateOrderStatus(currentOrder.id, selectedStatus);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order status updated successfully!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update order status.'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING: return Colors.orange;
      case OrderStatus.CONFIRMED: return Colors.blue;
      case OrderStatus.PROCESSING: return Colors.purple;
      case OrderStatus.SHIPPED: return Colors.teal;
      case OrderStatus.DELIVERED: return Colors.green;
      case OrderStatus.CANCELLED: return Colors.red;
      case OrderStatus.RETURNED: return Colors.deepOrange;
      case OrderStatus.REFUNDED: return Colors.pink;
      default: return Colors.grey;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #${widget.orderId.substring(0,8)}...'),
      ),
      body: StreamBuilder<OrderModel?>(
        stream: _orderService.getOrderDetails(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Error loading order details or order not found. ${snapshot.error}'));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0 /*Sizes.md*/),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionTitle('Order Information'),
                _buildInfoRow('Order ID:', order.id),
                _buildInfoRow('Status:', orderStatusToString(order.status), valueColor: _getStatusColor(order.status)),
                _buildInfoRow('Order Date:', DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt.toDate())),
                _buildInfoRow('Payment Method:', order.paymentMethod),
                if (order.couponCode != null && order.couponCode!.isNotEmpty)
                  _buildInfoRow('Coupon Code:', order.couponCode!),

                const SizedBox(height: 16 /*Sizes.spaceBtwSections*/),
                _buildSectionTitle('Buyer Information'),
                _buildInfoRow('Name:', order.shippingAddress.name),
                _buildInfoRow('Phone:', order.shippingAddress.phone),
                _buildInfoRow('Address:', order.shippingAddress.address),

                const SizedBox(height: 16),
                _buildSectionTitle('Order Items (${order.items.length})'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    // Async fetch for product details
                    return FutureBuilder<Map<String, String>>(
                      future: _fetchProductDetails(item.productId),
                      builder: (context, productSnapshot) {
                        String productName = item.productId; // Default to ID
                        String imageUrl = 'https://via.placeholder.com/80?text=Loading';

                        if (productSnapshot.connectionState == ConnectionState.done && productSnapshot.hasData) {
                          productName = productSnapshot.data!['name'] ?? item.productId;
                          imageUrl = productSnapshot.data!['imageUrl'] ?? 'https://via.placeholder.com/80?text=No+Image';
                        } else if (productSnapshot.hasError) {
                          imageUrl = 'https://via.placeholder.com/80?text=Error';
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 50),
                            ),
                            title: Text(productName),
                            subtitle: Text('Qty: ${item.quantity} - Price: \$${item.price.toStringAsFixed(2)} each'),
                            trailing: Text('\$${(item.quantity * item.price).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),
                _buildSectionTitle('Order Summary'),
                _buildInfoRow('Subtotal:', '\$${order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}'),
                _buildInfoRow('Shipping Fee:', '\$${order.shippingFee.toStringAsFixed(2)}'),
                _buildInfoRow('Tax:', '\$${order.tax.toStringAsFixed(2)}'),
                if (order.discountAmount > 0)
                  _buildInfoRow('Discount:', '-\$${order.discountAmount.toStringAsFixed(2)}', valueColor: Colors.green),
                if (order.pointAmount > 0)
                  _buildInfoRow('Points Used:', '-\$${order.pointAmount.toStringAsFixed(2)}', valueColor: Colors.green), // Assuming points convert to discount
                const Divider(thickness: 1, height: 20),
                _buildInfoRow('Total Amount:', '\$${order.totalAmount.toStringAsFixed(2)}', isBold: true, valueColor: Theme.of(context).primaryColor),

                const SizedBox(height: 24),
                _buildSectionTitle('Status History'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: order.statusHistory.length,
                  itemBuilder: (context, index) {
                    final history = order.statusHistory[order.statusHistory.length - 1 - index]; // Show newest first
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.circle, size: 10, color: _getStatusColor(stringToOrderStatus(history.status))),
                      title: Text(history.status, style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Text(DateFormat('dd MMM yy, hh:mm a').format(history.timestamp.toDate()), style: Theme.of(context).textTheme.bodySmall),
                    );
                  },
                ),

                const SizedBox(height: 32 /*Sizes.spaceBtwSections * 2*/),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: TColors.primary,
                      // foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () {
                      _showUpdateStatusDialog(order);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0 /*Sizes.sm*/),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0 /*Sizes.xs*/),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('$label ', style: Theme.of(context).textTheme.bodyMedium),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}