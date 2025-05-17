import 'package:flutter/material.dart';
import '../utils/colors.dart'; // Điều chỉnh đường dẫn
import '../utils/sizes.dart';  // Điều chỉnh đường dẫn

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor; // Màu chữ và icon
  final double? width;
  final double? height;
  final double? elevation;
  final BorderSide? borderSide;
  final IconData? icon;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 50.0, // Chiều cao nút mặc định
    this.elevation,
    this.borderSide,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color defaultBackgroundColor = TColors.primary;
    final Color defaultForegroundColor = Colors.white;

    return SizedBox(
      width: width ?? double.infinity, // Mặc định chiếm toàn bộ chiều rộng
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Vô hiệu hóa khi isLoading
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? TColors.buttonDisabled : (backgroundColor ?? defaultBackgroundColor),
          foregroundColor: foregroundColor ?? defaultForegroundColor,
          textStyle: textStyle ?? TextStyle(
            fontSize: Sizes.fontSizeMd,
            fontWeight: FontWeight.w600,
            color: foregroundColor ?? defaultForegroundColor, // Đảm bảo màu chữ cũng theo foregroundColor
          ),
          padding: const EdgeInsets.symmetric(vertical: Sizes.sm, horizontal: Sizes.md), // Điều chỉnh padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Sizes.buttonRadius),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: isLoading ? 0 : elevation, // Bỏ elevation khi loading
          // minimumSize: Size(width ?? double.infinity, height ?? 50), // Cách khác để đặt size
        ).copyWith(
          // Xử lý màu nền khi nút bị disable (onPressed == null hoặc isLoading == true)
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return TColors.buttonDisabled.withOpacity(0.7); // Màu khi disable
              }
              return backgroundColor ?? defaultBackgroundColor; // Màu khi enable
            },
          ),
          // Xử lý màu chữ khi nút bị disable
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.disabled)) {
                return TColors.dark; // Màu chữ khi disable
              }
              return foregroundColor ?? defaultForegroundColor; // Màu chữ khi enable
            },
          ),
        ),
        child: isLoading
            ? SizedBox(
          width: Sizes.iconMd, // Kích thước cho CircularProgressIndicator
          height: Sizes.iconMd,
          child: CircularProgressIndicator(
            color: foregroundColor ?? defaultForegroundColor,
            strokeWidth: 2.5,
          ),
        )
            : Row( // Sử dụng Row để có icon và text
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: Sizes.iconMd - 2), // Hiển thị icon nếu có
            if (icon != null && text.isNotEmpty) const SizedBox(width: Sizes.sm / 2), // Khoảng cách nếu có cả icon và text
            if (text.isNotEmpty) Text(text),
          ],
        ),
      ),
    );
  }
}