import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fish_detection_v2/screens/main_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Pindah ke halaman utama setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white, 
      body: Center(

        child: Image.asset(
          'assets/splash_logo.png',
          width: 150, 
        ),
      ),
    );
  }
}