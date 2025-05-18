import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/order/components/order_list_item.dart';
import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().getCurrentUser()?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Đơn Hàng Của Tôi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: userId == null
          ? const Center(child: Text('Vui lòng đăng nhập để xem đơn hàng'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải đơn hàng'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng nào'));
          }

          final orders = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(Sizes.defaultSpace),
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: Sizes.spaceBtwItems),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index].data() as Map<String, dynamic>;
                final order = OrderModel.fromJson(orderData);
                final orderId = orders[index].id;

                return OrderListItem(order: order, orderId: orderId);
              },
            ),
          );
        },
      ),
    );
  }
}