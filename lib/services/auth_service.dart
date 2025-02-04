import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';

class AuthService {
  // LOGIN METHOD
  Future<String?> login(String email, String password) async {
    try {
      final url = Uri.parse("$BASE_URL/login");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        return null; // Success
      } else {
        return ErrorHandler.getErrorMessage(response.body);
      }
    } catch (e) {
      return 'Network Error. Please try again.';
    }
  }

  // REGISTER METHOD
  Future<String?> register(String name, String email, String password, String confirmPassword) async {
    if (password != confirmPassword) return "Passwords do not match.";

    try {
      final url = Uri.parse("$BASE_URL/register");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      if (response.statusCode == 201) {
        return null; // Success
      } else {
        return ErrorHandler.getErrorMessage(response.body);
      }
    } catch (e) {
      return 'Network Error. Please try again.';
    }
  }

  // LOGOUT METHOD
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse("$BASE_URL/logout");

    await http.post(url, headers: {"Authorization": "Bearer $token"});
    await prefs.remove('token');
  }

  // CHECK LOGIN STATUS
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
