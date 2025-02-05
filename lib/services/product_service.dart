import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    final String url = "$BASE_URL/products"; // Use BASE_URL from constants.dart

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Get saved auth token

      if (token == null) {
        throw Exception("User is not authenticated. Please log in.");
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include token in request
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Handle potential JSON decoding errors
        Map<String, dynamic> jsonData;
        try {
          jsonData = jsonDecode(response.body);
        } catch (e) {
          throw Exception("Invalid JSON response: ${e.toString()}");
        }

        if (!jsonData.containsKey("products")) {
          throw Exception("Unexpected API response format: Missing 'products' key.");
        }

        List<dynamic> productList = jsonData["products"]; // Extract the list
        return productList.map((item) => Product.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized: Please log in again.");
      } else if (response.statusCode == 404) {
        throw Exception("Resource not found.");
      } else {
        throw Exception("Failed to load products: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }
}