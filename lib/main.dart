import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/pages/home_page.dart';
import 'package:tractian_mobile_engineer_test/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
