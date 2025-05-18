import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Models
import '../core/service/OrderService.dart';
import '../core/service/ProductService.dart';
import '../data/orderModels/order_model.dart';
import '../models/product_model.dart';


// Services


// Giả sử bạn có các file utils này, nếu không hãy thay thế bằng giá trị cụ thể
// import '../utils/colors.dart'; // TColors
// import '../utils/sizes.dart'; // Sizes

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  final ProductService _productService = ProductService();

  Future<ProductModel?> _fetchProductDetails(String productId) async {
    try {
      return await _productService.getProductById(productId);
    } catch (e) {
      print("Error fetching product details for $productId in OrderDetailScreen: $e");
      return null;
    }
  }

  void _showUpdateStatusDialog(OrderModel currentOrder) {
    OrderStatus selectedStatus = currentOrder.status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Update Order Status'),
                content: DropdownButton<OrderStatus>(
                  value: selectedStatus,
                  isExpanded: true,
                  items: OrderStatus.values
                      .where((s) => s != OrderStatus.UNKNOWN)
                      .map((OrderStatus status) {
                    return DropdownMenuItem<OrderStatus>(
                      value: status,
                      child: Text(orderStatusToString(status)),
                    );
                  }).toList(),
                  onChanged: (OrderStatus? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
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
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: TColors.primary, // Ví dụ sử dụng TColors
                      // foregroundColor: Colors.white,   // Ví dụ
                    ),
                    child: const Text('Update'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      bool success = await _orderService.updateOrderStatus(currentOrder.id, selectedStatus);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Order status updated successfully!' : 'Failed to update order status.'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
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
      case OrderStatus.PENDING: return Colors.orange.shade700;
      case OrderStatus.CONFIRMED: return Colors.blue.shade700;
      case OrderStatus.PROCESSING: return Colors.purple.shade700;
      case OrderStatus.SHIPPED: return Colors.teal.shade700;
      case OrderStatus.DELIVERED: return Colors.green.shade700;
      case OrderStatus.CANCELLED: return Colors.red.shade700;
      case OrderStatus.RETURNED: return Colors.deepOrange.shade700;
      case OrderStatus.REFUNDED: return Colors.pink.shade700;
      default: return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor; // Hoặc TColors.primary

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details #${widget.orderId.length > 8 ? widget.orderId.substring(0,8) : widget.orderId}...'),
        // backgroundColor: TColors.primary, // Ví dụ
        // foregroundColor: Colors.white,    // Ví dụ
      ),
      body: StreamBuilder<OrderModel?>(
        stream: _orderService.getOrderDetails(widget.orderId),
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orderSnapshot.hasError || !orderSnapshot.hasData || orderSnapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0 /* Sizes.md */),
                child: Text(
                  'Error loading order details or order not found.\n${orderSnapshot.error ?? ""}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final order = orderSnapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0 /* Sizes.md */),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildSectionTitle('Order Information', textTheme),
                _buildInfoRow('Order ID:', order.id, textTheme),
                _buildInfoRow('Status:', orderStatusToString(order.status), textTheme, valueColor: _getStatusColor(order.status), isValueBold: true),
                _buildInfoRow('Order Date:', DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt.toDate()), textTheme),
                _buildInfoRow('Payment Method:', order.paymentMethod, textTheme),
                if (order.couponCode != null && order.couponCode!.isNotEmpty)
                  _buildInfoRow('Coupon Code:', order.couponCode!, textTheme),

                const SizedBox(height: 24.0 /* Sizes.spaceBtwSections */),
                _buildSectionTitle('Buyer Information', textTheme),
                _buildInfoRow('Name:', order.shippingAddress.name, textTheme),
                _buildInfoRow('Phone:', order.shippingAddress.phone, textTheme),
                _buildInfoRow('Address:', order.shippingAddress.address, textTheme),

                const SizedBox(height: 24.0 /* Sizes.spaceBtwSections */),
                _buildSectionTitle('Order Items (${order.items.length})', textTheme),
                if (order.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0 /* Sizes.sm */),
                    child: Text("No items in this order.", style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8.0 /* Sizes.sm */),
                    itemBuilder: (context, index) {
                      final orderItem = order.items[index];
                      return FutureBuilder<ProductModel?>(
                        future: _fetchProductDetails(orderItem.productId),
                        builder: (context, productSnapshot) {
                          String productName = 'Loading product...';
                          Widget leadingWidget = SizedBox(
                            width: 60, // Sizes.productImageSize * 0.75
                            height: 60,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );

                          if (productSnapshot.connectionState == ConnectionState.done) {
                            if (productSnapshot.hasData && productSnapshot.data != null) {
                              final product = productSnapshot.data!;
                              productName = product.title;
                              leadingWidget = ClipRRect(
                                borderRadius: BorderRadius.circular(8.0 /* Sizes.borderRadiusMd */),
                                child: Image.network(
                                  product.thumbnail.isNotEmpty ? product.thumbnail : 'https://via.placeholder.com/100?text=No+Image',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(width: 60, height: 60, color: Colors.grey.shade300, child: const Icon(Icons.broken_image, size: 30, color: Colors.grey)),
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: 60, height: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              productName = 'Product not found';
                              leadingWidget = Container(width: 60, height: 60, color: Colors.grey.shade300, child: Icon(Icons.error_outline, size: 30, color: Colors.redAccent.shade100));
                            }
                          } else if (productSnapshot.hasError) {
                            productName = 'Error loading product';
                            leadingWidget = Container(width: 60, height: 60, color: Colors.grey.shade300, child: Icon(Icons.error, size: 30, color: Colors.red.shade300));
                          }

                          return Card(
                            elevation: 1,
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Sizes.cardRadiusMd)),
                            margin: EdgeInsets.zero, // Margin sẽ được xử lý bởi ListView.separated
                            child: Padding(
                              padding: const EdgeInsets.all(8.0 /* Sizes.sm */),
                              child: Row(
                                children: [
                                  leadingWidget,
                                  const SizedBox(width: 12.0 /* Sizes.spaceBtwItems / 1.5 */),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(productName, style: textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4.0 /* Sizes.xs */),
                                        Text('Qty: ${orderItem.quantity}', style: textTheme.bodySmall),
                                        Text('Price: \$${orderItem.price.toStringAsFixed(2)} each', style: textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0 /* Sizes.spaceBtwItems / 1.5 */),
                                  Text(
                                    '\$${(orderItem.quantity * orderItem.price).toStringAsFixed(2)}',
                                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: primaryColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 24.0 /* Sizes.spaceBtwSections */),
                _buildSectionTitle('Order Summary', textTheme),
                _buildInfoRow('Subtotal:', '\$${order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)).toStringAsFixed(2)}', textTheme),
                _buildInfoRow('Shipping Fee:', '\$${order.shippingFee.toStringAsFixed(2)}', textTheme),
                _buildInfoRow('Tax:', '\$${order.tax.toStringAsFixed(2)}', textTheme),
                if (order.discountAmount > 0)
                  _buildInfoRow('Discount:', '-\$${order.discountAmount.toStringAsFixed(2)}', textTheme, valueColor: Colors.green.shade700),
                if (order.pointAmount > 0)
                  _buildInfoRow('Points Used (Value):', '-\$${order.pointAmount.toStringAsFixed(2)}', textTheme, valueColor: Colors.green.shade700),
                const Divider(thickness: 1, height: 20.0 /* Sizes.spaceBtwItems * 1.25 */),
                _buildInfoRow('Total Amount:', '\$${order.totalAmount.toStringAsFixed(2)}', textTheme, isLabelBold: true, isValueBold: true, valueColor: primaryColor),

                const SizedBox(height: 24.0 /* Sizes.spaceBtwSections */),
                _buildSectionTitle('Status History', textTheme),
                if (order.statusHistory.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0 /* Sizes.sm */),
                    child: Text("No status history available.", style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.statusHistory.length,
                    itemBuilder: (context, index) {
                      // Hiển thị từ cũ nhất đến mới nhất hoặc ngược lại tùy bạn
                      final history = order.statusHistory[index]; // Hoặc order.statusHistory.reversed.toList()[index]
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0 /* Sizes.xs */),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 10, color: _getStatusColor(stringToOrderStatus(history.status))),
                            const SizedBox(width: 8.0 /* Sizes.sm */),
                            Expanded(child: Text(history.status, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                            Text(DateFormat('dd MMM yy, hh:mm a').format(history.timestamp.toDate()), style: textTheme.bodySmall),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32.0 /* Sizes.spaceBtwSections * 1.3 */),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note_outlined),
                    label: const Text('Update Order Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white, // Hoặc màu tương phản với primaryColor
                      padding: const EdgeInsets.symmetric(horizontal: 24.0 /* Sizes.lg */, vertical: 12.0 /* Sizes.md*0.75 */),
                      textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      _showUpdateStatusDialog(order);
                    },
                  ),
                ),
                const SizedBox(height: 20.0 /* Sizes.defaultSpace * 0.8 */),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0 /* Sizes.sm * 1.5 */),
      child: Text(
        title,
        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, TextTheme textTheme, {Color? valueColor, bool isLabelBold = false, bool isValueBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0 /* Sizes.xs + 2 */),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2, // Label chiếm ít không gian hơn
            child: Text(
                '$label ',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isLabelBold ? FontWeight.bold : FontWeight.normal,
                  color: Colors.grey.shade700, // TColors.textSecondary
                )
            ),
          ),
          Expanded(
            flex: 3, // Value chiếm nhiều không gian hơn, cho phép wrap nếu dài
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor, // Giữ nguyên màu nếu có
                fontWeight: isValueBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}