import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';
import 'shipping_address_model.dart';
import 'order_status_history_model.dart';

// Định nghĩa các trạng thái đơn hàng có thể có
enum OrderStatus {
  PENDING,
  CONFIRMED,
  PROCESSING, // Đang xử lý/đóng gói
  SHIPPED,    // Đã giao cho đơn vị vận chuyển
  DELIVERED,  // Đã giao thành công
  CANCELLED,  // Đã hủy
  RETURNED,   // Đã trả hàng
  REFUNDED,   // Đã hoàn tiền
  UNKNOWN     // Trạng thái không xác định
}

// Helper để chuyển đổi String sang Enum và ngược lại
OrderStatus stringToOrderStatus(String? statusStr) {
  statusStr = statusStr?.toUpperCase();
  switch (statusStr) {
    case 'PENDING':
      return OrderStatus.PENDING;
    case 'CONFIRMED':
      return OrderStatus.CONFIRMED;
    case 'PROCESSING':
      return OrderStatus.PROCESSING;
    case 'SHIPPED':
      return OrderStatus.SHIPPED;
    case 'DELIVERED':
      return OrderStatus.DELIVERED;
    case 'CANCELLED':
      return OrderStatus.CANCELLED;
    case 'RETURNED':
      return OrderStatus.RETURNED;
    case 'REFUNDED':
      return OrderStatus.REFUNDED;
    default:
      print("Unknown order status string: $statusStr");
      return OrderStatus.UNKNOWN;
  }
}

String orderStatusToString(OrderStatus status) {
  return status.toString().split('.').last;
}

class OrderModel {
  final String id; // Document ID từ Firestore
  final String? couponCode;
  final Timestamp createdAt;
  final double discountAmount;
  final List<OrderItemModel> items;
  final String paymentMethod;
  final double pointAmount; // Số điểm đã sử dụng
  final ShippingAddressModel shippingAddress;
  final double shippingFee;
  final OrderStatus status;
  final List<OrderStatusHistoryModel> statusHistory;
  final double tax;
  final double totalAmount; // Tổng tiền cuối cùng sau khi đã trừ discount, cộng phí ship, tax
  final String userId;

  OrderModel({
    required this.id,
    this.couponCode,
    required this.createdAt,
    required this.discountAmount,
    required this.items,
    required this.paymentMethod,
    required this.pointAmount,
    required this.shippingAddress,
    required this.shippingFee,
    required this.status,
    required this.statusHistory,
    required this.tax,
    required this.totalAmount,
    required this.userId,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("Order data is null for document ${snapshot.id}");
    }

    return OrderModel(
      id: snapshot.id,
      couponCode: data['couponCode'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      items: (data['items'] as List<dynamic>?)
          ?.map((itemMap) => OrderItemModel.fromMap(itemMap as Map<String, dynamic>))
          .toList() ??
          [],
      paymentMethod: data['paymentMethod'] ?? 'UNKNOWN',
      pointAmount: (data['pointAmount'] ?? 0.0).toDouble(),
      shippingAddress: ShippingAddressModel.fromMap(data['shippingAddress'] as Map<String, dynamic>? ?? {}),
      shippingFee: (data['shippingFee'] ?? 0.0).toDouble(),
      status: stringToOrderStatus(data['status']),
      statusHistory: (data['statusHistory'] as List<dynamic>?)
          ?.map((historyMap) => OrderStatusHistoryModel.fromMap(historyMap as Map<String, dynamic>))
          .toList() ??
          [],
      tax: (data['tax'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'couponCode': couponCode,
      'createdAt': createdAt,
      'discountAmount': discountAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'paymentMethod': paymentMethod,
      'pointAmount': pointAmount,
      'shippingAddress': shippingAddress.toMap(),
      'shippingFee': shippingFee,
      'status': orderStatusToString(status),
      'statusHistory': statusHistory.map((history) => history.toMap()).toList(),
      'tax': tax,
      'totalAmount': totalAmount,
      'userId': userId,
    };
  }
}