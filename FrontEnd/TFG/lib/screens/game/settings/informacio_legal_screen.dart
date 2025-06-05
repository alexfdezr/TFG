import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/texts.dart';

class InformacioLegalScreen extends StatelessWidget {
  const InformacioLegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blau,
        title: const Text(AppTexts.titolInformacioLegal, style: TextStyle(color: AppColors.groc)),
        centerTitle: true,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(AppTexts.textInformacioLegal, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
