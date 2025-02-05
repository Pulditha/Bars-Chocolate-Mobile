import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
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
        await prefs.setString('user', jsonEncode(data['user']));
        return null; // Success
      } else {
        return ErrorHandler.getErrorMessage(response.body);
      }
    } catch (e) {
      return 'Network Error. Please try again.';
    }
  }

  // GET AUTH TOKEN METHOD
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET LOGGED-IN USER PROFILE AS USERMODEL
  Future<UserModel?> getUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null && userData.isNotEmpty) {
      try {
        Map<String, dynamic> userMap = jsonDecode(userData);
        return UserModel.fromJson(userMap);
      } catch (e) {
        return null; // Handle JSON parsing error
      }
    }
    return null;
  }

  // GET USERNAME METHOD
  Future<String?> getUsername() async {
    UserModel? user = await getUserProfile();
    return user?.name;
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

    if (token != null) {
      await http.post(url, headers: {"Authorization": "Bearer $token"});
    }

    await prefs.remove('token');
    await prefs.remove('user');
  }

  // CHECK LOGIN STATUS
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }
}
