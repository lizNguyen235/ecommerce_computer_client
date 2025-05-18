import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/service/CouponService.dart';
import '../data/orderModels/couponModel.dart';
import 'add_coupon_dialog.dart';
// import '../utils/colors.dart';
// import '../utils/sizes.dart';

class CouponManagementScreen extends StatefulWidget {
  const CouponManagementScreen({super.key});

  @override
  State<CouponManagementScreen> createState() => _CouponManagementScreenState();
}

class _CouponManagementScreenState extends State<CouponManagementScreen> {
  final CouponService _couponService = CouponService();
  // Sử dụng NumberFormat để hiển thị giá trị USD
  final NumberFormat _usdFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  void _showAddCouponDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddCouponDialog(couponService: _couponService);
      },
    );
  }

  void _showCouponDetailsDialog(CouponModel coupon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Coupon Details: ${coupon.code}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildDetailRow('Code:', coupon.code),
                _buildDetailRow('Discount Value:', _usdFormatter.format(coupon.discountAmount)), // <<--- HIỂN THỊ USD
                _buildDetailRow('Created:', DateFormat('dd MMM yyyy, hh:mm a').format(coupon.createdAt.toDate())),
                _buildDetailRow('Used:', '${coupon.usedCount} times'),
                _buildDetailRow('Max Uses:', '${coupon.maxUses} times'),
                _buildDetailRow('Remaining:', '${coupon.remainingUses} times'),
                const SizedBox(height: 10),
                const Text('Applied to Orders:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (coupon.usedOrders.isEmpty)
                  const Text('Not applied to any orders yet.', style: TextStyle(fontStyle: FontStyle.italic))
                else
                  ...coupon.usedOrders.map((orderId) => Text('- $orderId')).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<CouponModel>>(
        stream: _couponService.getCoupons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Error in CouponManagementScreen StreamBuilder: ${snapshot.error}");
            return Center(child: Text('Error loading coupons: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No coupons found. Create a new one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0 /*Sizes.fontSizeLg*/, color: Colors.grey /*TColors.textSecondary*/),
                ),
              ),
            );
          }

          final coupons = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0 /*Sizes.sm*/),
            itemCount: coupons.length,
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              final bool isAvailable = coupon.isStillValid;
              final Color statusColor = isAvailable ? Colors.green /*TColors.success*/ : Colors.red /*TColors.error*/;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: InkWell(
                  onTap: () => _showCouponDetailsDialog(coupon),
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              coupon.code,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Text(
                                isAvailable ? "Active" : "Exhausted",
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Value: ${_usdFormatter.format(coupon.discountAmount)}', // <<--- HIỂN THỊ USD
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Usage: ${coupon.usedCount} / ${coupon.maxUses}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Created: ${DateFormat('dd MMM yyyy').format(coupon.createdAt.toDate())}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4.0),
                        LinearProgressIndicator(
                          value: coupon.maxUses > 0 ? coupon.usedCount / coupon.maxUses : 0,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCouponDialog,
        label: const Text('Create Coupon'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}