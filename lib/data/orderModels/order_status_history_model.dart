import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusHistoryModel {
  final String status;
  final Timestamp timestamp;

  OrderStatusHistoryModel({
    required this.status,
    required this.timestamp,
  });

  factory OrderStatusHistoryModel.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistoryModel(
      status: map['status'] ?? 'UNKNOWN',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }
}