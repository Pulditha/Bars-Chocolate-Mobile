import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../providers/connectivity_provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../providers/theme_provider.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthService authService = AuthService();
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    UserModel? fetchedUser = await authService.getUserProfile();
    setState(() {
      user = fetchedUser;
    });
  }

  void _logout() async {
    await authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _launchWebsite() async {
    final Uri url = Uri.parse("https://bars-chocolate.online");
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open website")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    bool isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("No Internet Connection"),
        backgroundColor: Colors.red,
      ));
    }

    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Section
            Column(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.brown[800],
                  child: Text(
                    user!.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  user!.name,
                  style:
                  TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  user!.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 20),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.white),
                        SizedBox(width: 8),
                        Text("Logout",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Settings Sections
            _buildSection(
              title: "Dark Mode",
              description:
              "Enable dark mode for a better night-time experience.",
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),

            _buildSection(
              title: "Scan QR Code",
              description: "Quickly scan QR codes to access features.",
              icon: Icons.qr_code_scanner,
              onTap: () {
                // TODO: Implement QR Scanner
              },
            ),

            _buildSection(
              title: "Manage Subscriptions",
              description: "View and manage your active subscriptions.",
              icon: Icons.subscriptions,
              onTap: () {
                // TODO: Navigate to subscriptions screen
              },
            ),

            _buildSection(
              title: "Privacy Settings",
              description: "Adjust your privacy and security preferences.",
              icon: Icons.privacy_tip,
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),

            // Visit Our Website Section
            _buildSection(
              title: "Visit Our Website",
              description: "Explore our website for more information.",
              icon: Icons.web,
              onTap: _launchWebsite,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    IconData? icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: icon != null
            ? Icon(icon, size: 30, color: Colors.brown)
            : null,
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description, style: TextStyle(color: Colors.grey)),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
