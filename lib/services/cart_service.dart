import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../utils/constants.dart';

class CartService {
  /// Fetches all cart items for the authenticated user.
  Future<List<CartItem>> fetchCartItems() async {
    final String url = "$BASE_URL/cart";

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
        return cartItemsFromJson(response.body);
      } else {
        throw Exception("Failed to load cart items: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching cart: $e");
    }
  }

  /// Toggles an item in the cart (adds or removes it).
  Future<void> toggleCart(int productId, bool isInCart) async {
    final String url = "$BASE_URL/cart/toggle";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated.");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'product_id': productId,
          'action': isInCart ? 'remove' : 'add',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to toggle cart item. Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating cart: $e");
    }
  }

  /// Increases or decreases the quantity of a product in the cart.
  Future<void> updateQuantity(int productId, bool increase) async {
    final String url = increase
        ? "$BASE_URL/cart/increase-quantity"
        : "$BASE_URL/cart/decrease-quantity";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated.");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update quantity. Error: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error updating quantity: $e");
    }
  }

  Future<void> checkout() async {
    final String url = "$BASE_URL/cart/checkout";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated.");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print("Checkout successful.");
      } else {
        throw Exception("Checkout failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error during checkout: $e");
    }
  }

}
