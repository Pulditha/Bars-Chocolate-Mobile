import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart'; // New Splash Screen
import 'services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()), // Network provider
      ],
      child: Consumer2<ThemeProvider, ConnectivityProvider>(
        builder: (context, themeProvider, connectivityProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: SplashScreen(), // Show SplashScreen first
          );
        },
      ),
    );
  }
}
