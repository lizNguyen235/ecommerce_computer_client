import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AppSnackbar {
  static void _show({
    required String title,
    String message = '',
    required Color backgroundColor,
    required IconData icon,
    Color colorText = Colors.white,
    SnackPosition position = SnackPosition.BOTTOM,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: colorText,
      icon: Icon(icon, color: colorText),
      snackPosition: position,
      margin: const EdgeInsets.all(20),
      duration: duration,
      isDismissible: true,
      shouldIconPulse: true,
    );
  }

  /// Cảnh báo (warning)
  static void warning({required String title, String message = ''}) => _show(
    title: title,
    message: message,
    backgroundColor: Colors.orange.shade600,
    icon: Iconsax.warning_2,
  );

  /// Lỗi (error)
  static void error({required String title, String message = ''}) => _show(
    title: title,
    message: message,
    backgroundColor: Colors.red.shade600,
    icon: Iconsax.close_square,
  );

  /// Thành công (success)
  static void success({required String title, String message = ''}) => _show(
    title: title,
    message: message,
    backgroundColor: Colors.green.shade600,
    icon: Iconsax.tick_circle,
  );

  /// Thông tin (info)
  static void info({required String title, String message = ''}) => _show(
    title: title,
    message: message,
    backgroundColor: Colors.blue.shade600,
    icon: Iconsax.info_circle,
  );
}
