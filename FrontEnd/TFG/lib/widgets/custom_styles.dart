import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomStyles {
  static ButtonStyle botoPrincipal({Size size = const Size(300, 60)}) {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.blau,
      foregroundColor: AppColors.groc,
      minimumSize: size,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
