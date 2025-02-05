import 'dart:convert';
import 'product.dart';

class CartItem {
  final int id;
  final int userId;
  final int productId;
  final int quantity;
  final Product product;
  final List<String> images;
  final String category;
  final double finalPrice; // Actual price minus discount

  CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.product,
    required this.images,
    required this.category,
    required this.finalPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    double price = parseDouble(json['product']['price']);
    double discountPrice = parseDouble(json['product']['discount_price']);

    // Calculate the final price (price - discount)
    double finalPrice = discountPrice > 0 ? (price - discountPrice) : price;

    return CartItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      product: Product.fromJson(json['product']),
      images: json['product']['images'] != null
          ? List<String>.from(jsonDecode(json['product']['images']))
          : [],
      category: json['product']['category'] ?? "Unknown",
      finalPrice: finalPrice,
    );
  }
}

  List<CartItem> cartItemsFromJson(String str) {
  final jsonData = json.decode(str);
  return List<CartItem>.from(jsonData["cart_items"].map((x) => CartItem.fromJson(x)));
}
