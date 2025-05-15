import 'package:ecommerce_computer_client/views/home/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/service/AuthService.dart';
import '../../core/service/UserService.dart'; // Cần import để xử lý FirebaseAuthException
// Import các Services đã tạo

class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<RegisterDialog> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các trường nhập
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Controller Mật khẩu
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Biến trạng thái cho UI
  bool _obscure = true; // Trạng thái ẩn/hiện mật khẩu
  bool _isLoading = false; // Trạng thái loading khi đang xử lý
  String? _errorMessage; // Thông báo lỗi

  // Instantiate AuthService và UserService
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Phương thức xử lý khi người dùng nhấn nút Đăng ký
  Future<void> _submitRegister() async {
    // Xóa thông báo lỗi cũ và reset trạng thái loading
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (_formKey.currentState!.validate()) {
      // Form hợp lệ, bắt đầu quá trình đăng ký
      setState(() {
        _isLoading = true; // Bật loading indicator
      });

      try {
        // BƯỚC 1: Đăng ký tài khoản với Firebase Authentication
        // Sử dụng AuthService để gọi hàm đăng ký
        User? user = await _authService.signUpWithEmailPassword(
          _emailController.text.trim(), // Lấy email từ controller và loại bỏ khoảng trắng
          _passwordController.text, // Lấy mật khẩu từ controller
        );

        // Nếu đăng ký Firebase Auth thành công (user không null)
        if (user != null) {
          print("User registered in Auth: ${user.uid}");

          // BƯỚC 2: LƯU THÔNG TIN HỒ SƠ VÀO FIRESTORE
          // Sử dụng UserService để gọi hàm lưu hồ sơ
          await _userService.createUserProfile(
            uid: user.uid, // Sử dụng UID của người dùng vừa đăng ký làm ID document
            email: user.email ?? _emailController.text.trim(), // Lấy email từ user hoặc controller
            fullName: _fullNameController.text.trim(), // Lấy họ tên từ controller
            shippingAddress: _addressController.text.trim(), // Lấy địa chỉ từ controller
          );

          print("User profile saved in Firestore for UID: ${user.uid}");

          // BƯỚC 3: Xử lý sau khi đăng ký và lưu hồ sơ thành công
          // Hiển thị thông báo thành công
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")),
          );
          // Điều hướng về trang Đăng nhập (thường là pop route hiện tại)
          Navigator.pop(context);

        } else {
          // Trường hợp này hiếm xảy ra với signInWithEmailAndPassword vì nó thường ném ngoại lệ
          // Nhưng thêm để xử lý dự phòng.
          setState(() {
            _errorMessage = 'Đăng ký không thành công (lỗi không xác định từ Auth).';
          });
        }

      } on FirebaseAuthException catch (e) {
        // Bắt các lỗi cụ thể từ Firebase Authentication (được ném lại bởi AuthService)
        String message;
        if (e.code == 'weak-password') {
          message = 'Mật khẩu quá yếu (ít nhất 6 ký tự).';
        } else if (e.code == 'email-already-in-use') {
          message = 'Email này đã được sử dụng.';
        } else if (e.code == 'invalid-email') {
          message = 'Định dạng email không hợp lệ.';
        } else if (e.code == 'operation-not-allowed') {
          message = 'Đăng ký bằng Email/Mật khẩu chưa được bật trong Firebase.';
        }
        // Thêm các trường hợp xử lý lỗi khác nếu cần thiết
        else {
          message = 'Đã xảy ra lỗi xác thực: ${e.message}';
        }
        print("Firebase Auth Error during registration: ${e.code}");
        setState(() {
          _errorMessage = message; // Cập nhật thông báo lỗi để hiển thị trên UI
        });

      } catch (e) {
        // Bắt các lỗi khác (bao gồm lỗi từ UserService hoặc lỗi chung)
        print("General Error during registration or profile save: $e");
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi trong quá trình đăng ký hoặc lưu hồ sơ: $e'; // Cập nhật thông báo lỗi chung
        });
      } finally {
        // Luôn dừng trạng thái loading sau khi hoàn thành (thành công hoặc thất bại)
        setState(() {
          _isLoading = false; // Tắt loading indicator
        });
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng Controllers khi Widget bị hủy để tránh rò rỉ bộ nhớ
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar đã bị loại bỏ trong thiết kế ban đầu, giữ nguyên
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center( // Căn giữa nội dung
          child: SingleChildScrollView( // Cho phép cuộn nếu nội dung vượt quá kích thước màn hình
            child: Column(
              mainAxisSize: MainAxisSize.min, // Kích thước cột nhỏ nhất có thể
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 400), // Giới hạn chiều rộng
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey, // Gắn GlobalKey cho Form để validate
                    child: Column(
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Trường nhập Email
                        _inputField(
                          controller: _emailController,
                          label: "Email",
                          hint: "Enter your email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress, // Kiểu bàn phím email
                          validator: (value) { // Validator cho Email
                            if (value == null || value.trim().isEmpty) {
                              return "Email không được để trống";
                            }
                            // Tùy chọn: Thêm regex kiểm tra định dạng email cơ bản (Firebase Auth cũng kiểm tra)
                            // if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            //   return "Định dạng email không hợp lệ";
                            // }
                            return null; // Hợp lệ
                          },
                        ),
                        const SizedBox(height: 20),

                        // Trường nhập Mật khẩu (MỚI THÊM)
                        _inputField(
                          controller: _passwordController,
                          label: "Mật khẩu",
                          hint: "Tạo mật khẩu (ít nhất 6 ký tự)", // Hint kèm yêu cầu độ dài
                          icon: Icons.lock,
                          obscure: _obscure, // Sử dụng trạng thái _obscure để ẩn/hiện
                          keyboardType: TextInputType.text, // Kiểu bàn phím text
                          validator: (value) { // Validator cho Mật khẩu
                            if (value == null || value.trim().isEmpty) {
                              return "Mật khẩu không được để trống";
                            }
                            if (value.length < 6) { // Firebase Auth yêu cầu tối thiểu 6 ký tự
                              return "Mật khẩu phải có ít nhất 6 ký tự";
                            }
                            return null; // Hợp lệ
                          },
                          suffix: IconButton( // Icon ở cuối để toggle ẩn/hiện
                            icon: Icon(
                              _obscure // Chọn icon dựa trên trạng thái
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                            onPressed: () {
                              setState(() => _obscure = !_obscure); // Đảo ngược trạng thái _obscure
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Trường nhập Họ và tên
                        _inputField(
                          controller: _fullNameController,
                          label: "Họ và tên",
                          hint: "Nhập đầy đủ họ và tên của bạn",
                          icon: Icons.person,
                          keyboardType: TextInputType.name, // Kiểu bàn phím tên
                          validator: (value) { // Validator Họ tên
                            if (value == null || value.trim().isEmpty) {
                              return "Họ và tên không được để trống";
                            }
                            return null; // Hợp lệ
                          },
                        ),
                        const SizedBox(height: 20),

                        // Trường nhập Địa chỉ giao hàng
                        _inputField(
                          controller: _addressController,
                          label: "Địa chỉ giao hàng",
                          hint: "Nhập địa chỉ giao hàng của bạn",
                          icon: Icons.location_on,
                          keyboardType: TextInputType.streetAddress, // Kiểu bàn phím địa chỉ
                          validator: (value) { // Validator Địa chỉ
                            if (value == null || value.trim().isEmpty) {
                              return "Địa chỉ giao hàng không được để trống";
                            }
                            return null; // Hợp lệ
                          },
                        ),
                        const SizedBox(height: 20),

                        // Hiển thị thông báo lỗi nếu có (_errorMessage không null)
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              _errorMessage!, // Hiển thị nội dung lỗi
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Nút Đăng ký
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43C6AC), Color(0xFF191654)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: _isLoading // Nếu đang loading, hiển thị loading indicator
                              ? const Center(child: CircularProgressIndicator(color: Colors.white))
                              : ElevatedButton( // Ngược lại, hiển thị nút
                            onPressed: _submitRegister, // Gắn phương thức xử lý đăng ký
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "REGISTER",
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),

                        // Text và Nút chuyển về trang Login (thường là trang gọi đến Register)
                        const SizedBox(height: 20),
                        const Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            // Quay trở lại trang trước (thường là trang Login)
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ⬅ Nút quay về home dưới dialog (giữ nguyên logic này nếu cần)
                const SizedBox(height: 20), // Thêm khoảng cách
                IconButton(
                  icon: const Icon(Icons.home, size: 28, color: Colors.black),
                  onPressed: () {
                    // Điều hướng về Home và xóa tất cả route trước đó
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const Home()),
                          (route) => false,
                    );
                  },
                ),
                const Text(
                  "Back to Home",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method cho input fields - Cập nhật để linh hoạt hơn
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false, // Mặc định false
    Widget? suffix, // Tùy chọn suffix widget
    TextInputType keyboardType = TextInputType.text, // Mặc định text
    String? Function(String?)? validator, // Tùy chọn validator function
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      // Sử dụng validator được cung cấp hoặc validator mặc định kiểm tra rỗng
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
        fillColor: const Color(0xFFF3F6FB),
        prefixIcon: Icon(icon, color: Colors.grey[800]),
        suffixIcon: suffix, // Sử dụng suffix widget
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00B4DB), width: 1.6),
        ),
      ),
    );
  }
}