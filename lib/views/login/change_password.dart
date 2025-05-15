import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/service/AuthService.dart';
// Import các files style của bạn
import '../../utils/colors.dart'; // Giả định đường dẫn này
import '../../utils/sizes.dart';   // Giả định đường dẫn này
import '../../consts/colors.dart'; // Giả định đường dẫn này
import '../../widgets/appbar.dart'; // Giả định TAppBar widget
import 'package:iconsax/iconsax.dart'; // Giả định bạn sử dụng Iconsax

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final AuthService _authService = AuthService();

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      User? user = _authService.getCurrentUser();

      if (user == null) {
        setState(() {
          _errorMessage = "Không tìm thấy người dùng đang đăng nhập. Vui lòng đăng nhập lại.";
          _isLoading = false;
        });
        return;
      }

      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        print("User re-authenticated successfully.");

        await _authService.updatePassword(_newPasswordController.text);

        print("Password updated successfully.");
        setState(() {
          _successMessage = "Mật khẩu của bạn đã được thay đổi thành công!";
          // Xóa nội dung các trường mật khẩu sau khi thành công
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'wrong-password') {
          message = 'Mật khẩu cũ không đúng. Vui lòng thử lại.';
        } else if (e.code == 'too-many-requests') {
          message = 'Đã có quá nhiều lần thử không thành công. Vui lòng thử lại sau ít phút.';
        } else if (e.code == 'weak-password') {
          message = 'Mật khẩu mới quá yếu (ít nhất 6 ký tự).';
        } else if (e.code == 'requires-recent-login') {
          message = 'Thao tác cần xác thực gần đây. Vui lòng đăng xuất và đăng nhập lại.';
        }
        else {
          message = 'Đã xảy ra lỗi xác thực: ${e.message}';
        }
        print("Firebase Auth Error during password change: ${e.code}");
        setState(() {
          _errorMessage = message;
        });

      } catch (e) {
        print("General Error during password change: $e");
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi không xác định: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng AppBar tùy chỉnh tương tự AddressScreen
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          'Đổi mật khẩu', // Tiêu đề tùy chỉnh
          style: TextStyle(
            color: Colors.black, // Màu đen như AddressScreen
            fontSize: 24, // Kích thước như AddressScreen
            fontWeight: FontWeight.w600, // Độ đậm như AddressScreen
          ),
        ),
        // Back arrow color? TAppBar của bạn có thể cần tùy chỉnh màu back arrow
        // leading: IconButton(icon: Icon(Iconsax.arrow_left, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: whiteColor, // Nền trắng như AddressScreen
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Sizes.defaultSpace), // Padding chung như AddressScreen
          child: Center( // Center nội dung form
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24), // Padding bên trong container
              decoration: BoxDecoration(
                color: whiteColor, // Nền trắng cho container form
                borderRadius: BorderRadius.circular(20), // Border radius như Login/Register
                boxShadow: const [
                  BoxShadow( // Shadow như Login/Register
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Text(
                      "Đổi mật khẩu tài khoản của bạn",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22, // Giảm kích thước tiêu đề một chút so với Create Account
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30), // Khoảng cách sau tiêu đề

                    // Trường nhập Mật khẩu cũ
                    _inputField(
                      controller: _currentPasswordController,
                      label: "Mật khẩu cũ",
                      hint: "Nhập mật khẩu hiện tại",
                      icon: Iconsax.lock_circle, // Iconsax icon
                      obscure: _obscureCurrent,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureCurrent ? Iconsax.eye_slash : Iconsax.eye, // Iconsax toggle icon
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() => _obscureCurrent = !_obscureCurrent);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Mật khẩu cũ không được để trống";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Sizes.md), // Sử dụng kích thước từ Sizes

                    // Trường nhập Mật khẩu mới
                    _inputField(
                      controller: _newPasswordController,
                      label: "Mật khẩu mới",
                      hint: "Nhập mật khẩu mới (ít nhất 6 ký tự)",
                      icon: Iconsax.lock, // Iconsax icon
                      obscure: _obscureNew,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureNew ? Iconsax.eye_slash : Iconsax.eye, // Iconsax toggle icon
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() => _obscureNew = !_obscureNew);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Mật khẩu mới không được để trống";
                        }
                        if (value.length < 6) {
                          return "Mật khẩu mới phải có ít nhất 6 ký tự";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Sizes.md), // Sử dụng kích thước từ Sizes

                    // Trường Xác nhận mật khẩu mới
                    _inputField(
                      controller: _confirmNewPasswordController,
                      label: "Xác nhận mật khẩu mới",
                      hint: "Nhập lại mật khẩu mới",
                      icon: Iconsax.lock, // Iconsax icon
                      obscure: _obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Iconsax.eye_slash : Iconsax.eye, // Iconsax toggle icon
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Xác nhận mật khẩu không được để trống";
                        }
                        if (value != _newPasswordController.text) {
                          return "Mật khẩu xác nhận không khớp";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: Sizes.defaultSpace), // Khoảng cách trước nút

                    // Hiển thị thông báo lỗi hoặc thành công
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Sizes.md), // Padding dưới thông báo lỗi
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Sizes.md), // Padding dưới thông báo thành công
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Nút Đổi mật khẩu (Style tương tự Login/Register)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43C6AC), Color(0xFF191654)], // Gradient tương tự
                        ),
                        borderRadius: BorderRadius.circular(30), // Border radius tương tự
                      ),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: whiteColor)) // Màu trắng cho loading
                          : ElevatedButton(
                        onPressed: _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          // foregroundColor: whiteColor, // Text color, có thể thiết lập ở đây hoặc child
                        ),
                        child: const Text(
                          "Đổi mật khẩu",
                          style: TextStyle(color: whiteColor, fontSize: 18), // Màu chữ trắng
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method cho input fields - Cập nhật style
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      validator: validator ?? (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label không được để trống";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        filled: true,
        fillColor: const Color(0xFFF3F6FB), // Màu nền input field
        prefixIcon: Icon(icon, color: Colors.grey[800]), // Màu icon
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder( // Border style
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder( // Focused border style
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TColors.primary, width: 1.6), // Sử dụng TColors.primary
        ),
        errorBorder: OutlineInputBorder( // Error border style
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder( // Focused error border style
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.6),
        ),
      ),
    );
  }
}