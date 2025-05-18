import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String id; // UID của document, do Firestore tự sinh
  final String code; // Mã coupon do admin nhập, 5 ký tự
  final double discountAmount; // 10000, 20000, 50000, 100000
  final int maxUses; // Tối đa 10, do admin quyết định
  final int usedCount;
  final List<String> usedOrders;
  final Timestamp createdAt;

  CouponModel({
    required this.id, // Thêm id
    required this.code,
    required this.discountAmount,
    required this.maxUses,
    this.usedCount = 0,
    this.usedOrders = const [],
    required this.createdAt,
  });

  factory CouponModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw Exception("Coupon data is null for document ${snapshot.id}");
    }
    return CouponModel(
      id: snapshot.id, // Lấy id từ snapshot
      code: data['code'] ?? '', // Lấy code từ data
      discountAmount: (data['discountAmount'] ?? 0.0).toDouble(),
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      usedOrders: List<String>.from(data['usedOrders'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code, // Lưu code vào field
      'discountAmount': discountAmount,
      'maxUses': maxUses,
      'usedCount': usedCount,
      'usedOrders': usedOrders,
      'createdAt': createdAt,
      // 'id' không cần lưu vào field vì nó là ID document
    };
  }

  bool get isStillValid {
    if (maxUses == 0) return true;
    return usedCount < maxUses;
  }

  int get remainingUses {
    if (maxUses == 0) return 9999;
    return maxUses - usedCount;
  }
}