import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smart_home/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // این متد بعد از 3 ثانیه کاربر را به صفحه لاگین منتقل می‌کند
  void _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 6000), () {});
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // استفاده از ویجت Lottie برای نمایش انیمیشن
        child: Lottie.asset(
          'assets/splash_animation.json', // مسیر فایل انیمیشن شما
          width: 250,
          height: 250,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}