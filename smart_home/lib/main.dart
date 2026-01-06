// lib/main.dart (نسخه اصلاح شده)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_home/screens/login_screen.dart';
import 'package:smart_home/screens/splash_screen.dart';
import 'package:smart_home/theme/app_theme.dart';
import 'package:smart_home/theme/theme_provider.dart';

void main() {
  runApp(
    // ۱. اضافه کردن Provider در بالاترین سطح ویجت‌ها
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});




  @override
  Widget build(BuildContext context) {
    // ۲. خواندن Provider برای تعیین تم برنامه
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Smart Home',
      // ۳. اتصال تم‌ها و حالت تم از Provider
      theme: AppTheme.lightTheme,       // تم روشن ما
      darkTheme: AppTheme.darkTheme,   // تم تاریک ما
      themeMode: themeProvider.themeMode, // حالت فعلی را از Provider می‌خواند

      home: const SplashScreen(), // تغییر صفحه شروع به اسپلش اسکرین
      debugShowCheckedModeBanner: false,
    );
  }
}