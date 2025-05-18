import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/models/product_model.dart';

class CartModel {
  final String userId; // ID của người dùng
  final Map<String, int> items; // Map<ProductID, Quantity>

  CartModel({
    required this.userId,
    required this.items,
  });

  // Chuyển đổi từ Map (Firestore) sang CartModel
  factory CartModel.fromMap(Map<String, dynamic> data, String userId) {
    final Map<String, int> items = Map<String, int>.from(data['items'] ?? {});
    return CartModel(
      userId: userId,
      items: items,
    );
  }

  // Chuyển đổi CartModel sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
    };
  }

  // Tạo một bản sao với các giá trị mới
  CartModel copyWith({
    String? userId,
    Map<String, int>? items,
  }) {
    return CartModel(
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }
}