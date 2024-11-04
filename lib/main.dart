// lib/main.dart
import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'screens/applicant_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Application',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const ApplicantListScreen(),
    );
  }
}
