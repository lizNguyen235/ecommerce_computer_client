import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/consts/consts.dart';
import 'package:ecommerce_computer_client/core/service/AuthService.dart';
import 'package:ecommerce_computer_client/models/order_model.dart';
import 'package:ecommerce_computer_client/utils/colors.dart';
import 'package:ecommerce_computer_client/utils/sizes.dart';
import 'package:ecommerce_computer_client/views/order/components/order_list_item.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedStatus = 'All'; // Default filter: show all orders
  bool _sortByNewest = true; // Default sort: newest first

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().getCurrentUser()?.uid;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'My Orders',
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
        actions: [
          IconButton(
            icon: Icon(
              _sortByNewest ? Iconsax.arrow_circle_down : Iconsax.arrow_circle_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _sortByNewest = !_sortByNewest;
              });
            },
            tooltip: _sortByNewest ? 'Sort by Oldest' : 'Sort by Newest',
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to view orders'))
          : Column(
        children: [
          // Filter and Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: Sizes.sm),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', _selectedStatus == 'All'),
                        const SizedBox(width: Sizes.sm),
                        _buildFilterChip('PENDING', _selectedStatus == 'PENDING'),
                        const SizedBox(width: Sizes.sm),
                        _buildFilterChip('CONFIRMED', _selectedStatus == 'CONFIRMED'),
                        const SizedBox(width: Sizes.sm),
                        _buildFilterChip('SHIPPED', _selectedStatus == 'SHIPPED'),
                        const SizedBox(width: Sizes.sm),
                        _buildFilterChip('DELIVERED', _selectedStatus == 'DELIVERED'),
                        const SizedBox(width: Sizes.sm),
                        _buildFilterChip('CANCELLED', _selectedStatus == 'CANCELLED'),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: userId)
                  .where('status', isEqualTo: _selectedStatus == 'All' ? null : _selectedStatus)
                  .orderBy('createdAt', descending: _sortByNewest)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading orders'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found'));
                }

                final orders = snapshot.data!.docs;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : TColors.dark,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStatus = label;
          });
        }
      },
      selectedColor: TColors.primary,
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}