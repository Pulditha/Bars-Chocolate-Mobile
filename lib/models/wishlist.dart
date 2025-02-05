import 'dart:convert';
import 'product.dart';

class WishlistItem {
  final int id;
  final int userId;
  final int productId;
  final Product product;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'],
      userId: json['user_id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product']),
    );
  }

  static List<WishlistItem> parseWishlist(String responseBody) {
    final List<dynamic> parsed = jsonDecode(responseBody);
    return parsed.map((json) => WishlistItem.fromJson(json)).toList();
  }
}
