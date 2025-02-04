import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/bottom_navbar.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final AuthService authService = AuthService();
  String? message;
  bool isSuccess = false;

  void handleRegister() async {
    setState(() => message = null);

    String? error = await authService.register(
      nameController.text,
      emailController.text,
      passwordController.text,
      confirmPasswordController.text,
    );

    if (error == null) {
      setState(() {
        message = "Registration Successful!";
        isSuccess = true;
      });

      // Redirect to HomeScreen after successful registration
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavBar()),
        );
      });
    } else {
      setState(() {
        message = error;
        isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (message != null)
              Text(
                message!,
                style: TextStyle(color: isSuccess ? Colors.green : Colors.red),
              ),
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: confirmPasswordController, decoration: InputDecoration(labelText: 'Confirm Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: handleRegister, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
