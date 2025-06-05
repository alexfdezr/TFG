import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/texts.dart';

class NotificacionsScreen extends StatelessWidget {
  const NotificacionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text(AppTexts.titolNotificacions, style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          AppTexts.textNotificacionsPlaceholder,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
