import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LoyaltyController extends GetxController {
  final String userId; // Assume userId is passed (e.g., from AuthController)
  final RxDouble loyaltyPoints = 0.0.obs; // Current loyalty points
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'loyalty_points';

  LoyaltyController({required this.userId}) {
    _loadPoints();
  }

  // Load loyalty points from Firestore
  Future<void> _loadPoints() async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        loyaltyPoints.value = (doc.data()!['points'] as num).toDouble();
      }
    } catch (e) {
      print('Error loading loyalty points: $e');
    }
  }

  // Save loyalty points to Firestore
  Future<void> _savePoints() async {
    try {
      await _firestore.collection(_collection).doc(userId).set({
        'userId': userId,
        'points': loyaltyPoints.value,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving loyalty points: $e');
    }
  }

  // Earn points: 10% of the order total (in VND)
  void earnPoints(double orderTotal) {
    final pointsEarned = orderTotal * 0.10 / 1000; // 1 point = 1,000 VND
    loyaltyPoints.value += pointsEarned;
    _savePoints();
  }

  // Redeem points: 1 point = 1,000 VND discount
  double redeemPoints(double pointsToRedeem) {
    if (pointsToRedeem > loyaltyPoints.value) {
      pointsToRedeem = loyaltyPoints.value; // Cannot redeem more than available
    }
    final discount = pointsToRedeem * 1000; // 1 point = 1,000 VND
    loyaltyPoints.value -= pointsToRedeem;
    _savePoints();
    return discount;
  }
}