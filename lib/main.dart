import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error loading app')));
          } else {
            // ✅ Redirect to BottomNavBar() after login
            return snapshot.data == true ? BottomNavBar() : LoginScreen();
          }
        },
      ),
    );
  }
}
