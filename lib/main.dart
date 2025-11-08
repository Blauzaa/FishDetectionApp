import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fish_detection_v2/screens/splash_screen.dart'; 
import 'firebase_options.dart';
import 'package:fish_detection_v2/services/auth_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await AuthService.signInAnonymously();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF1976D2); 

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fish Detection',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor, 
        ),
        useMaterial3: true,
       
        appBarTheme: const AppBarTheme(
          centerTitle: true, 
          backgroundColor: Colors.white, 
          elevation: 0.5, 
          titleTextStyle: TextStyle(
            color: primaryColor, 
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: primaryColor, 
          ),
        ),
       
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, 
            foregroundColor: Colors.white, 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), 
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}