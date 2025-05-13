import 'dart:ui';
import 'package:client/services/authservice.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showRegistrationDialog(BuildContext ctx) {
  return showDialog(
    context: ctx,
    barrierDismissible: false,
    builder: (_) => const RegistrationDialog(),
  );
}

class RegistrationDialog extends StatefulWidget {
  const RegistrationDialog({super.key});
  @override
  State<RegistrationDialog> createState() => _RegistrationDialogState();
}

class _RegistrationDialogState extends State<RegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePwd = true;

  final _nameCtrl = TextEditingController();
  String? _gender;
  final _dobCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _dobCtrl.text =
          "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      var isSuccess = await register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        gender: _gender ?? '',
      );
      if (isSuccess) {
        await showDialog(
          context: context,
          barrierDismissible: false, // không cho thoát bằng cách bấm ra ngoài
          builder:
              (context) => AlertDialog(
                title: const Text(
                  'Thành công',
                  style: TextStyle(color: Colors.green),
                ),
                content: Text("Bạn đã đăng ký tài khoản thành công"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(), // đóng dialog
                    child: const Text('Đóng'),
                  ),
                ],
              ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration failed!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Register error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withAlpha((0.25 * 255).toInt()),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.cyanAccent),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.cyanAccent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.lightBlueAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.deepOrangeAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.orangeAccent, width: 2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final dialogW = screenW > 600 ? 400.0 : screenW * 0.9;
    final maxH = MediaQuery.of(context).size.height * 0.8;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
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
          constraints: BoxConstraints(maxWidth: dialogW, maxHeight: maxH),
          child: Column(
            children: [
              // HEADER
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Create Account',
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

              // SCROLLABLE FORM
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name + Gender
                        LayoutBuilder(
                          builder: (ctx, cons) {
                            if (cons.maxWidth > 350) {
                              return Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextFormField(
                                      controller: _nameCtrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: _inputDecoration(
                                        'Name',
                                        Icons.person_outline,
                                      ),
                                      validator:
                                          RequiredValidator(
                                            errorText: 'Name is required',
                                          ).call,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _gender,
                                      dropdownColor: Colors.black,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      decoration: _inputDecoration(
                                        'Gender',
                                        Icons.transgender,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'Male',
                                          child: Text(
                                            'Male',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Female',
                                          child: Text(
                                            'Female',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'Other',
                                          child: Text(
                                            'Other',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                      onChanged:
                                          (v) => setState(() => _gender = v),
                                      validator:
                                          (v) =>
                                              v == null
                                                  ? 'Select gender'
                                                  : null,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  TextFormField(
                                    controller: _nameCtrl,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      'Name',
                                      Icons.person_outline,
                                    ),
                                    validator:
                                        RequiredValidator(
                                          errorText: 'Name is required',
                                        ).call,
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value: _gender,
                                    dropdownColor: Colors.black,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _inputDecoration(
                                      'Gender',
                                      Icons.transgender,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Male',
                                        child: Text(
                                          'Male',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Female',
                                        child: Text(
                                          'Female',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Other',
                                        child: Text(
                                          'Other',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                    onChanged:
                                        (v) => setState(() => _gender = v),
                                    validator:
                                        (v) =>
                                            v == null ? 'Select gender' : null,
                                  ),
                                ],
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _dobCtrl,
                          readOnly: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Date of Birth',
                            Icons.calendar_today,
                          ),
                          onTap: _pickDate,
                          validator:
                              RequiredValidator(
                                errorText: 'DOB is required',
                              ).call,
                        ),

                        // Account Info Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Colors.white30),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Account Info',
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Divider(color: Colors.white30),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Email',
                            Icons.email_outlined,
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
                        const SizedBox(height: 12),

                        // Security Divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: [
                              const Expanded(
                                child: Divider(color: Colors.white30),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Security',
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Divider(color: Colors.white30),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePwd,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Password',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePwd
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.cyanAccent,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePwd = !_obscurePwd,
                                  ),
                            ),
                          ),
                          validator:
                              MultiValidator([
                                RequiredValidator(
                                  errorText: 'Password is required',
                                ),
                                PatternValidator(
                                  r'^(?=.*[!@#\$&*~]).{6,}$',
                                  errorText:
                                      'Min 6 chars & at least 1 special char',
                                ),
                              ]).call,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscurePwd,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            'Confirm Password',
                            Icons.lock_outline,
                          ),
                          validator:
                              (val) => MatchValidator(
                                errorText: 'Passwords do not match',
                              ).validateMatch(val ?? '', _passwordCtrl.text),
                        ),

                        const SizedBox(height: 24),
                        // Register Button
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
                              ),
                              onPressed: _isLoading ? null : _submit,
                              child:
                                  _isLoading
                                      ? const SpinKitCircle(
                                        size: 24,
                                        color: Colors.white,
                                      )
                                      : Text(
                                        'Register',
                                        style: GoogleFonts.openSans(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Back to Login',
                            style: GoogleFonts.openSans(
                              color: Colors.cyanAccent,
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
        ),
      ),
    );
  }
}
