import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyle {
  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static const hint = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );
}
