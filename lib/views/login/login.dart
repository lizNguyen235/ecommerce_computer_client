import 'dart:ui';
import 'package:client/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'registration_page.dart';
import 'forgot_reset_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _rememberMe = false; // ✅ Thêm biến Remember Me
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (_emailCtrl.text.trim().isNotEmpty &&
          _pwdCtrl.text.trim().isNotEmpty) {
        bool isVerify = await login(
          _emailCtrl.text.trim(),
          _pwdCtrl.text.trim(),
          rememberMe: _rememberMe,
        );

        if (isVerify) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: Invalid credentials')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email and password are required')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardW = w > 600 ? 400.0 : w * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/tech_background.png',
            fit: BoxFit.cover,
            color: Colors.black.withAlpha((0.6 * 255).toInt()),
            colorBlendMode: BlendMode.darken,
          ),
          Center(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: cardW,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withAlpha((0.85 * 255).toInt()),
                      const Color(0xFF0D47A1).withAlpha((0.75 * 255).toInt()),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.cyanAccent.withAlpha((0.8 * 255).toInt()),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withAlpha((0.3 * 255).toInt()),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- HEADER ---
                    Container(
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Welcome Back',
                        style: GoogleFonts.openSans(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.cyanAccent.withAlpha(
                                (0.7 * 255).toInt(),
                              ),
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- FORM ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email
                            TextFormField(
                              controller: _emailCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withAlpha(
                                  (0.25 * 255).toInt(),
                                ),
                                labelText: 'Email',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: Colors.cyanAccent,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: const TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.orangeAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator:
                                  MultiValidator([
                                    RequiredValidator(
                                      errorText: 'Email is required',
                                    ),
                                    EmailValidator(errorText: 'Invalid email'),
                                  ]).call,
                            ),
                            const SizedBox(height: 16),

                            // Password
                            TextFormField(
                              controller: _pwdCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withAlpha(
                                  (0.25 * 255).toInt(),
                                ),
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: Colors.cyanAccent,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.lightBlueAccent,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.deepOrangeAccent,
                                    width: 2,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 2,
                                  ),
                                ),
                                errorStyle: const TextStyle(
                                  color: Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 8,
                                      color: Colors.orangeAccent,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              obscureText: true,
                              validator:
                                  RequiredValidator(
                                    errorText: 'Password is required',
                                  ).call,
                            ),

                            // ✅ Remember Me + Forgot password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: Colors.cyanAccent,
                                    ),
                                    Text(
                                      'Remember Me',
                                      style: GoogleFonts.openSans(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder:
                                          (_) => const ForgotPasswordDialog(),
                                    );
                                  },
                                  child: Text(
                                    'Forgot password?',
                                    style: GoogleFonts.openSans(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF0D47A1),
                                      Color(0xFF00BCD4),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                  ),
                                  onPressed: _isLoading ? null : _login,
                                  child:
                                      _isLoading
                                          ? const SpinKitCircle(
                                            size: 24,
                                            color: Colors.white,
                                          )
                                          : Text(
                                            'Login',
                                            style: GoogleFonts.openSans(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Sign up link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: GoogleFonts.openSans(
                                    color: Colors.white70,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => showRegistrationDialog(context),
                                  child: Text(
                                    'Sign up',
                                    style: GoogleFonts.openSans(
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
