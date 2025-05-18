import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/orderModels/couponModel.dart';

class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'coupons';
  final List<double> allowedDiscountAmounts = [10.0, 20.0, 50.0, 100.0];

  // Thêm coupon mới
  Future<String?> addCoupon({
    required String code, // Do admin nhập, 5 ký tự
    required double discountAmount,
    required int maxUses,
  }) async {
    if (code.length != 5) {
      throw Exception("Mã coupon phải có đúng 5 ký tự.");
    }
    if (!code.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
      throw Exception("Mã coupon chỉ được chứa chữ và số.");
    }
    if (!allowedDiscountAmounts.contains(discountAmount)) {
      throw Exception("Giá trị giảm giá không hợp lệ.");
    }
    if (maxUses <= 0 || maxUses > 10) {
      throw Exception("Số lần sử dụng tối đa phải từ 1 đến 10.");
    }

    final upperCaseCode = code.toUpperCase();

    // Kiểm tra xem mã (trường 'code') đã tồn tại chưa bằng cách query
    final querySnapshot = await _firestore
        .collection(_collectionPath)
        .where('code', isEqualTo: upperCaseCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception("Mã coupon '$upperCaseCode' đã tồn tại.");
    }

    try {
      // Firestore sẽ tự sinh ID cho document mới
      DocumentReference docRef = _firestore.collection(_collectionPath).doc();

      final coupon = CouponModel(
        id: docRef.id, // Gán ID tự sinh vào model
        code: upperCaseCode,
        discountAmount: discountAmount,
        maxUses: maxUses,
        createdAt: Timestamp.now(),
      );
      await docRef.set(coupon.toJson());
      return docRef.id; // Trả về UID của document mới được tạo
    } catch (e) {
      print('Error adding coupon: $e');
      if (e is Exception && e.toString().contains("Mã coupon")) rethrow;
      throw Exception("Đã xảy ra lỗi khi thêm coupon: ${e.toString()}");
    }
  }

  // Lấy danh sách tất cả coupon (Stream)
  Stream<List<CouponModel>> getCoupons() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return <CouponModel>[];
      return snapshot.docs
          .map((doc) => CouponModel.fromFirestore(doc))
          .toList();
    }).handleError((error, stackTrace) {
      print("Error fetching coupons stream: $error");
      print(stackTrace);
      return <CouponModel>[];
    });
  }

  // Lấy một coupon theo mã (trường 'code')
  Future<CouponModel?> getCouponByCode(String code) async {
    final upperCaseCode = code.toUpperCase();
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .where('code', isEqualTo: upperCaseCode)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CouponModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching coupon by code $upperCaseCode: $e');
      return null;
    }
  }

  // Ghi nhận sử dụng coupon
  Future<bool> recordCouponUsage(String couponCode, String orderId, {FirebaseFirestore? firestoreInstance, Transaction? transaction}) async {
    final db = firestoreInstance ?? _firestore;
    final upperCaseCode = couponCode.toUpperCase();

    try {
      // Tìm document dựa trên trường 'code'
      QuerySnapshot querySnapshot;
      Query couponQuery = db.collection(_collectionPath).where('code', isEqualTo: upperCaseCode).limit(1);

      if (transaction != null) {
        // Firestore transactions không hỗ trợ query trực tiếp bên trong transaction một cách dễ dàng cho tất cả các SDK.
        // Cách an toàn là query ID trước, rồi dùng ID trong transaction.
        // Hoặc, nếu bạn chắc chắn về SDK và môi trường, có thể thử.
        // Để đơn giản và an toàn hơn, chúng ta sẽ get document ID trước khi vào transaction nếu có thể.
        // Tuy nhiên, nếu logic áp dụng coupon và tạo order nằm trong cùng 1 transaction,
        // việc query trước ID là cần thiết.
        // Giả định: transaction được truyền vào khi đã có document ID của coupon.
        // Nếu không, logic này cần điều chỉnh.
        // Hiện tại, ví dụ này sẽ tìm ID trước, không lý tưởng cho transaction phức tạp.
        final tempSnapshot = await couponQuery.get();
        if (tempSnapshot.docs.isEmpty) {
          print("Coupon $upperCaseCode không tồn tại khi ghi nhận sử dụng.");
          return false;
        }
        final couponDocId = tempSnapshot.docs.first.id;
        final couponRef = db.collection(_collectionPath).doc(couponDocId);
        DocumentSnapshot couponSnapshot;

        if (transaction != null) {
          couponSnapshot = await transaction.get(couponRef);
        } else {
          couponSnapshot = await couponRef.get();
        }
        if (!couponSnapshot.exists) {
          print("Coupon $upperCaseCode (ID: $couponDocId) không tồn tại (sau khi query lại).");
          return false;
        }
        CouponModel coupon = CouponModel.fromFirestore(couponSnapshot as DocumentSnapshot<Map<String,dynamic>>);

        if (coupon.usedCount >= coupon.maxUses) {
          print("Coupon $upperCaseCode đã hết lượt sử dụng.");
          return false;
        }

        Map<String, dynamic> updateData = {
          'usedCount': FieldValue.increment(1),
          'usedOrders': FieldValue.arrayUnion([orderId]),
        };

        if (transaction != null) {
          transaction.update(couponRef, updateData);
        } else {
          await couponRef.update(updateData);
        }

      } else { // Không có transaction
        final querySnapshot = await couponQuery.get();
        if (querySnapshot.docs.isEmpty) {
          print("Coupon $upperCaseCode không tồn tại khi ghi nhận sử dụng.");
          return false;
        }
        final couponDoc = querySnapshot.docs.first;
        CouponModel coupon = CouponModel.fromFirestore(couponDoc as DocumentSnapshot<Map<String, dynamic>>);

        if (coupon.usedCount >= coupon.maxUses) {
          print("Coupon $upperCaseCode đã hết lượt sử dụng.");
          return false;
        }
        await couponDoc.reference.update({
          'usedCount': FieldValue.increment(1),
          'usedOrders': FieldValue.arrayUnion([orderId]),
        });
      }
      print("Đã ghi nhận việc sử dụng coupon $upperCaseCode cho đơn hàng $orderId");
      return true;
    } catch (e) {
      print("Lỗi khi ghi nhận sử dụng coupon $upperCaseCode: $e");
      return false;
    }
  }
}