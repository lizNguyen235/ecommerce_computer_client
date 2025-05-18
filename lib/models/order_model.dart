import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/models/address_model.dart';

class OrderModel {
  final String userId;
  final Address shippingAddress;
  final String paymentMethod;
  final double shippingFee;
  final double tax;
  final double discountAmount;
  final double pointAmount;
  final double totalAmount;
  final List<Map<String, dynamic>> items; // Includes name
  final DateTime createdAt;
  final String status;
  final List<Map<String, dynamic>> statusHistory;

  OrderModel({
    required this.userId,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.shippingFee,
    required this.tax,
    required this.discountAmount,
    required this.pointAmount,
    required this.totalAmount,
    required this.items,
    required this.createdAt,
    this.status = 'PENDING',
    this.statusHistory = const [],
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'shippingAddress': shippingAddress.toJson(),
    'paymentMethod': paymentMethod,
    'shippingFee': shippingFee,
    'tax': tax,
    'discountAmount': discountAmount,
    'pointAmount': pointAmount,
    'totalAmount': totalAmount,
    'items': items.map((item) => {
      'productId': item['productId'],
      'quantity': item['quantity'],
      'price': item['price'],
      'name': item['name'], // Include name
    }).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status,
    'statusHistory': statusHistory.map((e) => {
      'status': e['status'],
      'timestamp': e['timestamp'] is DateTime ? Timestamp.fromDate(e['timestamp']) : e['timestamp'],
    }).toList(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    userId: json['userId'],
    shippingAddress: Address.fromJson(json['shippingAddress']),
    paymentMethod: json['paymentMethod'],
    shippingFee: json['shippingFee'].toDouble(),
    tax: json['tax'].toDouble(),
    discountAmount: json['discountAmount'].toDouble(),
    pointAmount: json['pointAmount'].toDouble(),
    totalAmount: json['totalAmount'].toDouble(),
    items: List<Map<String, dynamic>>.from(json['items']).map((item) => {
      'productId': item['productId'],
      'quantity': item['quantity'],
      'price': item['price'],
      'name': item['name'], // Include name
    }).toList(),
    createdAt: json['createdAt'] is Timestamp
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.parse(json['createdAt'] as String), // Handle string format
    status: json['status'] ?? 'PENDING',
    statusHistory: List<Map<String, dynamic>>.from(json['statusHistory'] ?? []).map((e) => {
      'status': e['status'],
      'timestamp': e['timestamp'] is Timestamp
          ? (e['timestamp'] as Timestamp).toDate()
          : DateTime.parse(e['timestamp'] as String), // Handle string format
    }).toList(),
  );
}