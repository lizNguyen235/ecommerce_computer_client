import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/service/OrderService.dart';
import '../data/orderModels/order_model.dart';
import 'order_detail_screen.dart';
// import '../utils/colors.dart'; // TColors
// import '../utils/sizes.dart'; // Sizes

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final OrderService _orderService = OrderService();
  OrderTimeFilter _selectedFilter = OrderTimeFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  // For pagination with StreamBuilder, we typically don't manage lastDocument directly in state
  // if we rebuild the StreamBuilder with new parameters.
  // If you were using FutureBuilder and manual "Load More", you'd need it.
  // For simplicity with StreamBuilder, we'll refetch the stream with new limits or filters.
  // However, if you want true "load more" behavior with a Stream, it's more complex.
  // For now, let's assume we refetch the entire (filtered) list when changing pages or filters.
  // A more advanced pagination would involve keeping track of loaded documents.

  // This is a simplified pagination control.
  // A real app might use a package like `infinite_scroll_pagination`.
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument; // For manual pagination if not using Stream for everything

  @override
  void initState() {
    super.initState();
    // _loadOrders(); // If using manual pagination
  }

  // Example for manual pagination (not used with the current StreamBuilder setup directly)
  /*
  Future<void> _loadOrders({bool loadMore = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // This approach requires getOrders to return a Future<List<OrderModel>>
      // and handle lastDocument. The current getOrders returns a Stream.
      // You'd need a separate method in OrderService for Future-based fetching.
      // For now, we'll rely on the StreamBuilder to handle updates.
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
  */


  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Cho phép chọn đến 1 năm sau
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedFilter = OrderTimeFilter.customRange;
        _lastDocument = null; // Reset pagination
        _orders.clear(); // Clear current orders to refetch
        // _loadOrders(); // If using manual pagination
      });
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: OrderTimeFilter.values.map((filter) {
          bool isSelected = _selectedFilter == filter;
          if (filter == OrderTimeFilter.customRange && (_customStartDate == null || _customEndDate == null) && _selectedFilter != OrderTimeFilter.customRange) {
            // Don't show custom range chip initially if no range selected, unless it's the active filter
          }

          String label = "";
          switch(filter) {
            case OrderTimeFilter.all: label = "All"; break;
            case OrderTimeFilter.today: label = "Today"; break;
            case OrderTimeFilter.yesterday: label = "Yesterday"; break;
            case OrderTimeFilter.thisWeek: label = "This Week"; break;
            case OrderTimeFilter.thisMonth: label = "This Month"; break;
            case OrderTimeFilter.customRange:
              label = _customStartDate != null && _customEndDate != null
                  ? "${DateFormat('dd/MM').format(_customStartDate!)} - ${DateFormat('dd/MM/yy').format(_customEndDate!)}"
                  : "Custom Range";
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (filter == OrderTimeFilter.customRange) {
                  _selectDateRange(context);
                } else {
                  setState(() {
                    _selectedFilter = filter;
                    _customStartDate = null;
                    _customEndDate = null;
                    _lastDocument = null; // Reset pagination
                    _orders.clear();
                    // _loadOrders();
                  });
                }
              },
              // selectedColor: TColors.primary.withOpacity(0.8),
              // checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Order Management")), // Already handled by AdminMainPage
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // Key ensures StreamBuilder rebuilds when filter changes
              key: ValueKey("${_selectedFilter.toString()}-${_customStartDate?.toIso8601String()}-${_customEndDate?.toIso8601String()}"),
              stream: _orderService.getOrders(
                filter: _selectedFilter,
                customStartDate: _customStartDate,
                customEndDate: _customEndDate,
                // lastDocument: _lastDocument, // For pagination, StreamBuilder makes this tricky
                // without manual stream management.
                // This simple setup re-fetches first 20 on filter change.
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No orders found for the selected filter.'));
                }

                _orders = snapshot.data!; // Update local list for potential manual "load more"

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0 /*Sizes.sm*/),
                  itemCount: _orders.length, // + (_hasMore ? 1 : 0) for load more indicator
                  itemBuilder: (context, index) {
                    // if (index == _orders.length && _hasMore) {
                    //   return Center(child: CircularProgressIndicator()); // Load more indicator
                    // }
                    final order = _orders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text('Order ID: ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('User: ${order.shippingAddress.name} (${order.userId.substring(0,6)}...)'), // Show part of user ID
                            Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt.toDate())}'),
                            Text('Total: \$${order.totalAmount.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                orderStatusToString(order.status),
                                style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(orderId: order.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Simple pagination buttons (conceptual)
          // A real implementation would need more robust state management for _lastDocument
          // and fetching the next set of data.
          /*
          if (_orders.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(onPressed: null, child: Text("Previous")), // Needs logic
                  ElevatedButton(
                    onPressed: _hasMore && !_isLoading ? () {
                      // Need to fetch the actual last document from the current _orders list
                      // if _orderService.getOrders is adapted for manual pagination.
                      // For now, this is a placeholder.
                      // _loadOrders(loadMore: true);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Load More (WIP)")));
                    } : null,
                    child: Text("Next Page")
                  ),
                ],
              ),
            )
          */
        ],
      ),
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
}