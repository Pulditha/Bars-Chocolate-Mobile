import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

import 'login_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// Check login status and navigate accordingly
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(Duration(seconds: 2)); // Show splash for 2 seconds
    bool isLoggedIn = await AuthService().isLoggedIn();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn ? BottomNavBar() : LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[800], // Customize the splash screen color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(height: 16),
            Text(
              "BARS.ONLINE",
              style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
