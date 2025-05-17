import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cho TextInputFormatter
import '../utils/colors.dart';      // Điều chỉnh đường dẫn nếu cần
import '../utils/sizes.dart';       // Điều chỉnh đường dẫn nếu cần

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool obscureText;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? initialValue; // Dùng nếu không muốn truyền controller
  final bool readOnly;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      initialValue: initialValue, // Sẽ bị bỏ qua nếu controller được cung cấp
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.labelMedium?.copyWith(color: TColors.textSecondary),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: TColors.dark) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.borderPrimary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.borderPrimary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Sizes.inputFieldRadius),
          borderSide: BorderSide(color: TColors.dark.withOpacity(0.5)),
        ),
        filled: !enabled, // Chỉ tô màu nền khi disabled
        fillColor: !enabled ? (isDark ? TColors.dark.withOpacity(0.5) : TColors.light.withOpacity(0.7)) : null,
        contentPadding: const EdgeInsets.symmetric(vertical: Sizes.sm + 4, horizontal: Sizes.md -2), // Điều chỉnh padding
      ),
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines, // obscureText chỉ hoạt động với maxLines = 1
      validator: validator,
      obscureText: obscureText,
      enabled: enabled,
      onTap: onTap,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      readOnly: readOnly,
      style: textTheme.bodyLarge?.copyWith(color: enabled ? (isDark ? TColors.light : TColors.dark) : TColors.dark),
    );
  }
}