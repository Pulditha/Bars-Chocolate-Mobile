import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'providers/connectivity_provider.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()), // Added network provider
      ],
      child: Consumer2<ThemeProvider, ConnectivityProvider>(
        builder: (context, themeProvider, connectivityProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: FutureBuilder<bool>(
              future: AuthService().isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(body: Center(child: CircularProgressIndicator()));
                } else if (snapshot.hasError) {
                  return Scaffold(body: Center(child: Text('Error loading app')));
                } else {
                  bool isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
                  return Stack(
                    children: [
                      snapshot.data == true ? BottomNavBar() : LoginScreen(),
                      if (!isOnline) _buildNoInternetBanner(), // Show No Internet Banner
                    ],
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }

  /// Widget to show a "No Internet Connection" banner
  Widget _buildNoInternetBanner() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "No Internet Connection",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
