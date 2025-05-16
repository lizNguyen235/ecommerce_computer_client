import 'package:cloud_firestore/cloud_firestore.dart';

class ConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Biến để lưu trữ adminUid sau khi lấy lần đầu, tránh query lại nhiều lần
  String? _cachedAdminUid;

  // Phương thức để lấy adminUid
  // Có thể trả về null nếu không tìm thấy hoặc có lỗi
  Future<String?> getAdminUid() async {
    // Nếu đã có trong cache, trả về ngay
    if (_cachedAdminUid != null && _cachedAdminUid!.isNotEmpty) {
      return _cachedAdminUid;
    }

    try {
      // Truy cập document '/config/admin'
      DocumentSnapshot adminConfigDoc =
      await _firestore.collection('config').doc('admin').get();

      if (adminConfigDoc.exists) {
        // Lấy dữ liệu từ document
        Map<String, dynamic>? data =
        adminConfigDoc.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey('adminUid')) {
          final String adminUid = data['adminUid'] as String;
          if (adminUid.isNotEmpty) {
            _cachedAdminUid = adminUid; // Lưu vào cache
            return _cachedAdminUid;
          } else {
            print('ConfigService: adminUid field is empty in /config/admin.');
            return null;
          }
        } else {
          print('ConfigService: adminUid field not found in /config/admin document.');
          return null;
        }
      } else {
        print('ConfigService: /config/admin document does not exist.');
        return null;
      }
    } catch (e) {
      print('ConfigService: Error fetching adminUid - ${e.toString()}');
      // Bạn có thể xử lý lỗi cụ thể hơn ở đây nếu cần
      // Ví dụ: throw Exception('Could not fetch admin configuration.');
      return null;
    }
  }

  // (Tùy chọn) Phương thức để xóa cache nếu cần (ví dụ: khi admin thay đổi)
  void clearCachedAdminUid() {
    _cachedAdminUid = null;
  }

  // (Tùy chọn) Nếu bạn muốn lấy adminUid một cách đồng bộ sau khi đã fetch lần đầu
  // Hoặc nếu bạn chắc chắn nó đã được fetch trong quá trình khởi tạo app.
  // Cẩn thận khi dùng phương thức này, nó có thể trả về null nếu chưa fetch.
  String? getAdminUidSynchronous() {
    if (_cachedAdminUid == null || _cachedAdminUid!.isEmpty) {
      print('ConfigService (Synchronous): adminUid not fetched or is empty. Call getAdminUid() first.');
    }
    return _cachedAdminUid;
  }
}