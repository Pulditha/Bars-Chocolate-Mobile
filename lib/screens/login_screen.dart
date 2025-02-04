import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navbar.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();
  String? errorMessage;

  void handleLogin() async {
    setState(() => errorMessage = null);

    String? error = await authService.login(emailController.text, passwordController.text);
    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottomNavBar()));
    } else {
      setState(() => errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: TextStyle(color: Colors.red)),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: handleLogin, child: Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
