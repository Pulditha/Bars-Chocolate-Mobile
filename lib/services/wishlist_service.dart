import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist.dart';
import '../utils/constants.dart';

class WishlistService {
  Future<List<WishlistItem>> fetchWishlist() async {
    final String url = "$BASE_URL/wishlist";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("User is not authenticated. Please log in.");
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return WishlistItem.parseWishlist(response.body);
      } else {
        throw Exception("Failed to load wishlist: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching wishlist: $e");
    }
  }

  Future<bool> toggleWishlist(int productId, String action) async {
    final String url = "$BASE_URL/wishlist/toggle";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception("User is not authenticated. Please log in.");
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"product_id": productId, "action": action}),
      );

      if (response.statusCode == 200) {
        return true; // Success
      } else {
        throw Exception("Failed to update wishlist: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error updating wishlist: $e");
    }
  }
}
