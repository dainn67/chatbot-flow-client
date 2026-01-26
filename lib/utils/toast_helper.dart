import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Helper class để hiển thị toast messages
class ToastHelper {
  /// Hiển thị toast thông báo thành công
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF4CAF50),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Hiển thị toast thông báo lỗi
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: const Color(0xFFD32F2F),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Hiển thị toast thông báo cảnh báo
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFFFC107),
      textColor: Colors.black87,
      fontSize: 16.0,
    );
  }

  /// Hiển thị toast thông báo thông tin
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF2196F3),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  /// Hiển thị toast tùy chỉnh
  static void showCustom({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Toast? toastLength,
    ToastGravity? gravity,
    int? timeInSecForIosWeb,
    double? fontSize,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: toastLength ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: timeInSecForIosWeb ?? 2,
      backgroundColor: backgroundColor ?? Colors.grey[800],
      textColor: textColor ?? Colors.white,
      fontSize: fontSize ?? 16.0,
    );
  }

  /// Hủy tất cả toast đang hiển thị
  static void cancelAllToasts() {
    Fluttertoast.cancel();
  }
}

