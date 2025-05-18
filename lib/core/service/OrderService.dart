import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/orderModels/order_model.dart';
import '../../data/orderModels/order_status_history_model.dart';

// Định nghĩa các khoảng thời gian lọc
enum OrderTimeFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
  customRange,
}

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'orders';
  final int _itemsPerPage = 20; // Số item mỗi trang

  // Lấy danh sách đơn hàng với phân trang và lọc
  Stream<List<OrderModel>> getOrders({
    OrderTimeFilter filter = OrderTimeFilter.all,
    DateTime? customStartDate,
    DateTime? customEndDate,
    DocumentSnapshot? lastDocument, // For pagination
  }) {
    Query query = _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true); // Sắp xếp mới nhất trước

    // Áp dụng bộ lọc thời gian
    DateTime now = DateTime.now();
    DateTime startOfQuery;
    DateTime endOfQuery;

    switch (filter) {
      case OrderTimeFilter.today:
        startOfQuery = DateTime(now.year, now.month, now.day); // 00:00:00 hôm nay
        endOfQuery = DateTime(now.year, now.month, now.day, 23, 59, 59, 999); // 23:59:59 hôm nay
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfQuery))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfQuery));
        break;
      case OrderTimeFilter.yesterday:
        DateTime yesterday = now.subtract(const Duration(days: 1));
        startOfQuery = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endOfQuery = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59, 999);
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfQuery))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfQuery));
        break;
      case OrderTimeFilter.thisWeek:
      // Tuần bắt đầu từ Thứ Hai (weekday 1) đến Chủ Nhật (weekday 7)
        int currentWeekday = now.weekday; // Monday is 1, Sunday is 7
        startOfQuery = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1)); // Về đầu tuần (Thứ Hai)
        endOfQuery = startOfQuery.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999)); // Cuối tuần (Chủ Nhật)
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfQuery))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfQuery));
        break;
      case OrderTimeFilter.thisMonth:
        startOfQuery = DateTime(now.year, now.month, 1);
        endOfQuery = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999); // Ngày cuối cùng của tháng hiện tại
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfQuery))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfQuery));
        break;
      case OrderTimeFilter.customRange:
        if (customStartDate != null && customEndDate != null) {
          startOfQuery = DateTime(customStartDate.year, customStartDate.month, customStartDate.day);
          endOfQuery = DateTime(customEndDate.year, customEndDate.month, customEndDate.day, 23, 59, 59, 999);
          query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfQuery))
              .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endOfQuery));
        }
        break;
      case OrderTimeFilter.all:
      default:
      // Không cần thêm điều kiện where cho 'createdAt' nếu là 'all'
        break;
    }

    // Áp dụng phân trang
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    query = query.limit(_itemsPerPage);

    return query.snapshots().map((snapshot) { // snapshot là QuerySnapshot<Map<String, dynamic>>
      if (snapshot.docs.isEmpty) {
        return <OrderModel>[]; // TRẢ VỀ List<OrderModel> RỖNG
      }
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList(); // Trả về List<OrderModel>
    }).handleError((error, stackTrace) { // Thêm stackTrace để debug tốt hơn
      print("Error fetching orders stream: $error");
      print(stackTrace);
      // Quan trọng: handleError nên trả về một List<OrderModel> hoặc ném lỗi nếu
      // StreamBuilder của bạn mong đợi List<OrderModel> và không xử lý lỗi tốt.
      // Trả về danh sách rỗng thường là một cách an toàn để UI không bị crash.
      return <OrderModel>[];
    });
  }

  // Lấy chi tiết một đơn hàng
  Stream<OrderModel?> getOrderDetails(String orderId) {
    return _firestore
        .collection(_collectionPath)
        .doc(orderId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return OrderModel.fromFirestore(snapshot as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    }).handleError((error) {
      print("Error fetching order details for $orderId: $error");
      return null;
    });
  }

  // Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus, {String? adminNotes}) async {
    try {
      DocumentReference orderRef = _firestore.collection(_collectionPath).doc(orderId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(orderRef);
        if (!snapshot.exists) {
          throw Exception("Order does not exist!");
        }

        // Lấy lịch sử trạng thái hiện tại
        List<dynamic> currentStatusHistory = (snapshot.data() as Map<String, dynamic>)['statusHistory'] ?? [];
        List<Map<String, dynamic>> newStatusHistory = List<Map<String, dynamic>>.from(currentStatusHistory);


        // Thêm trạng thái mới vào lịch sử
        newStatusHistory.add(OrderStatusHistoryModel(
          status: orderStatusToString(newStatus),
          timestamp: Timestamp.now(),
          // Ghi chú của admin có thể được thêm vào đây nếu model OrderStatusHistoryModel hỗ trợ
        ).toMap());

        transaction.update(orderRef, {
          'status': orderStatusToString(newStatus),
          'statusHistory': newStatusHistory,
          // Thêm trường 'lastUpdatedAt' nếu cần
          'lastUpdatedAt': Timestamp.now(),
        });
      });
      return true;
    } catch (e) {
      print('Error updating order status for $orderId: $e');
      return false;
    }
  }

  // Helper để lấy document cuối cùng cho phân trang (nếu bạn dùng get thay vì stream)
  // Nếu dùng stream, bạn sẽ quản lý lastDocument trong State của Widget
  Future<DocumentSnapshot?> fetchLastDocumentForPage({
    OrderTimeFilter filter = OrderTimeFilter.all,
    DateTime? customStartDate,
    DateTime? customEndDate,
    int pageNumber = 1, // Bắt đầu từ trang 1
  }) async {
    if (pageNumber <= 1) return null;

    Query query = _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true);

    // Áp dụng bộ lọc thời gian tương tự như getOrders
    // ... (code lọc thời gian giống như trên) ...

    query = query.limit(_itemsPerPage * (pageNumber - 1));
    QuerySnapshot querySnapshot = await query.get();
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.last;
    }
    return null;
  }
}