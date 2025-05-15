import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // Khởi tạo instance của FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Phương thức Đăng nhập bằng email và mật khẩu ---
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Trả về đối tượng User nếu đăng nhập thành công
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Authentication
      // Ném lại (re-throw) ngoại lệ để lớp gọi có thể bắt và xử lý lỗi
      print("AuthService Error (signIn): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      // Xử lý các lỗi khác
      print("AuthService Error (signIn) - General: $e");
      // Ném lại ngoại lệ chung
      throw e;
    }
  }

  // --- Phương thức Đăng ký bằng email và mật khẩu ---
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Trả về đối tượng User nếu đăng ký thành công
      return result.user;
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Authentication khi đăng ký
      print("AuthService Error (signUp): ${e.code} - ${e.message}");
      // Ví dụ các lỗi phổ biến khi đăng ký:
      // 'email-already-in-use'
      // 'invalid-email'
      // 'operation-not-allowed'
      // 'weak-password'
      throw e; // Ném lại ngoại lệ
    } catch (e) {
      // Xử lý các lỗi khác
      print("AuthService Error (signUp) - General: $e");
      throw e; // Ném lại ngoại lệ chung
    }
  }

  // --- Phương thức Quên mật khẩu (Gửi email đặt lại mật khẩu) ---
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim()); // Sử dụng trim()
      // Phương thức này không trả về gì khi thành công, chỉ cần hoàn thành
      print("AuthService: Email đặt lại mật khẩu đã được gửi tới $email");
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Authentication khi gửi email reset
      print("AuthService Error (resetPassword): ${e.code} - ${e.message}");
      // Ví dụ các lỗi phổ biến:
      // 'user-not-found'
      // 'invalid-email'
      throw e; // Ném lại ngoại lệ
    } catch (e) {
      // Xử lý các lỗi khác
      print("AuthService Error (resetPassword) - General: $e");
      throw e; // Ném lại ngoại lệ chung
    }
  }

  // --- Phương thức Đổi mật khẩu cho người dùng hiện tại ---
  // Lưu ý: Firebase có thể yêu cầu người dùng đăng nhập lại gần đây
  // trước khi cho phép đổi mật khẩu vì lý do bảo mật.
  // Nếu không, bạn có thể gặp lỗi 'requires-recent-login'.
  // Để xử lý, bạn cần yêu cầu người dùng nhập lại mật khẩu cũ và gọi user.reauthenticateWithCredential(...)
  // trước khi gọi updatePassword. Ví dụ này chỉ gọi updatePassword trực tiếp.
  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser; // Lấy người dùng hiện tại

    if (user == null) {
      // Không có người dùng nào đang đăng nhập
      print("AuthService Error (updatePassword): Không có người dùng đăng nhập.");
      // Ném một ngoại lệ tùy chỉnh hoặc FirebaseAuthException
      throw Exception("User not logged in."); // Hoặc FirebaseAuthException(code: 'user-not-logged-in', message: '...')
    }

    try {
      await user.updatePassword(newPassword);
      print("AuthService: Mật khẩu đã được cập nhật thành công.");
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể của Firebase Authentication khi đổi mật khẩu
      print("AuthService Error (updatePassword): ${e.code} - ${e.message}");
      // Ví dụ các lỗi phổ biến:
      // 'weak-password'
      // 'requires-recent-login' (phổ biến nhất nếu người dùng không đăng nhập lại gần đây)
      throw e; // Ném lại ngoại lệ
    } catch (e) {
      // Xử lý các lỗi khác
      print("AuthService Error (updatePassword) - General: $e");
      throw e; // Ném lại ngoại lệ chung
    }
  }

  // --- Phương thức Đăng xuất ---
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("AuthService: Đăng xuất thành công.");
    } catch (e) {
      print("AuthService Error (signOut): $e");
      throw e; // Ném lại ngoại lệ
    }
  }

  // --- Getter để lấy người dùng hiện tại ---
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- Stream để theo dõi trạng thái xác thực ---
  // Rất hữu ích để tự động chuyển hướng người dùng khi đăng nhập/đăng xuất
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}