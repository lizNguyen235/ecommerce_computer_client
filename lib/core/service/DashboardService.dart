import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Duration _defaultTimeout = const Duration(seconds: 20);

  // Helper function để lấy giá trị số một cách an toàn
  num _getSafeNum(dynamic value, {num defaultValue = 0}) {
    if (value is num) {
      return value;
    } else if (value is String) {
      return num.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  Future<Map<String, dynamic>> getGlobalMetrics() async {
    const String debugPrefix = "DEBUG_SERVICE: getGlobalMetrics";
    print("$debugPrefix - START");
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection("dashboardMetrics").doc("global").get()
          .timeout(_defaultTimeout, onTimeout: () {
        print("$debugPrefix - TIMEOUT");
        throw FirebaseException(plugin: 'Firestore', code: 'deadline-exceeded', message: 'Timeout fetching global metrics');
      });

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        print("$debugPrefix - SUCCESS, Raw Data from Firestore: $data");

        final result = {
          'totalUsers': _getSafeNum(data['totalUsers']).toInt(),
          'totalOrders': _getSafeNum(data['totalOrders']).toInt(),
          'totalRevenue': _getSafeNum(data['totalRevenue']).toDouble(),
          'lastUpdated': data['lastUpdated'] as Timestamp?, // lastUpdated phải là Timestamp
        };
        print("$debugPrefix - Parsed Data to be returned: $result");
        return result;
      }
      print("$debugPrefix - Document does not exist or data is null. Returning defaults.");
      return {'totalUsers': 0, 'totalOrders': 0, 'totalRevenue': 0.0, 'lastUpdated': null};
    } catch (e, s) {
      print("$debugPrefix - ERROR: $e\n$s");
      // Trong trường hợp lỗi, cũng trả về cấu trúc tương tự để tránh lỗi null ở screen
      return {'totalUsers': 0, 'totalOrders': 0, 'totalRevenue': 0.0, 'lastUpdated': null};
    }
  }

  Future<int> getNewUsersInRange(DateTime startDate, DateTime endDate) async {
    const String debugPrefix = "DEBUG_SERVICE: getNewUsersInRange";
    int totalNewUsers = 0;
    print("$debugPrefix - START, Range: $startDate to $endDate");
    try {
      final DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore
          .collection("dailyStats")
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get()
          .timeout(_defaultTimeout, onTimeout: () {
        print("$debugPrefix - TIMEOUT");
        throw FirebaseException(plugin: 'Firestore', code: 'deadline-exceeded', message: 'Timeout fetching new users in range');
      });

      print("$debugPrefix - Fetched ${snapshot.docs.length} dailyStats documents.");
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("$debugPrefix - Processing dailyStat doc ${doc.id}: $data");
        totalNewUsers += _getSafeNum(data['newUsers']).toInt();
      }
      print("$debugPrefix - SUCCESS, Total new users: $totalNewUsers");
      return totalNewUsers;
    } catch (e, s) {
      print("$debugPrefix - ERROR: $e\n$s");
      return 0;
    }
  }

  Future<Map<String, num>> getOrdersAndRevenueInRange(DateTime startDate, DateTime endDate) async {
    const String debugPrefix = "DEBUG_SERVICE: getOrdersAndRevenueInRange";
    int totalOrders = 0;
    double totalRevenue = 0.0;
    print("$debugPrefix - START, Range: $startDate to $endDate");
    try {
      final DateTime startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore
          .collection("dailyStats")
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get()
          .timeout(_defaultTimeout, onTimeout: () {
        print("$debugPrefix - TIMEOUT");
        throw FirebaseException(plugin: 'Firestore', code: 'deadline-exceeded', message: 'Timeout fetching orders and revenue');
      });

      print("$debugPrefix - Fetched ${snapshot.docs.length} dailyStats documents.");
      for (var doc in snapshot.docs) {
        final data = doc.data();
        print("$debugPrefix - Processing dailyStat doc ${doc.id}: $data");
        totalOrders += _getSafeNum(data['ordersCount']).toInt();
        totalRevenue += _getSafeNum(data['revenue']).toDouble();
      }
      print("$debugPrefix - SUCCESS, Orders: $totalOrders, Revenue: $totalRevenue");
      return {'ordersCount': totalOrders, 'revenue': totalRevenue};
    } catch (e, s) {
      print("$debugPrefix - ERROR: $e\n$s");
      return {'ordersCount': 0, 'revenue': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getBestSellingProductsFromSummary({int limit = 5}) async {
    const String debugPrefix = "DEBUG_SERVICE: getBestSellingProductsFromSummary";
    print("$debugPrefix - START, Limit: $limit");
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await _firestore
          .collection("productSalesSummary")
          .orderBy("totalQuantitySold", descending: true)
          .limit(limit)
          .get()
          .timeout(_defaultTimeout, onTimeout: () {
        print("$debugPrefix - TIMEOUT");
        throw FirebaseException(plugin: 'Firestore', code: 'deadline-exceeded', message: 'Timeout fetching best selling products');
      });

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        print("$debugPrefix - Processing productSummary doc ${doc.id}: $data");
        return {
          'productId': doc.id, // Hoặc data['productId'] nếu bạn lưu nó trong document data
          'name': data['productName'] as String? ?? 'Unknown Product',
          'quantitySold': _getSafeNum(data['totalQuantitySold']).toInt(),
          // 'lastSaleDate': data['lastSaleDate'] as Timestamp?, // Nếu bạn cần
        };
      }).toList();
      print("$debugPrefix - SUCCESS, Count: ${products.length}");
      return products;
    } catch (e, s) {
      print("$debugPrefix - ERROR: $e\n$s");
      return [];
    }
  }
}