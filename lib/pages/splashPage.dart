import 'package:flutter/material.dart';
import 'dart:async';

class Splashpage extends StatefulWidget {
  @override
  _SplashpageState createState() => _SplashpageState();
}

class _SplashpageState extends State<Splashpage> {
  @override
  void initState() {
    super.initState();
    print('Splash Screen initialized');
    _navigateToLogin();
  }

  void _navigateToLogin() {
    print('Memulai');
    Timer(Duration(seconds: 3), () {
      print('Navigation timer completed');
      Navigator.pushReplacementNamed(context, '/login')
          .then((_) => print('Navigated to login'))
          .catchError((error) => print('Navigation error: $error'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/Logo.jpeg',
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $error');
                return Icon(Icons.error, size: 150, color: Colors.white);
              },
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 10),
            Text(
              'Tunggu...',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
