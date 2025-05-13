import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Bổ sung callback onVerified
Future<void> showOTPDialog(
  BuildContext context, {
  required String email,
  required VoidCallback onVerified,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => OTPVerificationDialog(email: email, onVerified: onVerified),
  );
}

class OTPVerificationDialog extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  const OTPVerificationDialog({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

class _OTPVerificationDialogState extends State<OTPVerificationDialog> {
  bool _isLoading = false;
  bool _canResend = false;
  int _secondsLeft = 60;
  Timer? _timer;

  final List<TextEditingController> _ctrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _fns = List.generate(6, (_) => FocusNode());

  String get _otpCode => _ctrls.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendOTP();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _ctrls) {
      c.dispose();
    }
    for (var f in _fns) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsLeft = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _sendOTP() async {
    // TODO: gọi API gửi OTP tới widget.email
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit code')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://reqres.in/api/users'); // Fake API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': _otpCode}),
      );

      if (response.statusCode == 201) {
        widget.onVerified();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: _ctrls[i],
            focusNode: _fns[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.cyanAccent),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.lightBlueAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white.withAlpha((0.25 * 255).toInt()),
            ),
            onChanged: (v) {
              if (v.length == 1 && i < 5) {
                _fns[i + 1].requestFocus();
              }
              if (v.isEmpty && i > 0) {
                _fns[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final dialogW = w > 600 ? 380.0 : w * 0.9;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: dialogW,
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
              // Header
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Verify Account',
                  style: GoogleFonts.openSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.cyanAccent.withAlpha((0.7 * 255).toInt()),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),

              // Body
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      'Enter the 6-digit code sent to',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.email,
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _buildOtpFields(),
                    const SizedBox(height: 12),
                    _canResend
                        ? TextButton(
                          onPressed: () {
                            _sendOTP();
                            _startTimer();
                          },
                          child: const Text(
                            'Resend Code',
                            style: TextStyle(color: Colors.cyanAccent),
                          ),
                        )
                        : Text(
                          'Resend in $_secondsLeft s',
                          style: GoogleFonts.openSans(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D47A1), Color(0xFF00BCD4)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : _verifyOTP,
                          child:
                              _isLoading
                                  ? const SpinKitCircle(
                                    size: 24,
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Verify',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
