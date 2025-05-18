import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Đăng nhập ẩn danh
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      print("Signed in anonymously with UID: ${result.user?.uid}");
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (signInAnonymously): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (signInAnonymously) - General: $e");
      throw e;
    }
  }

  // Đăng nhập bằng email và mật khẩu
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (signIn): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (signIn) - General: $e");
      throw e;
    }
  }

  // Đăng ký bằng email và mật khẩu
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (signUp): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (signUp) - General: $e");
      throw e;
    }
  }

  // Liên kết tài khoản ẩn danh với tài khoản email/mật khẩu
  Future<void> linkAnonymousWithEmail(String email, String password) async {
    User? anon = _auth.currentUser;
    if (anon == null || !anon.isAnonymous) {
      throw Exception("No anonymous user to link.");
    }
    try {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      await anon.linkWithCredential(credential);
      print("Linked anonymous account with email: $email");
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (linkWithCredential): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (linkWithCredential) - General: $e");
      throw e;
    }
  }

  // Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      print("AuthService: Email đặt lại mật khẩu đã được gửi tới $email");
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (resetPassword): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (resetPassword) - General: $e");
      throw e;
    }
  }

  // Đổi mật khẩu
  Future<void> updatePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("AuthService Error (updatePassword): Không có người dùng đăng nhập.");
      throw Exception("User not logged in.");
    }
    try {
      await user.updatePassword(newPassword);
      print("AuthService: Mật khẩu đã được cập nhật thành công.");
    } on FirebaseAuthException catch (e) {
      print("AuthService Error (updatePassword): ${e.code} - ${e.message}");
      throw e;
    } catch (e) {
      print("AuthService Error (updatePassword) - General: $e");
      throw e;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print("AuthService: Đăng xuất thành công.");
    } catch (e) {
      print("AuthService Error (signOut): $e");
      throw e;
    }
  }

  // Lấy người dùng hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Theo dõi trạng thái xác thực
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }



  Future<void> upgradeAnonymousUserToEmail({
    required String email,
    required String password,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null || !user.isAnonymous) {
        print('Người dùng hiện tại không ở chế độ ẩn danh');
        return;
      }

      // Tạo thông tin đăng nhập email/password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Liên kết với người dùng hiện tại
      UserCredential result = await user.linkWithCredential(credential);

      print("Nâng cấp tài khoản thành công! UID: ${result.user?.uid}");
      print("Email mới: ${result.user?.email}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Email này đã được sử dụng bởi tài khoản khác.");
      } else {
        print('Lỗi khi nâng cấp tài khoản: ${e.message}');
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
    }
  }
}