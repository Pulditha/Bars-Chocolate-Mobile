import 'dart:convert';

class Product {
  final int id;
  final String name;
  final String category;
  final String description;
  final List<String> images;
  final String price;
  final String currency;
  final int stockQuantity;
  final String stockStatus;
  final String weight;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.images,
    required this.price,
    required this.currency,
    required this.stockQuantity,
    required this.stockStatus,
    required this.weight,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imageList = [];

    if (json['images'] is String) {
      try {
        imageList = List<String>.from(jsonDecode(json['images']));
      } catch (e) {
        imageList = [];
      }
    } else if (json['images'] is List) {
      imageList = List<String>.from(json['images']);
    }

    return Product(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      images: imageList,
      price: json['price'],
      currency: json['currency'],
      stockQuantity: json['stock_quantity'],
      stockStatus: json['stock_status'],
      weight: json['weight'],
    );
  }
}
