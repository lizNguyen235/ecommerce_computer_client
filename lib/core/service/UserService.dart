import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'AuthService.dart'; // Cần User để lấy UID

class UserService {
  // Khởi tạo instance của Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService _auth = AuthService();
  // Tham chiếu đến collection 'users' trong Firestore (tên collection có thể tùy chỉnh)
  final CollectionReference usersCollection =
  FirebaseFirestore.instance.collection('users');

  // --- Phương thức tạo/lưu thông tin hồ sơ người dùng ban đầu ---
  // Thường gọi sau khi người dùng đăng ký thành công qua Firebase Auth
  Future<void> createUserProfile({
    required String uid, // UID của người dùng từ Firebase Auth
    required String email, // Email cũng từ Firebase Auth
    required String fullName,
    required String shippingAddress,
    // Thêm các trường thông tin khác nếu cần thiết cho hồ sơ
  }) async {
    try {
      // Sử dụng UID của người dùng làm ID cho document trong collection 'users'
      await usersCollection.doc(uid).set({
        'uid': uid, // Lưu UID (có thể dư vì nó là doc ID, nhưng đôi khi tiện)
        'email': email, // Lưu email (cũng có trong Auth nhưng tiện truy vấn)
        'fullName': fullName,
        'role': 'customer', // Mặc định là 'customer', có thể thay đổi sau
        'shippingAddress': [shippingAddress], // Danh sách địa chỉ giao hàng
        'createdAt': Timestamp.now(), // Thời gian tạo hồ sơ (tùy chọn)
        // Thêm các trường khác (ví dụ: số điện thoại, avatarUrl...)
      });
      print("UserService: User profile created successfully for UID: $uid");
    } catch (e) {
      print("UserService Error (createUserProfile): $e");
      // Ném lại ngoại lệ để lớp gọi (ví dụ: RegisterDialog) có thể bắt và xử lý
      throw e;
    }
  }

  // --- Phương thức đọc thông tin hồ sơ người dùng ---
  // Có thể gọi sau khi người dùng đăng nhập hoặc khi load profile page
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(uid).get();
      if (doc.exists) {
        print("UserService: User profile loaded for UID: $uid");
        // Ép kiểu dữ liệu sang Map<String, dynamic>
        return doc.data() as Map<String, dynamic>?;
      } else {
        print("UserService: No user profile found for UID: $uid");
        return null; // Trả về null nếu không tìm thấy document
      }
    } catch (e) {
      print("UserService Error (getUserProfile): $e");
      throw e; // Ném lại ngoại lệ
    }
  }

  // --- Phương thức cập nhật thông tin hồ sơ người dùng ---
  // Có thể gọi khi người dùng chỉnh sửa thông tin cá nhân
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await usersCollection.doc(uid).update(data);
      print("UserService: User profile updated for UID: $uid");
    } catch (e) {
      print("UserService Error (updateUserProfile): $e");
      throw e; // Ném lại ngoại lệ
    }
  }
// Bạn có thể thêm các phương thức khác liên quan đến dữ liệu người dùng tại đây
// ví dụ: xóa hồ sơ, thêm địa chỉ phụ...
  // --- Phương thức trả về vai trò (role) của người dùng hiện tại ---
  // Tự lấy UID của người dùng đang đăng nhập
  Future<String> getCurrentUserRole() async {
    // Lấy người dùng hiện tại từ Firebase Auth
    User? user = _auth.getCurrentUser(); // Sử dụng instance Auth trong UserService

    // Kiểm tra xem có người dùng nào đang đăng nhập không
    if (user == null) {
      print("UserService: No user logged in. Cannot get role.");
      // Nếu không có người dùng, mặc định trả về role 'guest' hoặc 'anonymous'
      return 'guest'; // hoặc một role phù hợp cho người dùng chưa đăng nhập
    }

    // Nếu có người dùng đăng nhập, sử dụng UID của họ để lấy profile
    String uid = user.uid;

    try {
      // Lấy document hồ sơ của người dùng hiện tại
      DocumentSnapshot doc = await usersCollection.doc(uid).get();

      // Kiểm tra xem document có tồn tại và có dữ liệu không
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Lấy giá trị của trường 'role', mặc định là 'user' nếu không có
        String role = data['role']?.toString() ?? 'user';
        print("UserService: Fetched role '$role' for current user UID: $uid");
        return role;
      } else {
        // Document không tồn tại hoặc dữ liệu là null, mặc định gán role là 'user'
        print("UserService: No profile found or data is null for current user UID: $uid. Returning default role 'user'");
        return 'user';
      }
    } catch (e) {
      // Xử lý lỗi trong quá trình đọc dữ liệu
      print("UserService Error (getCurrentUserRole): $e");
      // Nếu có lỗi khi đọc profile, vẫn nên trả về một role mặc định
      // hoặc ném ngoại lệ tùy thuộc vào chiến lược xử lý lỗi của bạn.
      // Trả về 'user' là một lựa chọn an toàn trong nhiều trường hợp.
      return 'user'; // Trả về mặc định 'user' ngay cả khi có lỗi đọc
      // Hoặc ném ngoại lệ nếu bạn muốn lớp gọi xử lý lỗi này:
      // throw Exception("Failed to get current user role: $e");
    }
  }

}