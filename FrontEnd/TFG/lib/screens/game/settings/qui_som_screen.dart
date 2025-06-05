import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/texts.dart';

class QuiSomScreen extends StatelessWidget {
  const QuiSomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text(AppTexts.titolQuiSom, style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(AppTexts.textQuiSom, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
