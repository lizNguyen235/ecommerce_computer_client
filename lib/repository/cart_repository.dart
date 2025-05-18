import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce_computer_client/models/cart_model.dart';

class CartRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'carts';

  // Lưu giỏ hàng vào Firestore
  Future<void> saveCart(String userId, CartModel cart) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .set(cart.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving cart: $e');
      rethrow;
    }
  }

  // Lấy giỏ hàng từ Firestore
  Future<CartModel?> getCart(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return CartModel.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      print('Error getting cart: $e');
      rethrow;
    }
  }

  // Xóa giỏ hàng
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}