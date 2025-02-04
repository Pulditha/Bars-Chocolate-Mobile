import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class AccountScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  void _logout(BuildContext context) async {
    await authService.logout();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _logout(context),
          child: Text("Logout"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ),
    );
  }
}
