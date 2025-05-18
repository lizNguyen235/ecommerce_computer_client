import 'package:ecommerce_computer_client/views/home/home.dart';
import 'package:flutter/material.dart';
import '../../core/service/AuthService.dart';
import '../../core/service/UserService.dart';
import '../login/register.dart'; // Assuming RegisterDialog is in this file
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  final TextEditingController _emailController =
      TextEditingController(); // Changed from _usernameController
  final TextEditingController _passwordController = TextEditingController();

  // Instantiate the AuthService
  final AuthService _authService = AuthService();

  // State variables for loading and error
  bool _isLoading = false;
  String? _errorMessage;
  final UserService _userService = UserService();
  Future<void> _submitLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      try {
        // BƯỚC 1: Đăng nhập bằng Firebase Auth
        User? user = await _authService.signInWithEmailPassword(
          email,
          password,
        );

        // BƯỚC 2: Nếu đăng nhập Auth thành công, kiểm tra trạng thái isBanned từ Firestore
        if (user != null) {

          Map<String, dynamic>? userProfile = await _userService.getUserProfile(user.uid);

          if (userProfile == null) {
            // Trường hợp hiếm: User tồn tại trong Auth nhưng không có profile trong Firestore
            // Có thể xử lý bằng cách tạo profile ở đây hoặc báo lỗi.
            // Tạm thời, chúng ta sẽ đăng xuất và báo lỗi.
            await _authService.signOut(); // Đăng xuất người dùng
            setState(() {
              _errorMessage = 'Không tìm thấy thông tin hồ sơ người dùng. Vui lòng thử lại.';
              // _isLoading = false; // Sẽ được set trong finally
            });
            print("Login Aborted: User ${user.uid} authenticated but no Firestore profile found.");
            return; // Dừng quá trình
          }

          final bool isBanned = userProfile['isBanned'] as bool? ?? false;
          if (isBanned) {
            // Nếu người dùng bị ban, đăng xuất họ ngay lập tức
            await _authService.signOut();
            setState(() {
              _errorMessage = 'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên.';
              // _isLoading = false; // Sẽ được set trong finally
            });
            print("Login Aborted: User ${user.uid} is banned.");
            return; // Dừng quá trình
          }

          // Nếu không bị ban và có profile, đăng nhập thành công
          print("User logged in successfully: ${user.uid}");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const Home()),
                (route) => false,
          );
        } else {
          // Trường hợp này ít xảy ra vì signInWithEmailPassword thường ném lỗi nếu thất bại
          setState(() {
            _errorMessage = 'Đăng nhập không thành công (lỗi không xác định từ Auth).';
            // _isLoading = false; // Sẽ được set trong finally
          });
        }
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Không tìm thấy người dùng cho email này.';
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          message = 'Sai mật khẩu.';
        } else if (e.code == 'invalid-email') {
          message = 'Định dạng email không hợp lệ.';
        } else if (e.code == 'user-disabled') {
          message = 'Tài khoản người dùng đã bị vô hiệu hóa bởi hệ thống.';
        } else {
          message = 'Đã xảy ra lỗi xác thực: ${e.message}';
        }
        print("Firebase Auth Error during login: ${e.code}");
        setState(() {
          _errorMessage = message;
          // _isLoading = false; // Sẽ được set trong finally
        });
      } catch (e) {
        // Lỗi từ UserService.getUserProfile hoặc các lỗi mạng khác
        print("General Error during login: $e");
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi: $e';
          // _isLoading = false; // Sẽ được set trong finally
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // --- Phương thức xử lý quên mật khẩu ---
  Future<void> _forgotPassword() async {
    // Lấy email từ trường nhập email.
    String email = _emailController.text.trim();

    // Kiểm tra xem email có rỗng không
    if (email.isEmpty) {
      // Hiển thị thông báo yêu cầu nhập email
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập địa chỉ email của bạn.")),
      );
      return; // Dừng hàm
    }

    setState(() {
      _isLoading = true; // Bật loading indicator
      _errorMessage = null; // Xóa lỗi cũ
    });

    try {
      // Gọi phương thức gửi email reset mật khẩu từ AuthService
      await _authService.sendPasswordResetEmail(email);

      // Nếu thành công, hiển thị thông báo cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Link đặt lại mật khẩu đã được gửi tới ${email}. Vui lòng kiểm tra hòm thư.",
          ),
        ),
      );
      print("Password reset email sent to $email");
    } on FirebaseAuthException catch (e) {
      // Xử lý các lỗi cụ thể từ Firebase Auth khi gửi email reset
      String message;
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng với email này.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng email không hợp lệ.';
      }
      // Thêm các lỗi khác nếu cần (ví dụ: 'auth/missing-email')
      else {
        message = 'Đã xảy ra lỗi khi gửi email đặt lại mật khẩu: ${e.message}';
      }
      print("Firebase Auth Error sending reset email: ${e.code}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _errorMessage =
            message; // Tùy chọn: cũng hiển thị lỗi dưới form nếu muốn
      });
    } catch (e) {
      // Xử lý các lỗi khác
      print("General Error sending reset email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xảy ra lỗi không xác định: $e')),
      );
      setState(() {
        _errorMessage =
            'Đã xảy ra lỗi không xác định: $e'; // Tùy chọn: cũng hiển thị lỗi dưới form
      });
    } finally {
      // Luôn dừng trạng thái loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar as it's a fullscreen dialog/page simulation
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
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
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email Field (formerly Username)
                        _inputField(
                          controller: _emailController,
                          label: "Email", // Changed label
                          hint: "Enter your email", // Changed hint
                          icon: Icons.email, // Changed icon
                          obscure: false,
                          keyboardType:
                              TextInputType.emailAddress, // Added keyboard type
                          validator: (value) {
                            // Added specific email validator
                            if (value == null || value.trim().isEmpty) {
                              return "Email cannot be empty";
                            }
                            // Optional: Basic email format validation (Firebase Auth will validate more strictly)
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              // return "Please enter a valid email format";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        _inputField(
                          controller: _passwordController,
                          label: "Password",
                          hint: "Enter your password",
                          icon: Icons.lock,
                          obscure: _obscure,
                          keyboardType:
                              TextInputType.text, // Added keyboard type
                          validator: (value) {
                            // Added password validator
                            if (value == null || value.trim().isEmpty) {
                              return "Password cannot be empty";
                            }
                            // Optional: Add minimum length validation
                            // if (value.length < 6) {
                            //   return "Password must be at least 6 characters";
                            // }
                            return null;
                          },
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                            onPressed: () {
                              setState(() => _obscure = !_obscure);
                            },
                          ),
                        ),

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),

                        // Display error message if any
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43C6AC), Color(0xFF191654)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child:
                              _isLoading // Conditionally show loading or button
                                  ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : ElevatedButton(
                                    onPressed:
                                        _submitLogin, // Call the login method
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      "LOGIN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ), // Added font size
                                    ),
                                  ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "Don’t have an account?",
                          style: TextStyle(color: Colors.black54),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Register page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterDialog(),
                              ),
                            );
                          },
                          child: const Text(
                            "Register",
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

                // ⬅ Nút quay về home dưới dialog
                const SizedBox(height: 20), // Add spacing
                IconButton(
                  icon: const Icon(Icons.home, size: 28, color: Colors.black),
                  onPressed: () {
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

  // Helper method for input fields
  Widget _inputField({
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    Widget? suffix,
    required TextEditingController controller,
    TextInputType keyboardType =
        TextInputType.text, // Added keyboard type with default
    String? Function(String?)? validator, // Made validator optional
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType, // Use provided keyboard type
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      validator:
          validator ??
          (value) {
            // Use provided validator or default (non-empty)
            if (value == null || value.trim().isEmpty) {
              return "$label cannot be empty";
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
        suffixIcon: suffix,
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
