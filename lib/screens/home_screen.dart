import 'package:flutter/material.dart';
import 'input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
       
              Text(
                'Aplikasi Deteksi\nJenis Ikan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 40),

              Image.asset(
                'assets/splash_logo.png',
                width: 130,
                color: primaryColor,
              ),
              const SizedBox(height: 60),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const InputScreen()));
                },
                child: const Text('Mulai Deteksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}